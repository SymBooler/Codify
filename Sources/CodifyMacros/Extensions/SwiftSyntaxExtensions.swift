//
//  Convenience.swift
//  RayMacro
//
//  Created by symbool.zhang on 2025/12/16.
//
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

extension MemberBlockItemListSyntax.Element {
    var isComputedProperty: Bool {
        decl.as(VariableDeclSyntax.self)?.bindings.first?.accessorBlock != nil
    }
}

extension MemberBlockItemListSyntax.Element {
    func parameterValue(for attributeName: String) throws -> String? {
        try attributeSyntax(named: attributeName)?.parameterValue()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
    }
}

extension Character {
    var isAlphaNumeric: Bool {
        isLetter || isNumber
    }
}

extension String {
    var isAllCaps: Bool {
        first { $0.isAlphaNumeric && $0.isLowercase } == nil
    }
}

extension DeclGroupSyntax {
    func parameterValue(for attributeName: String) throws -> String? {
        try attributes.attributeSyntax(named: attributeName)?.parameterValue()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
    }
}

extension AttributeSyntax {
    func parameterValue(at index: Int) throws -> ExprSyntax? {
        guard let argumentList = arguments?.as(LabeledExprListSyntax.self), argumentList.count > index else {
            throw DiagnosticsError(diagnostics: [.init(node: self, syntaxError: .codingKeyValueRequired)])
        }
        let argument = argumentList[argumentList.index(argumentList.startIndex, offsetBy: index)]
        // Get the value of the macro
        guard let customKeyValue = argument.expression.as(StringLiteralExprSyntax.self) else {
            throw DiagnosticsError(diagnostics: [.init(node: self, syntaxError: .mustBeStringLiteral)])
        }

        return ExprSyntax(customKeyValue)
    }

    func parameterValue() throws -> String {
        guard let caseValue = try parameterValue(at: 0), !"\(caseValue.syntaxTextBytes)".isEmpty else {
            throw DiagnosticsError(diagnostics: [.init(node: self, syntaxError: .codingKeyValueRequired)])
        }
        return "\(caseValue)"
    }
}

extension StructDeclSyntax {
    /// 检查是否已经存在 CodingKeys 枚举
    func getEnumDeclSyntax(named name: String) -> EnumDeclSyntax? {
        memberBlock.members.first {
            $0.decl.as(EnumDeclSyntax.self)?.name.text == name
        }?.decl.as(EnumDeclSyntax.self)
    }

    func parameterValue(for attributeName: String) throws -> String? {
        try attributes.attributeSyntax(named: attributeName)?.parameterValue()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
    }
}
extension MemberBlockItemListSyntax.Element {
    var propertyIdentifier: String? {
        decl.as(VariableDeclSyntax.self)?.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
    }

    func attribute(named attributeName: String) -> AttributeListSyntax.Element? {
        decl.as(VariableDeclSyntax.self)?.attributes.attribute(named: attributeName)
    }

    var codingAttributes: [CodingAttributeInfo] {
        attributes(matching: CodingKeyAttribute.self).map(CodingAttributeInfo.init(attributeType:))
    }

    func attributes<T: RawRepresentable>(matching rawType: T.Type) -> [T] where T.RawValue == String {
        decl.as(VariableDeclSyntax.self)?.attributes.matching(matching: T.self) ?? []
    }

    // Not currently used
//    func attributeSyntax<T: RawRepresentable>(matching rawType: T.Type) -> [(T, AttributeSyntax)] where T.RawValue == String {
//        decl.as(VariableDeclSyntax.self)?.attributes.matchingSyntax(matching: T.self) ?? []
//    }

/// Summary: Auto-generated documentation for attributeSyntax()
/// - Parameters:
///   - named name: String parameter.
/// - Returns: AttributeSyntax? value.

    func attributeSyntax(named name: String) -> AttributeSyntax? {
        attribute(named: name)?.as(AttributeSyntax.self)
    }
}

extension AttributeListSyntax {

    var codingAttributes: [CodingAttributeInfo] {
        matching(matching: CodingKeyAttribute.self).map(CodingAttributeInfo.init(attributeType:))
    }

    func attribute(named attributeName: String) -> AttributeListSyntax.Element? {
        first { $0.identifierName?.trimmingCharacters(in: .whitespacesAndNewlines) == attributeName }
    }

    func attributeSyntax(named attributeName: String) -> AttributeSyntax? {
        attribute(named: attributeName)?.as(AttributeSyntax.self)
    }

    func matching<T: RawRepresentable>(matching rawType: T.Type) -> [T] where T.RawValue == String {
        compactMap {
            guard let attributeName = $0.identifierName?.trimmingCharacters(in: .whitespacesAndNewlines), let type = T(rawValue: attributeName) else {
                return nil
            }
            return type
        }
    }

