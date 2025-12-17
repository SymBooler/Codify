import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CodifyMacro: MemberMacro, ExtensionMacro, MacroNameable {
    static let macroName: String = "Codify"
    
    /// EN: Provide extension to attach Codable conformances when protocols are present
    /// ZH: 当存在目标协议时，提供扩展以附加 Codable 等协议
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    )
        throws -> [ExtensionDeclSyntax]
    {
        // EN: If no protocols were requested, skip generating extension
        // ZH: 若未请求任何协议，则跳过扩展生成
        guard !protocols.isEmpty else { return [] }
        
        return [
            ExtensionDeclSyntax(
                extendedType: type,
                inheritanceClause: InheritanceClauseSyntax(
                    inheritedTypes: InheritedTypeListSyntax {
                        protocols.map { InheritedTypeSyntax(type: $0) }
                    }
                ),
                memberBlock: MemberBlockSyntax(members: [])  // Empty for this example
            )
        ]
    }

    /// EN: Generate CodingKeys and Codable members for struct declarations
    /// ZH: 为结构体声明生成 CodingKeys 与 Codable 相关成员
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: declaration, message: DefaultValueMacroDiagnostic.notStruct))
            return []
        }

        let generator = try CodifyGenerator(node: node, declaration: structDecl, context: context, defaultValueSyntaxName: DefaultValueMacro.macroName)
        return generator.generate()
    }

    /// EN: Build CodingKeys enum from stored properties
    /// ZH: 根据存储属性构造 CodingKeys 枚举
    private static func buildCodingKeysEnum(members: MemberBlockItemListSyntax, accessModifier: DeclModifierSyntax?) -> DeclSyntax {
        var codingKeysElements: [EnumCaseElementSyntax] = []
        for member in members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = varDecl.bindings.first,
                  let propertyName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                continue
            }
            let caseElement = EnumCaseElementSyntax(name: .identifier(propertyName))
            codingKeysElements.append(caseElement)
        }
        
        return DeclSyntax(
            EnumDeclSyntax(
                modifiers: accessModifier.flatMap({ [$0] }) ?? [],
                name: .identifier("CodingKeys"),
                inheritanceClause: InheritanceClauseSyntax {
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("String")))
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("CodingKey")))
                },
                memberBlock: MemberBlockSyntax {
                    for caseElement in codingKeysElements {
                        EnumCaseDeclSyntax(elements: EnumCaseElementListSyntax { caseElement })
                    }
                }
            )
        )
    }

    /// EN: Build `init(from:)` that decodes all stored properties
    /// ZH: 构造 `init(from:)` 解码所有存储属性
    private static func buildInitFromDecoder(members: MemberBlockItemListSyntax, accessModifier: DeclModifierSyntax?, context: some MacroExpansionContext) -> DeclSyntax {
        let decodeStatements = members.compactMap { member -> String? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = varDecl.bindings.first,
                  let propertyName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let typeAnnotation = binding.typeAnnotation else {
                return nil
            }
//            let (isOptional, baseTypeIdentifier) = extractOptionalInfo(from: typeAnnotation)
            // EN: Extract optional wrapped type if present; fallback to raw type description
            // ZH: 若为可选类型则提取包裹类型，否则使用原始类型描述
            let optionalWrappedTypeIdentifier = typeAnnotation.type.optionalWrappedType
//            OptionalTypeUtil.getWrappedTypeDescription(typeAnnotation)
            let baseTypeIdentifier = optionalWrappedTypeIdentifier ?? typeAnnotation.type.trimmedDescription
            
            // EN: Detect @DefaultValue attribute on property
            // ZH: 检测属性上的 @DefaultValue 注解
            let isDefaultValued = varDecl.attributes.contains { attr in
                attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "DefaultValue"
            }
            if isDefaultValued {
                guard let defaultValueAttr = varDecl.attributes.first(where: {
                    $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "DefaultValue"
                })?.as(AttributeSyntax.self),
                      let defaultValueExpr = defaultValueAttr.arguments?.as(LabeledExprListSyntax.self)?.first?.expression else {
                    context.diagnose(
                        Diagnostic(
                            node: varDecl,
                            message: DefaultValueMacroDiagnostic.missingDefaultValue(propertyName)
                        )
                    )
                    return nil
                }
                return "self.\(propertyName) = try container.decodeIfPresent(\(baseTypeIdentifier).self, forKey: .\(propertyName)) ?? \(defaultValueExpr)"
            } else if optionalWrappedTypeIdentifier != nil {
                return "self.\(propertyName) = try container.decodeIfPresent(\(baseTypeIdentifier).self, forKey: .\(propertyName))"
            } else {
                return "self.\(propertyName) = try container.decode(\(baseTypeIdentifier).self, forKey: .\(propertyName))"
            }
        }
        
        return """
        \(raw: accessModifier.flatMap({ $0.name.text + " " }) ?? "")init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            \(raw: decodeStatements.joined(separator: "\n"))
        }
        """
    }

    /// EN: Build `encode(to:)` that encodes all stored properties
    /// ZH: 构造 `encode(to:)` 编码所有存储属性
    private static func buildEncodeToEncoder(members: MemberBlockItemListSyntax, accessModifier: DeclModifierSyntax?) -> DeclSyntax {
        let encodeStatements = members
            .compactMap { member -> String? in
                guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                      let binding = varDecl.bindings.first,
                      let propertyName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                    return nil
                }
                return "try container.encode(self.\(propertyName), forKey: .\(propertyName))"
            }
            .joined(separator: "\n")
        
        return """
        \(raw: accessModifier.flatMap({ $0.name.text + " " }) ?? "")func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            \(raw: encodeStatements)
        }
        """
    }
}

let accessModifiers = ["public", "private", "internal", "fileprivate", "open"]
/*
 EN: CodifyMacro implements the core macro that generates CodingKeys, decoding/encoding methods, and optionally adds Codable conformances via extension.
 ZH: CodifyMacro 实现核心宏，生成 CodingKeys、解码/编码方法，并在需要时通过扩展添加 Codable 协议。
 */
