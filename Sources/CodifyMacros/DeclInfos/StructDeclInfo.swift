//
//  StructDeclInfo.swift
//  RayMacro
//
//  Created by symbool.zhang on 2025/7/5.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

struct StructDeclInfo {
    
    let declaration: StructDeclSyntax
    
    let name: String
    // struct attributes
    let codingAttributes: [CodingAttributeInfo]
    let codingKeyPrefix: String?
    let codingKeySuffix: String?
    let memberDeclInfo: [StructMemberDeclInfo]
        
    init(declaration: DeclGroupSyntax) throws {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw DiagnosticsError(diagnostics: [Diagnostic(node: declaration, message: CodifyMacroDiagnostic.notStruct)])
        }
        try self.init(declaration: structDecl)
    }
    
    init(declaration: StructDeclSyntax) throws {
        self.declaration = declaration
        name = declaration.name.text
        codingAttributes = declaration.attributes.codingAttributes
        codingKeyPrefix = try declaration.parameterValue(for: CodingKeyPrefixMacro.macroName)
        codingKeySuffix = try declaration.parameterValue(for: CodingKeySuffixMacro.macroName)
        memberDeclInfo = try declaration.memberInfo()
    }
    
    var hasCodingKeys: Bool { codingKeyEnumDeclSyntax != nil }
    
    /// 检查是否已经存在 CodingKeys 枚举
    var codingKeyEnumDeclSyntax: EnumDeclSyntax? {
        declaration.memberBlock.members.first {
            $0.decl.as(EnumDeclSyntax.self)?.name.text == "CodingKeys"
        }?.decl.as(EnumDeclSyntax.self)
    }

    func attributeNameCanGenerate(name: String?) -> Bool {
        name == CodifyMacro.macroName
    }
}