      // Not currently used
//    func matchingSyntax<T: RawRepresentable>(matching rawType: T.Type) -> [(T, AttributeSyntax)] where T.RawValue == String {
//        compactMap {
//            guard let attributeName = $0.identifierName?.trimmingCharacters(in: .whitespacesAndNewlines), let syntax = $0.as(AttributeSyntax.self), let type = T(rawValue: attributeName) else {
//                return nil
//            }
//            return (type, syntax)
//        }
//    }
}

extension StructDeclSyntax {
    func memberInfo() throws -> [StructMemberDeclInfo] {
        try memberBlock.members.compactMap { try StructMemberDeclInfo(element: $0) }
    }
}

extension SomeOrAnyTypeSyntax {
    func protocolName() -> [String] {
        if let simpleType = constraint.as(IdentifierTypeSyntax.self) {
            return [simpleType.name.text]
        } else if let compositionType = constraint.as(CompositionTypeSyntax.self) {
//            Decodable & Encodable
            return compositionType.elements.compactMap { $0.type.as(IdentifierTypeSyntax.self)?.name.text }
        }
        return []
    }
}

extension TypeSyntax {
    
    func protocolName() -> [String] {
        if let simpleType = self.as(IdentifierTypeSyntax.self) {
            return [simpleType.name.text]
        } else if let compositionType = self.as(CompositionTypeSyntax.self) {
//            Decodable & Encodable
            return compositionType.elements.compactMap { $0.type.as(IdentifierTypeSyntax.self)?.name.text }
        }
        return []
    }
    
    func isProtocolName(_ name: String) -> Bool {
        (self.as(SomeOrAnyTypeSyntax.self)?.protocolName() ?? protocolName()).contains { $0 == name }
    }
    
    var isOptional: Bool {
        self.as(OptionalTypeSyntax.self) != nil ||
        self.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) != nil ||
        (self.as(IdentifierTypeSyntax.self)?.name.text == "Optional" &&
         self.as(IdentifierTypeSyntax.self)?.genericArgumentClause != nil)
    }
    
    var optionalWrappedType: TypeSyntax? {
        // Attempt to cast the TypeSyntax to OptionalTypeSyntax
        // Type?
        if let optionalType = self.as(OptionalTypeSyntax.self) {
            // If successful, return the trimmed description of its wrappedType
            return optionalType.wrappedType
        } else if let implicitlyUnwrappedOptionalType = self.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            // Handle ImplicitlyUnwrappedOptionalType (e.g., String!)
            // Type!
            return implicitlyUnwrappedOptionalType.wrappedType
        } else if let identifierType = self.as(IdentifierTypeSyntax.self),
                  identifierType.name.text == "Optional",
                  let genericArgument = identifierType.genericArgumentClause?.arguments.first?.argument {
            // Handle generic Optional (e.g., Optional<String>)
            return genericArgument
        }
        // If none of the above, it's not an optional type, so return nil
        return nil
    }
    
    func recursiveUnwrapOptionalType() -> TypeSyntax? {
        // 从当前类型开始
        var currentType: TypeSyntax = self
        var isOptional = false
        
        // 循环查找可选类型的包装类型
        while true {
            // 检查当前类型是否为可选类型
            if let wrappedType = currentType.optionalWrappedType {
                // 如果是可选类型，继续解包
                currentType = wrappedType
                isOptional = true
            } else {
                // 如果不是可选类型，返回当前类型
                break
            }
        }
        
        return isOptional ? currentType : nil
    }
    
    var arrayElementType: TypeSyntax? {
        if let type = self.as(ArrayTypeSyntax.self) {
            return type.element
        } else if let identifierType = self.as(IdentifierTypeSyntax.self),
                  identifierType.name.text == "Array",
                  let genericArgument = identifierType.genericArgumentClause?.arguments.first?.argument {
            return genericArgument
        }
        return nil
    }
    
    var setElementType: TypeSyntax? {
        if let identifierType = self.as(IdentifierTypeSyntax.self),
                  identifierType.name.text == "Set",
                  let genericArgument = identifierType.genericArgumentClause?.arguments.first?.argument {
            return genericArgument
        }
        return nil
    }
    
    var dictionaryElementType: (TypeSyntax, TypeSyntax)? {
        if let type = self.as(DictionaryTypeSyntax.self) {
            return (type.key, type.value)
        } else if let identifierType = self.as(IdentifierTypeSyntax.self),
                  identifierType.name.text == "Dictionary",
                  let arguments = identifierType.genericArgumentClause?.arguments,
                  let key = arguments.first?.argument, let value = arguments.last?.argument {
            return (key, value)
        }
        return nil
    }
}

