import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(CodifyMacros)
import CodifyMacros

let macrosDict: [String: Macro.Type] = [
    "Codify": CodifyMacro.self,
    "CustomCodingKey": CustomCodingKeyMacro.self,
]
#endif

final class CodingKeyAttachmentTests: XCTestCase {
    func testCustomCodingKeyOnStructErrors() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @CustomCodingKey("x")
            struct S {}
            """,
            expandedSource:
            """
            struct S {}
            """,
            diagnostics: [
                .init(message: "[E005] EN: @CustomCodingKey can only be attached to properties | ZH: @CustomCodingKey 只能应用在属性上", line: 1, column: 1)
            ],
            macros: macrosDict
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

