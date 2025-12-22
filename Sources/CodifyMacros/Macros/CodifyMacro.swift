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
            context.diagnose(Diagnostic(node: declaration, message: CodifyMacroDiagnostic.notStruct))
            return []
        }

        let generator = try CodifyGenerator(node: node, declaration: structDecl, context: context, defaultValueSyntaxName: DefaultValueMacro.macroName)
        return generator.generate()
    }
}

let accessModifiers = ["public", "private", "internal", "fileprivate", "open"]
/*
 EN: CodifyMacro implements the core macro that generates CodingKeys, decoding/encoding methods, and optionally adds Codable conformances via extension.
 ZH: CodifyMacro 实现核心宏，生成 CodingKeys、解码/编码方法，并在需要时通过扩展添加 Codable 协议。
 */
