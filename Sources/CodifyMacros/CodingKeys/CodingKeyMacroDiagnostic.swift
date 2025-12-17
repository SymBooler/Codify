//
//  CodingKeyMacroDiagnostic.swift
//  RayMacro
//
//  Created by symbool.zhang on 2025/7/9.
//

import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros

/*
 EN: Centralized diagnostics for CodingKey-related macros. Provides unified bilingual messages with error codes,
     helper warnings for non-fatal cases, and convenience initializers for emitting diagnostics during macro expansion.
 ZH: 针对 CodingKey 相关宏的集中式诊断。提供带错误码的中英文统一消息、非致命场景的辅助警告，
     以及在宏展开期间便捷地抛出诊断的初始化方法。
 */

// --- Diagnostic Messages for better error reporting ---

/// EN: Diagnostic messages for CodingKey customization and usage validation
/// ZH: 用于 CodingKey 自定义与使用校验的诊断消息集合
public enum CodingKeyMacroDiagnostic: DiagnosticMessage {
    case mustBeStringLiteral
    case codingKeyValueRequired
    case codingKeyValueCannotBeEmpty
    case codingKeysExist
    case canOnlyBeAttachedToProperty(name: String)
    case canOnlyBeAttachedToStruct(name: String)
    case canOnlyBeAttachedToPropertiesAndStructs(name: String)
    
    case notStruct
    case missingDefaultValue(String)
    case requiresCodableMacro(name: String)
    case underlying(String)

    /// EN: Localized bilingual message with an error code and optional hint
    /// ZH: 带错误码与可选提示的本地化中英文消息
    public var message: String {
        switch self {
        case .mustBeStringLiteral:
            Self.fmt("E001", en: "CodingKey must be a String Literal", zh: "CodingKey 必须是字符串字面量", hint: "使用 \"value\"")
        case .codingKeyValueRequired:
            Self.fmt("E002", en: "CodingKey requires a non-empty value", zh: "必须提供非空字符串", hint: "传入非空字符串")
        case .codingKeyValueCannotBeEmpty:
            Self.fmt("E003", en: "CodingKey value cannot be empty", zh: "CodingKey 值不能为空", hint: "传入有效字符串")
        case .codingKeysExist:
            Self.fmt("E004", en: "Remove CodingKeys to use @\(CodifyMacro.macroName)", zh: "使用 @\(CodifyMacro.macroName) 前需移除已有 CodingKeys")
        case .canOnlyBeAttachedToProperty(let name):
            Self.fmt("E005", en: "\(name) can only be attached to properties", zh: "\(name) 只能应用在属性上")
        case .canOnlyBeAttachedToStruct(let name):
            Self.fmt("E006", en: "\(name) can only be attached to structs", zh: "\(name) 只能应用在结构体上")
        case .canOnlyBeAttachedToPropertiesAndStructs(let name):
            Self.fmt("E007", en: "\(name) can only be attached to properties and structs", zh: "\(name) 只能应用在属性或结构体上")
        case .notStruct:
            Self.fmt("E008", en: "Can only be applied to a struct.", zh: "只能应用在结构体上")
        case .missingDefaultValue(let propertyName):
            Self.fmt("E009", en: "Property '\(propertyName)' annotated with @DefaultValue requires a default value argument, e.g., @DefaultValue(\"\").", zh: "属性 '\(propertyName)' 使用 @DefaultValue 时必须提供默认值，例如 @DefaultValue(\"\")")
        case .requiresCodableMacro(let name):
            Self.fmt("E010", en: "@\(CodifyMacro.macroName) is required to use @\(name)", zh: "使用 @\(name) 需要先添加 @\(CodifyMacro.macroName)")
        case .underlying(let msg):
            Self.fmt("E099", en: msg, zh: msg)
        }
    }

    /// EN: Format a bilingual diagnostic message with a code and optional hint
    /// ZH: 格式化带错误码与可选提示的双语诊断消息
    static func fmt(_ code: String, en: String, zh: String, hint: String? = nil) -> String {
        // EN: Compose the base message with code and EN/ZH texts
        // ZH: 组装包含错误码与中英文文本的基础消息
        var s = "[\(code)] EN: \(en) | ZH: \(zh)"
        // EN: Append hint part only when present and non-empty
        // ZH: 仅在提示存在且非空时附加提示信息
        if let h = hint, !h.isEmpty { s += " | HINT: \(h)" }
        return s
    }

    /// EN: Group messages under a domain and identifier for diagnostics
    /// ZH: 为诊断消息设置域与唯一标识符
    public var diagnosticID: MessageID {
        MessageID(domain: "DefaultValueMacros", id: "DefaultValueMacro.\(self)")
    }

    /// EN: Treat all messages as errors to halt invalid macro usage
    /// ZH: 将所有消息标记为错误以阻止非法宏用法
    public var severity: DiagnosticSeverity { .error }
}

/// EN: Non-fatal warnings emitted during attribute resolution
/// ZH: 属性解析过程中的非致命警告
enum SyntaxWarning: Error {
    case multipleCodingKeyAttributes
    case defaultingToCodingKey
    case cannotBeAttachedToComputedProperties

    /// EN: Human-readable warning text used for macro expansion warnings
    /// ZH: 用于宏展开警告的可读性文本
    var localizedDescription: String {
        switch self {
        case .multipleCodingKeyAttributes: "Multiple CodingKey attributes found. Defaulting to the left most attribute"
        case .defaultingToCodingKey: "Multiple CodingKey attributes found. Defaulting to CodingKey(String)"
        case .cannotBeAttachedToComputedProperties: "CodingKey attributes cannot be attached to Computed Properties"
        }
    }
}

/// EN: Convenience initializer to emit an error diagnostic using `CodingKeyMacroDiagnostic`
/// ZH: 使用 `CodingKeyMacroDiagnostic` 便捷初始化并抛出错误诊断
extension Diagnostic {
    init(node: some SyntaxProtocol,
         position: AbsolutePosition? = nil,
         syntaxError: CodingKeyMacroDiagnostic,
         highlights: [Syntax]? = nil,
         notes: [Note] = [],
         fixIts: [FixIt] = []) {
        self.init(node: node,
                  position: position,
                  message: syntaxError,
                  highlights: highlights,
                  notes: notes,
                  fixIts: fixIts)
    }
    
    /// EN: Convenience initializer to emit a non-fatal macro expansion warning
    /// ZH: 便捷初始化并抛出非致命的宏展开警告
    init(node: some SyntaxProtocol,
         position: AbsolutePosition? = nil,
         syntaxWarning: SyntaxWarning,
         highlights: [Syntax]? = nil,
         notes: [Note] = [],
         fixIts: [FixIt] = []) {
        self.init(node: node,
                  position: position,
                  message: MacroExpansionWarningMessage(syntaxWarning.localizedDescription),
                  highlights: highlights,
                  notes: notes,
                  fixIts: fixIts)
    }
}
