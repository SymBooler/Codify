//
//  File.swift
//  RayMacro
//
//  Created by symbool.zhang on 2025/7/4.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/*
 EN: CodifyGenerator is a helper that constructs CodingKeys, decoding and encoding members for a struct based on its properties and attributes.
 ZH: CodifyGenerator 是用于根据结构体属性与注解构建 CodingKeys、解码与编码成员的辅助器。
 */

struct CodifyGenerator {
    let node: AttributeSyntax
    let declaration: StructDeclSyntax
    let context: MacroExpansionContext
    let defaultValueSyntaxName: String
    let structDeclInfo: StructDeclInfo
    let accessModifier: DeclModifierListSyntax.Element?
    let codingKeysGenerator: CodingKeysGenerator
    
    /// EN: Initialize generator with macro node, target struct, expansion context and @DefaultValue macro name
    /// ZH: 使用宏节点、目标结构体、展开上下文与 @DefaultValue 名称初始化生成器
    init(node: AttributeSyntax,
         declaration: StructDeclSyntax,
         context: MacroExpansionContext,
         defaultValueSyntaxName: String) throws {
        self.node = node
        self.declaration = declaration
        self.context = context
        self.defaultValueSyntaxName = defaultValueSyntaxName
        self.structDeclInfo = try StructDeclInfo(declaration: declaration)
        self.accessModifier = declaration.modifiers.first { accessModifiers.contains($0.name.text) }
        self.codingKeysGenerator = try CodingKeysGenerator(node: node, declaration: declaration, context: context)
    }

    /// EN: Build `init(from:)` decoding logic for members
    /// ZH: 为成员构造 `init(from:)` 解码逻辑
    func buildInitFromDecoder(_ members: [StructMemberDeclInfo], _ accessModifierStr: String) throws -> DeclSyntax {
//        let content = members.map { property -> String in
//            let defaultAttr = property.attributes.first { $0.attributeName.trimmedDescription == defaultValueSyntaxName }
//            let defaultValue = findAttribute(from: property.attributes, byName: defaultValueSyntaxName)
//            // EN: Emit error when @DefaultValue is present without argument
//            // ZH: 当存在 @DefaultValue 却未提供参数时抛出错误
//            if defaultAttr != nil && defaultValue == nil {
//                if let node = defaultAttr {
//                    context.diagnose(Diagnostic(node: node, message: CodifyMacroDiagnostic.missingDefaultValue(property.name)))
//                } else {
//                    context.diagnose(Diagnostic(node: declaration, message: CodifyMacroDiagnostic.missingDefaultValue(property.name)))
//                }
//            }
//            if let value = property.value ?? defaultValue {
//                return "self.\(property.name) = try container.decodeIfPresent(\(property.typeDesc).self, forKey: .\(property.name)) ?? \(value)"
//            } else if property.isOptional {
//                return "self.\(property.name) = try container.decodeIfPresent(\(property.typeDesc).self, forKey: .\(property.name))"
//            } else if let element = property.type.arrayElementType, element.optionalWrappedTypeDesc == nil {
////                context.diagnose(Diagnostic(node: declaration, message: CodifyMacroDiagnostic.underlying("\(element.optionalWrappedType)")))
//                return "self.\(property.name) = try container.decode([\(element.trimmedDescription)].self, forKey: .\(property.name))"
//            }
//            return "self.\(property.name) = try container.decode(\(property.typeDesc).self, forKey: .\(property.name))"
//        }.joined(separator: "\n")
        let content = try members.map { try $0.decodeDesc(defaultValueSyntaxName) }.joined(separator: "\n")
        
        return
            """
            \(raw: accessModifierStr)init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                \(raw: content)
            }
            """
    }

    /// EN: Build `encode(to:)` for members
    /// ZH: 为成员构造 `encode(to:)`
    func buildEncodeToEncoder(_ members: [StructMemberDeclInfo], _ accessModifierStr: String) -> DeclSyntax {
        let content = members.map { prop -> String in
            if prop.isOptional {
                return "try container.encodeIfPresent(self.\(prop.name), forKey: .\(prop.name))"
            }
            return "try container.encode(self.\(prop.name), forKey: .\(prop.name))"
        }.joined(separator: "\n")
        return """
        \(raw: accessModifierStr)func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            \(raw: content)
        }
        """
    }
    
    // EN: Find attribute value expression by name (e.g. @DefaultValue)
    // ZH: 根据名称查找属性的值表达式（如 @DefaultValue）
    func findAttribute(from attributes: [AttributeSyntax], byName name: String) -> ExprSyntax? {
        attributes.first { $0.attributeName.trimmedDescription == name }?.arguments?.as(LabeledExprListSyntax.self)?.first?.expression
    }
    
    /// EN: Check if `init(from:)` already exists
    /// ZH: 检查是否已存在 `init(from:)`
    func hasExistingInitFromDecoder() -> Bool {
        declaration.memberBlock.members.contains { member in
            if let initDecl = member.decl.as(InitializerDeclSyntax.self) {
//                throw CodifyMacroDiagnostic.underlying("\(initDecl.signature.parameterClause.parameters.first!.type.protocolDescriptions())")
                // 检查参数是否包含 "from decoder"
                return initDecl.signature.parameterClause.parameters.contains { param in
                    param.firstName.text == "from" &&
                    param.secondName?.text == "decoder" &&
                    param.type.isProtocolName("Decoder")
                }
            }
            return false
        }
    }
    
    /// EN: Check if `encode(to:)` already exists
    /// ZH: 检查是否已存在 `encode(to:)`
    func hasExistingEncodeToEncoder() -> Bool {
        declaration.memberBlock.members.contains { member in
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self) {
                // 检查函数名和参数
                return funcDecl.name.text == "encode" &&
                funcDecl.signature.parameterClause.parameters.contains { param in
                    param.firstName.text == "to" &&
                    param.secondName?.text == "encoder" &&
                    param.type.isProtocolName("Encoder")
                }
            }
            return false
        }
    }
    
    /// EN: Generate CodingKeys and Codable members, respecting existing implementations
    /// ZH: 生成 CodingKeys 与 Codable 成员，保留已有实现
    func generate() -> [DeclSyntax] {
        // 检查是否已经存在相关方法
//        let hasInitFromDecoder = hasExistingInitFromDecoder()
//        let hasEncodeToEncoder = hasExistingEncodeToEncoder()
        
        var declarations = [DeclSyntax]()
        let accessModifierStr = accessModifier.flatMap({ $0.name.text + " " }) ?? ""
        
        // 检查是否已经存在 `CodingKeys`
        if !structDeclInfo.hasCodingKeys {
            do {
                let codingKeys = try codingKeysGenerator.generate(accessModifier: accessModifier)
                declarations.append(codingKeys)
            } catch {
                context.addDiagnostics(from: error, node: node)
            }
        }
        // 检查是否已经存在 `InitFromDecoder`
        if !hasExistingInitFromDecoder() {
//            return ["test"]
            do {
                let fun = try buildInitFromDecoder(structDeclInfo.memberDeclInfo, accessModifierStr)
                declarations.append(fun)
            } catch {
                context.addDiagnostics(from: error, node: node)
            }
        }
        // 检查是否已经存在 `EncodeToEncoder`
        if !hasExistingEncodeToEncoder() {
            declarations.append(buildEncodeToEncoder(structDeclInfo.memberDeclInfo, accessModifierStr))
        }
        
        return declarations
    }
}