extension EnumCaseElementSyntax {
    init(name: String, rawValueString: String?) {
        self.init(name: .identifier(name),
                  rawValue: rawValueString.flatMap({ InitializerClauseSyntax(value: StringLiteralExprSyntax(content: $0)) }))
    }
}

extension MemberBlockItemSyntax {
    init(enumCaseName: String, enumRawValueString: String?) {
        self.init(decl: EnumCaseDeclSyntax(elements: .init([
            EnumCaseElementSyntax(name: enumCaseName, rawValueString: enumRawValueString)
        ])))
    }
}

extension EnumDeclSyntax {
    
    func getNoneAssociatedValueCaseNameAndRawValues() -> [(name: String, rawValue: String?)] {        
        memberBlock.members.flatMap {
            $0.decl.as(EnumCaseDeclSyntax.self)?.elements ?? []
        }.compactMap {
            $0.parameterClause == nil ? ($0.name.text, $0.rawValue?.value.trimmedDescription) : nil
        }
    }
    
    func asDeclSyntax() -> DeclSyntax {
        DeclSyntax(self)
    }
}

extension AttributeListSyntax.Element {
    var identifierName: String? {
        self.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text
    }
}

extension StructDeclSyntax {
    var hasCodableAttribute: Bool { hasAttribute(named: CodifyMacro.macroName) }

    func hasAttribute(named name: String) -> Bool {
        attributes.contains { $0.identifierName?.trimmingCharacters(in: .whitespacesAndNewlines) == name }
    }
}

extension VariableDeclSyntax {
    var isComputedProperty: Bool { bindings.first?.accessorBlock != nil }
}

extension VariableDeclSyntax {
    
    /// 尝试获取该变量上附带的 Property Wrapper 的类型字符串
    /// - Returns: 返回类型字符串 (例如 "LosslessValue<String>" 或 "State<Int>")，如果没有找到则返回 nil
    func getPropertyWrapperType() -> String? {
        // 1. 获取变量的原始类型 (例如 "String")
        guard let binding = self.bindings.first,
              let typeAnnotation = binding.typeAnnotation else {
            return nil
        }
        
        let originalType = typeAnnotation.type.trimmedDescription
        
        // 2. 遍历所有 Attribute
        for attribute in self.attributes {
            guard case let .attribute(attr) = attribute else { continue }
            
            // 获取属性名称 (例如 "LosslessValue", "objc", "State")
            let attributeName = attr.attributeName.trimmedDescription
            
            // 3. 【关键步骤】过滤 Swift 内置的标准属性
            // 这些肯定不是 Property Wrapper，直接跳过
            if isStandardSwiftAttribute(attributeName) {
                continue
            }
            // 3. 【关键步骤】过滤 Swift 当前项目宏标记
            // 这些肯定不是 Property Wrapper，直接跳过
            if isCodifyMacroAttribute(attributeName) {
                continue
            }
            
            // 4. 分析是否已经显式包含了泛型参数
            // 检查 attributeName 对应的 TypeSyntax 是否包含 genericArgumentClause
            // 场景 A: @Complex<Int> var x: Int -> attr.attributeName 里包含 <Int>
            // 场景 B: @LosslessValue var x: String -> attr.attributeName 只是 identifier
            
            if attributeName.contains("<") && attributeName.contains(">") {
                // 场景 A: 用户已经显式写了泛型，直接返回该名称作为类型
                return attributeName
            } else {
                // 场景 B: 标准 Wrapper 模式，需要把变量类型塞进去
                // 假设 Wrapper 是 MyWrapper<T>
                return "\(attributeName)<\(originalType)>"
            }
        }
        
        return nil
    }
    
    /// 辅助函数：判断是否是 Swift 内置的非 Wrapper 属性
    /// 这是一个简单的黑名单，可能需要根据 Swift 版本更新
    private func isStandardSwiftAttribute(_ name: String) -> Bool {
        let standardAttributes: Set<String> = [
            "available", "objc", "objcMembers", "inlinable", "discardableResult",
            "GKInspectable", "IBOutlet", "IBAction", "NSManaged", "requires_stored_property_inits",
            "warn_unqualified_access", "main", "preconcurrency", "frozen"
        ]
        return standardAttributes.contains(name)
    }
    
    private func isCodifyMacroAttribute(_ name: String) -> Bool {
        let standardAttributes: Set<String> = [
            "DefaultValue", "CustomCodingKey", "CodingKeyPrefix", "CodingKeySuffix", "SnakeCase","CamelCase", "FlatCase", "PascalCase", "UpperCase", "SnakeCase","CamelSnakeCase", "PascalSnakeCase", "ScreamingSnakeCase", "KebabCase", "CamelKebabCase", "PascalKebabCase", "ScreamingKebabCase", "SkipNull", "Lossless"
        ]
        return standardAttributes.contains(name)
    }
}
