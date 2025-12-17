//
// CodingKeyMacros.swift
//
/*
 EN: Macro definitions for customizing CodingKeys generation, including per-property custom key, and struct-level prefix/suffix and case transformations.
 ZH: 自定义 CodingKeys 生成的宏定义，支持属性级自定义键、结构体级前缀/后缀与大小写转换。
 */

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// EN: Provide a unified macro name interface for diagnostics and usage
/// ZH: 提供统一的宏命名接口，用于诊断与使用
protocol MacroNameable {
    static var macroName: String { get }
}

/// Type: struct CustomCodingKeyMacro
/// Purpose: Auto-generated documentation for CustomCodingKeyMacro.

public struct CustomCodingKeyMacro: PeerMacro, MacroNameable {
    static let macroName: String = "CustomCodingKey"
    /// EN: Validate that macro is attached to a property; no peers are generated
    /// ZH: 校验宏仅能附加到属性；不生成同级声明
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard declaration.as(VariableDeclSyntax.self) != nil else {
            throw DiagnosticsError(diagnostics: [Diagnostic(node: node, syntaxError: .canOnlyBeAttachedToProperty(name: "@\(macroName)"))])
        }
        return []
    }
}

public struct CodingKeyPrefixMacro: PeerMacro {
    static let macroName: String = "CodingKeyPrefix"
    /// EN: Allow on structs with @Codify or properties; diagnose otherwise
    /// ZH: 可作用于带 @Codify 的结构体或属性；否则给出诊断
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            guard structDecl.hasCodableAttribute else {
                context.diagnose(Diagnostic(node: node, syntaxError: .requiresCodableMacro(name: macroName)))
                return []
            }
            return []
        } else if declaration.is(VariableDeclSyntax.self) {
            return []
        } else {
            context.diagnose(Diagnostic(node: declaration, syntaxError: .canOnlyBeAttachedToPropertiesAndStructs(name: macroName)))
            return []
        }
    }
}

public struct CodingKeySuffixMacro: PeerMacro {
    static let macroName: String = "CodingKeySuffix"
    /// EN: Allow on structs with @Codify or properties; diagnose otherwise
    /// ZH: 可作用于带 @Codify 的结构体或属性；否则给出诊断
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            guard structDecl.hasCodableAttribute else {
                context.diagnose(Diagnostic(node: node, syntaxError: .requiresCodableMacro(name: macroName)))
                return []
            }
            return []
        } else if declaration.is(VariableDeclSyntax.self) {
            return []
        } else {
            context.diagnose(Diagnostic(node: declaration, syntaxError: .canOnlyBeAttachedToPropertiesAndStructs(name: macroName)))
            return []
        }
    }
}

/// Interface for a basic decorating CodingKey macro
/// Used to unify identical definitions
/// EN: Base protocol for decorating CodingKey case transformations
/// ZH: CodingKey 大小写转换装饰宏的基础协议
protocol DecoratingCodingKeyAttribute: PeerMacro, MacroNameable {
    /// The kind of CodingKey for this macro
    static var attributeType: CodingKeyAttribute { get }
}

extension DecoratingCodingKeyAttribute {
    static var macroName: String { attributeType.rawValue }

    /// EN: Case macros apply to structs with @Codify or to properties; diagnose invalid attachments
    /// ZH: 大小写宏可用于带 @Codify 的结构体或属性；非法附着给出诊断
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            guard structDecl.hasCodableAttribute else {
                throw DiagnosticsError(diagnostics: [Diagnostic(node: node, syntaxError: .requiresCodableMacro(name: macroName))])
            }
            return []
        } else if declaration.is(VariableDeclSyntax.self) {
            return []
        }
        else {
            context.diagnose(Diagnostic(node: declaration, syntaxError: .canOnlyBeAttachedToPropertiesAndStructs(name: macroName)))
            return []
        }
    }
}

