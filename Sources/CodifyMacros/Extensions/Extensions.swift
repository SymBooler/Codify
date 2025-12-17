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
    func getProtocolDescriptions() -> [String] {
        if let simpleType = constraint.as(IdentifierTypeSyntax.self) {
            return [simpleType.name.text]
        } else if let compositionType = constraint.as(CompositionTypeSyntax.self) {
            return compositionType.elements.compactMap { $0.type.as(IdentifierTypeSyntax.self)?.name.text }
        }
        return []
    }
}

extension TypeSyntax {
    var isOptional: Bool {
        self.as(OptionalTypeSyntax.self) != nil ||
        self.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) != nil ||
        (self.as(IdentifierTypeSyntax.self)?.name.text == "Optional" &&
         self.as(IdentifierTypeSyntax.self)?.genericArgumentClause != nil)
    }
    
    var optionalWrappedType: String? {
        // Attempt to cast the TypeSyntax to OptionalTypeSyntax
        if let optionalType = self.as(OptionalTypeSyntax.self) {
            // If successful, return the trimmed description of its wrappedType
            return optionalType.wrappedType.trimmedDescription
        } else if let implicitlyUnwrappedOptionalType = self.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            // Handle ImplicitlyUnwrappedOptionalType (e.g., String!)
            return implicitlyUnwrappedOptionalType.wrappedType.trimmedDescription
        } else if let identifierType = self.as(IdentifierTypeSyntax.self),
                  identifierType.name.text == "Optional",
                  let genericArgument = identifierType.genericArgumentClause?.arguments.first?.argument {
            // Handle generic Optional (e.g., Optional<String>)
            return genericArgument.trimmedDescription
        }
        // If none of the above, it's not an optional type, so return nil
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
