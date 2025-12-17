//
//  File.swift
//  RayMacro
//
//  Created by symbool.zhang on 2025/7/4.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

struct StructMemberDeclInfo {
    let accessModifier: DeclModifierSyntax?
    let name: String
    let type: String
    let value: ExprSyntax?
    let isOptional: Bool
    let isComputedProperty: Bool
    let attributes: [AttributeSyntax]
    //    前缀
    let codingKeyPrefix: String?
    //    后缀
    let codingKeySuffix: String?
    //    自定义CodingKey
    let customCodingKey: String?
    //    CamelCase 驼峰等标记
    let codingAttributes: [CodingAttributeInfo]
    
    var hasValue: Bool { value != nil }
    
    init(element: MemberBlockItemListSyntax.Element) throws {
        
        let error = DiagnosticsError(diagnostics: [.init(node: element, syntaxError: .codingKeyValueRequired)])
        
        guard let varDecl = element.decl.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first else {
            throw error
        }
        guard let name = element.propertyIdentifier else {
            throw error
        }
        guard let typeAnnotation = binding.typeAnnotation else {
            throw error
        }
        // 提取访问权限 private、public等
        let accessModifier = varDecl.modifiers.first { accessModifiers.contains($0.name.text) }
        // 提取类型信息
        let optionalWrappedType = typeAnnotation.type.optionalWrappedType
        let type = optionalWrappedType ?? typeAnnotation.type.trimmedDescription
        
        // 提取初始化值
        let value = binding.initializer?.value
        
        // 提取Attribute
        let attributes = varDecl.attributes.compactMap { $0.as(AttributeSyntax.self) }
        
        self.accessModifier = accessModifier
        self.name = name
        self.type = type
        self.value = value
        self.isOptional = optionalWrappedType != nil
        self.attributes = attributes
        self.isComputedProperty = element.isComputedProperty
        
        self.customCodingKey = try element.parameterValue(for: CustomCodingKeyMacro.macroName)
        self.codingAttributes = element.codingAttributes
        self.codingKeyPrefix = try element.parameterValue(for: CodingKeyPrefixMacro.macroName)
        self.codingKeySuffix = try element.parameterValue(for: CodingKeySuffixMacro.macroName)

        if customCodingKey == "" {
            throw DiagnosticsError(diagnostics: [.init(node: element, syntaxError: .codingKeyValueCannotBeEmpty)])
        }
    }
    
    var hasAnyAttributes: Bool {
        customCodingKey != nil
        || !codingAttributes.isEmpty
        || codingKeyPrefix != nil
        || codingKeySuffix != nil
    }
}
