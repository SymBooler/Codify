//
//  CodingKeysGenerator.swift
//  RayMacro
//
//  Created by symbool.zhang on 2025/12/16.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/*
 EN: CodingKeysGenerator resolves attributes and produces a CodingKeys enum with transformed raw values, respecting custom keys, prefixes and suffixes.
 ZH: CodingKeysGenerator 解析注解并生成包含转换后原始值的 CodingKeys 枚举，支持自定义键、前缀与后缀。
 */

class CodingKeysGenerator {
    let node: AttributeSyntax
    let declaration: DeclGroupSyntax
    let context: MacroExpansionContext
    let structDef: StructDeclInfo
    
    /// EN: Initialize with macro node, declaration group and expansion context
    /// ZH: 使用宏节点、声明组与展开上下文进行初始化
    init(node: AttributeSyntax, declaration: DeclGroupSyntax, context: MacroExpansionContext) throws {
        self.node = node
        self.declaration = declaration
        self.context = context
        self.structDef = try StructDeclInfo(declaration: declaration)
    }
    
    /// EN: Generate CodingKeys declaration; throws diagnostics for invalid configurations
    /// ZH: 生成 CodingKeys 声明；对非法配置抛出诊断
    func generate(accessModifier: DeclModifierSyntax?, insideExtension: Bool = false) throws -> DeclSyntax {
        guard let attributeName = node.attributeName.as(IdentifierTypeSyntax.self)?.name.text else {
            throw DiagnosticsError(diagnostics: [.init(node: node, syntaxError: CodifyMacroDiagnostic.requiresCodableMacro(name: CodifyMacro.macroName))])
        }

        guard structDef.attributeNameCanGenerate(name: attributeName) else {
            throw DiagnosticsError(diagnostics: [.init(node: node, syntaxError: CodifyMacroDiagnostic.requiresCodableMacro(name: attributeName))])
        }

        guard !structDef.hasCodingKeys else {
//            throw DiagnosticsError(diagnostics: [.init(node: node, syntaxError: .codingKeysExist)])
            throw DiagnosticsError(diagnostics: [.init(node: node, syntaxError: .underlying("hasCodingKeys"))])
        }
        
        guard structDef.codingAttributes.count <= 1 else {
            throw DiagnosticsError(diagnostics: [.init(node: node, syntaxWarning: .multipleCodingKeyAttributes)])
//            context.diagnose(.init(node: node, syntaxWarning: .multipleCodingKeyAttributes))
        }

        let cases = try declaration.memberBlock.members.compactMap { member -> CodingKeyInfo? in
            
            guard let property = try StructMemberDeclInfo(element: member),
                  var codingKey = try makeCodingKeyInfo(from: property, syntax: member, in: structDef) else {
                return nil
            }
            if property.customCodingKey == nil {
                if let prefix = property.codingKeyPrefix ?? structDef.codingKeyPrefix {
                    codingKey.rawCaseValue = prefix + codingKey.rawCaseValue
                }
                if let suffix = property.codingKeySuffix ?? structDef.codingKeySuffix {
                    codingKey.rawCaseValue = codingKey.rawCaseValue + suffix
                }
            }
            return codingKey
        }
        
        return makeCodingKeysEnum(from: cases, accessModifier: accessModifier).asDeclSyntax()        
    }
    
    /// EN: Produce CodingKeyInfo from a property and its attributes
    /// ZH: 根据属性及其注解生成 CodingKeyInfo
    private func makeCodingKeyInfo(from property: StructMemberDeclInfo, syntax member: MemberBlockItemListSyntax.Element, in structDefinition: StructDeclInfo) throws -> CodingKeyInfo? {

        guard !property.isComputedProperty else {
            if property.hasAnyAttributes {
                throw DiagnosticsError(diagnostics: [.init(node: member, syntaxWarning: .cannotBeAttachedToComputedProperties)])
//                context.diagnose(.init(node: member, syntaxWarning: .cannotBeAttachedToComputedProperties))
            }
            throw DiagnosticsError(diagnostics: [.init(node: member, syntaxWarning: .cannotBeAttachedToComputedProperties)])
        }

        if property.codingAttributes.count > 1 && property.customCodingKey == nil {
            throw DiagnosticsError(diagnostics: [.init(node: member, syntaxWarning: .multipleCodingKeyAttributes)])
//            context.diagnose(.init(node: member, syntaxWarning: .multipleCodingKeyAttributes))
        }
        if let codingKey = property.customCodingKey {
            if !property.codingAttributes.isEmpty {
//                context.diagnose(.init(node: member, syntaxWarning: .defaultingToCodingKey))
                throw DiagnosticsError(diagnostics: [.init(node: member, syntaxWarning: .defaultingToCodingKey)])
            }
            return .init(caseName: property.name, rawCaseValue: codingKey)
        }
        if let codingAttribute = property.codingAttributes.first {
            return try codingAttribute.asCodingKeyInfo(named: property.name)
        } else if let topLevelCodingAttribute = structDefinition.codingAttributes.first {
            return try topLevelCodingAttribute.asCodingKeyInfo(named: property.name)
        } else {
            return CodingKeyInfo(caseName: property.name, rawCaseValue: property.name, keyCase: .noChanges)
        }
    }
    
    /// EN: Materialize CodingKeys enum from key info collection
    /// ZH: 根据键信息集合构建 CodingKeys 枚举
    func makeCodingKeysEnum(from keys: [CodingKeyInfo], accessModifier: DeclModifierSyntax?) -> EnumDeclSyntax {
        EnumDeclSyntax(
            modifiers: accessModifier.flatMap({ [$0] }) ?? [],
            name: .identifier("CodingKeys"),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("String")))
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("CodingKey")))
            },
            memberBlock: .init(members: .init(keys.map(\.declaration)))
        )
    }
}
