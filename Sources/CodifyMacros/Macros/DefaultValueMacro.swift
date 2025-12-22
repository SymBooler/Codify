//
//  File.swift
//  RayMacro
//
//  Created by zhangguanglu.ray on 2025/12/16.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct DefaultValueMacro: PeerMacro, MacroNameable {
    static let macroName: String = "DefaultValue"
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.as(VariableDeclSyntax.self) != nil else {
            context.diagnose(Diagnostic(node: declaration, message: CodifyMacroDiagnostic.notStruct))
            return []
        }
        
        return []
    }
}

// --- Diagnostic Messages for better error reporting ---
//public enum DefaultValueMacroDiagnostic: DiagnosticMessage {
//    case notStruct
//    case missingDefaultValue(String)
//
//    public var message: String {
//        switch self {
//        case .notStruct:
//            return "[D001] EN: @DefaultCodable can only be applied to a struct. | ZH: @DefaultCodable 只能应用在结构体上"
//        case .missingDefaultValue(let propertyName):
//            return "[E009] EN: Property '\(propertyName)' annotated with @DefaultValue requires a default value argument, e.g., @DefaultValue(\"\"). | ZH: 属性 '\(propertyName)' 使用 @DefaultValue 时必须提供默认值，例如 @DefaultValue(\"\")"
//        }
//    }
//
//    public var diagnosticID: MessageID {
//        MessageID(domain: "DefaultValueMacros", id: "DefaultValueMacro.\(self)")
//    }
//
//    public var severity: DiagnosticSeverity { .error }
//}
