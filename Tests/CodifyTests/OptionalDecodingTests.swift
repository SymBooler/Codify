import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(CodifyMacros)
import CodifyMacros

let macrosOpt: [String: Macro.Type] = [
    "Codify": CodifyMacro.self,
]
#endif

final class OptionalDecodingTests: XCTestCase {
    func testOptionalFormsUseDecodeIfPresent() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                let a: String?
                let b: Optional<Int>
                let c: String!
            }
            """,
            expandedSource:
            """
            struct S {
                let a: String?
                let b: Optional<Int>
                let c: String!

                enum CodingKeys: String, CodingKey {
                    case a = "a"
                    case b = "b"
                    case c = "c"
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.a = try container.decodeIfPresent(String.self, forKey: .a)
                    self.b = try container.decodeIfPresent(Int.self, forKey: .b)
                    self.c = try container.decodeIfPresent(String.self, forKey: .c)
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(self.a, forKey: .a)
                    try container.encode(self.b, forKey: .b)
                    try container.encode(self.c, forKey: .c)
                }
            }
            """,
            macros: macrosOpt
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

