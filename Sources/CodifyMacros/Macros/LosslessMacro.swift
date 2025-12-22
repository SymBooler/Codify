//
//  SkipNullMacro 2.swift
//  Codify
//
//  Created by zhangguanglu.ray on 2025/12/19.
//


import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LosslessMacro: PeerMacro, MacroNameable {
    static let macroName: String = "Lossless"
    
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
