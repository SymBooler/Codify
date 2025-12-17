//
//  CodingKeyInfo.swift
//  RayMacro
//
//  Created by symbool.zhang on 2025/7/5.
//
import SwiftSyntax

struct CodingAttributeInfo {
    let attributeType: CodingKeyAttribute

    var codingKeyCase: CodingKeyCase {
        attributeType.codingKeyCase
    }

    func asCodingKeyInfo(named name: String) throws -> CodingKeyInfo {
        switch attributeType {
        case .snakeCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .camelCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .flatCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .pascalCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .upperCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .camelSnakeCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .pascalSnakeCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .screamingSnakeCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .kebabCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .camelKebabCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .pascalKebabCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        case .screamingKebabCase: return .init(caseName: name, rawCaseValue: name, keyCase: codingKeyCase)
        }
    }
}

struct CodingKeyInfo {
    let caseName: String
    var rawCaseValue: String

    init(caseName: String, rawCaseValue: String) {
        self.caseName = caseName
        self.rawCaseValue = rawCaseValue.replacingOccurrences(of: "\"", with: "")
    }

    init(caseName: String, rawCaseValue: String, keyCase: CodingKeyCase) {
        self.init(caseName: caseName,
                  rawCaseValue: keyCase.makeKeyValue(from: rawCaseValue.replacingOccurrences(of: "\"", with: "")))
    }

    var declaration: MemberBlockItemSyntax {
        .init(enumCaseName: caseName, enumRawValueString: rawCaseValue)
    }
}