/// Type: struct CamelCaseMacro
/// Purpose: Auto-generated documentation for CamelCaseMacro.

public struct CamelCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .camelCase }
}

/// Type: struct FlatCaseMacro
/// Purpose: Auto-generated documentation for FlatCaseMacro.

public struct FlatCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .flatCase }
}

/// Type: struct PascalCaseMacro
/// Purpose: Auto-generated documentation for PascalCaseMacro.

public struct PascalCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .pascalCase }
}

/// Type: struct UpperCaseMacro
/// Purpose: Auto-generated documentation for UpperCaseMacro.

public struct UpperCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .upperCase }
}

/// Type: struct SnakeCaseMacro
/// Purpose: Auto-generated documentation for SnakeCaseMacro.

public struct SnakeCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .snakeCase }
}

/// Type: struct CamelSnakeCaseMacro
/// Purpose: Auto-generated documentation for CamelSnakeCaseMacro.

public struct CamelSnakeCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .camelSnakeCase }
}

/// Type: struct PascalSnakeCaseMacro
/// Purpose: Auto-generated documentation for PascalSnakeCaseMacro.

public struct PascalSnakeCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .pascalSnakeCase }
}

/// Type: struct ScreamingSnakeCaseMacro
/// Purpose: Auto-generated documentation for ScreamingSnakeCaseMacro.

public struct ScreamingSnakeCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .screamingSnakeCase }
}

/// Type: struct KebabCaseMacro
/// Purpose: Auto-generated documentation for KebabCaseMacro.

public struct KebabCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .kebabCase }
}

/// Type: struct CamelKebabCaseMacro
/// Purpose: Auto-generated documentation for CamelKebabCaseMacro.

public struct CamelKebabCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .camelKebabCase }
}

/// Type: struct PascalKebabCaseMacro
/// Purpose: Auto-generated documentation for PascalKebabCaseMacro.

public struct PascalKebabCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .pascalKebabCase }
}

/// Type: struct ScreamingKebabCaseMacro
/// Purpose: Auto-generated documentation for ScreamingKebabCaseMacro.

public struct ScreamingKebabCaseMacro: DecoratingCodingKeyAttribute {
    static var attributeType: CodingKeyAttribute { .screamingKebabCase }
}

enum CodingKeyAttribute: String, CaseIterable {
    /// casedLikeThis
    case camelCase = "CamelCase"
    /// casedlikethis
    case flatCase = "FlatCase"
    /// CasedLikeThis
    case pascalCase = "PascalCase"
    /// CASEDLIKETHIS
    case upperCase = "UpperCase"
    /// cased_like_this
    case snakeCase = "SnakeCase"
    /// cased_Like_This
    case camelSnakeCase = "CamelSnakeCase"
    /// cased_Like_This
    case pascalSnakeCase = "PascalSnakeCase"
    /// CASED_LIKE_THIS
    case screamingSnakeCase = "ScreamingSnakeCase"
    /// cased-like-this
    case kebabCase = "KebabCase"
    /// cased-Like-This
    case camelKebabCase = "CamelKebabCase"
    /// Cased-Like-This
    case pascalKebabCase = "PascalKebabCase"
    /// CASED-LIKE-THIS
    case screamingKebabCase = "ScreamingKebabCase"

    var codingKeyCase: CodingKeyCase {
        switch self {
        case .camelCase: .camelCase
        case .flatCase: .flatCase
        case .pascalCase: .pascalCase
        case .upperCase: .upperCase
        case .snakeCase: .snakeCase
        case .camelSnakeCase: .camelSnakeCase
        case .pascalSnakeCase: .pascalSnakeCase
        case .screamingSnakeCase: .screamingSnakeCase
        case .kebabCase: .kebabCase
        case .camelKebabCase: .camelKebabCase
        case .pascalKebabCase: .pascalKebabCase
        case .screamingKebabCase: .screamingKebabCase
        }
    }
}
