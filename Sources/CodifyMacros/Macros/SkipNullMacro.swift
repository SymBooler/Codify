//
//  SkipNullMacro.swift
//  Codify
//
//  Created by zhangguanglu.ray on 2025/12/17.
//

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SkipNullMacro: PeerMacro, MacroNameable {
    static let macroName: String = "SkipNull"
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.as(VariableDeclSyntax.self) != nil else {
            context.diagnose(Diagnostic(node: declaration, message: CodifyMacroDiagnostic.canOnlyBeAttachedToProperty(name: macroName)))
            return []
        }
        
        return []
    }
}
