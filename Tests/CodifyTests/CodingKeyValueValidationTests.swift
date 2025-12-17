import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(CodifyMacros)
import CodifyMacros

let macrosVal: [String: Macro.Type] = [
    "Codify": CodifyMacro.self,
    "CustomCodingKey": CustomCodingKeyMacro.self,
]
#endif

final class CodingKeyValueValidationTests: XCTestCase {
    func testCustomCodingKeyMustBeStringLiteral() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                @CustomCodingKey(123)
                let id: Int
            }
            """,
            expandedSource:
            """
            struct S {
                let id: Int
            }
            """,
            diagnostics: [
                .init(message: #"[E001] EN: CodingKey must be a String Literal | ZH: CodingKey 必须是字符串字面量 | HINT: 使用 "value""#, line: 3, column: 5, severity: .error)
            ],
            macros: macrosVal
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCustomCodingKeyRequiresValue() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                @CustomCodingKey
                let id: Int
            }
            """,
            expandedSource:
            """
            struct S {
                let id: Int
            }
            """,
            diagnostics: [
                .init(message: #"[E002] EN: CodingKey requires a non-empty value | ZH: 必须提供非空字符串 | HINT: 传入非空字符串"#, line: 3, column: 5, severity: .error)
            ],
            macros: macrosVal
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCustomCodingKeyCannotBeEmpty() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                @CustomCodingKey("")
                let id: Int
            }
            """,
            expandedSource:
            """
            struct S {
                let id: Int
            }
            """,
            diagnostics: [
                .init(message: #"[E003] EN: CodingKey value cannot be empty | ZH: CodingKey 值不能为空 | HINT: 传入有效字符串"#, line: 3, column: 5, severity: .error)
            ],
            macros: macrosVal
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
