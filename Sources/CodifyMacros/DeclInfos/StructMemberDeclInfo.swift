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
    let element: MemberBlockItemListSyntax.Element
    let accessModifier: DeclModifierSyntax?
    let name: String
    let type: TypeSyntax
    let typeDesc: String
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
    //    PropertyWrapper Type
    let propertyWrapperType: String?
    
    var hasValue: Bool { value != nil }
    
    init?(element: MemberBlockItemListSyntax.Element) throws {
        
        self.element = element
                
        guard let varDecl = element.decl.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let name = element.propertyIdentifier,
              let typeAnnotation = binding.typeAnnotation else {
                  return nil
              }
//        guard let name = element.propertyIdentifier,
//              let typeAnnotation = binding.typeAnnotation else {
//            throw DiagnosticsError(diagnostics: [.init(node: element, syntaxError: .codingKeyValueRequired)])
//        }
        
//        throw DiagnosticsError(diagnostics: [.init(node: element, syntaxError: .underlying("\(typeAnnotation.type.arrayElementType)"))])
        // 提取访问权限 private、public等
        let accessModifier = varDecl.modifiers.first { accessModifiers.contains($0.name.text) }
        
        // 提取类型信息
        let optionalWrappedType = typeAnnotation.type.optionalWrappedType?.trimmedDescription
        let typeDesc = typeAnnotation.type.optionalWrappedType?.trimmedDescription ?? typeAnnotation.type.trimmedDescription
        
        // 提取初始化值
        let value = binding.initializer?.value
        
        // 提取Attribute
        let attributes = varDecl.attributes.compactMap { $0.as(AttributeSyntax.self) }
        
        self.accessModifier = accessModifier
        self.name = name
        self.type = typeAnnotation.type
        self.typeDesc = typeDesc
        self.value = value
        self.isOptional = optionalWrappedType != nil
        self.attributes = attributes
        self.propertyWrapperType = varDecl.getPropertyWrapperType()
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
    
    func decodeDesc(_ defaultValueSyntaxName: String) throws -> String {
        
        let defaultValue = defaultValueAttribute()
//        是否包含`Lossless` 标签
        let containLossAttri = containAttribute(name: LosslessMacro.macroName)
        let propertyName = propertyWrapperType == nil ? name : "_" + name
        let skipNullAttr = attributes.first { $0.attributeName.trimmedDescription == SkipNullMacro.macroName }
        let unwrappedType = type.recursiveUnwrapOptionalType()
        let resolvedType = unwrappedType ?? type
        var typeDesc = resolvedType.trimmedDescription
        
        var tail = ""
        if let name = propertyWrapperType {
            typeDesc = name
        } else if skipNullAttr != nil {
            if let type = resolvedType.arrayElementType, !type.isOptional {
                typeDesc = "[\(type.trimmedDescription)?]"
                tail = ".compactMap { $0 }"
            } else if let type = resolvedType.setElementType, !type.isOptional {
                typeDesc = "[\(type.trimmedDescription)?]"
                tail = ".compactMap { $0 }.asSet()"
            } else if let (key, value) = resolvedType.dictionaryElementType, !value.isOptional {
                typeDesc = "[\(key.trimmedDescription): \(value.trimmedDescription)?]"
                tail = ".compactMapValues { $0 }"
            }
        } else if containLossAttri {
            typeDesc = typeDesc + ".Container"
            tail = ".losslessValue"
        }
        
        if unwrappedType != nil || defaultValue != nil {
            if !tail.isEmpty {
                tail = "?" + tail
            }
            let desc = "self.\(propertyName) = try container.decodeIfPresent(\(typeDesc).self, forKey: .\(name))\(tail)"
            if let value = defaultValue ?? value {
                return desc + " ?? \(value)"
            } else {
                return desc
            }
        } else {        
            return "self.\(propertyName) = try container.decode(\(typeDesc).self, forKey: .\(name))\(tail)"
        }
    }
    
    // EN: Find attribute value expression by name (e.g. @DefaultValue)
    // ZH: 根据名称查找属性的值表达式（如 @DefaultValue）
    func findAttribute(from attributes: [AttributeSyntax], byName name: String) -> ExprSyntax? {
        attributes.first { $0.attributeName.trimmedDescription == name }?.arguments?.as(LabeledExprListSyntax.self)?.first?.expression
    }
    
    // EN: Find attribute value expression by name (e.g. @DefaultValue)
    // ZH: 根据名称查找属性的值表达式（如 @DefaultValue）
    func defaultValueAttribute() -> ExprSyntax? {
        attributes.first { $0.attributeName.trimmedDescription == DefaultValueMacro.macroName }?.arguments?.as(LabeledExprListSyntax.self)?.first?.expression
    }
    
    func containAttribute(name: String) -> Bool {
        attributes.contains { $0.attributeName.trimmedDescription == name }
    }
}
