import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(CodifyMacros)
import CodifyMacros

let testMacros: [String: Macro.Type] = [
    "Codify": CodifyMacro.self,
    "DefaultValue": DefaultValueMacro.self,
    "CustomCodingKey": CustomCodingKeyMacro.self,
    "CodingKeyPrefix": CodingKeyPrefixMacro.self,
    "CodingKeySuffix": CodingKeySuffixMacro.self,
]
#endif

final class CodifyTests: XCTestCase {
    func testSmoke() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S { let a: Int }
            """,
            expandedSource: """
            struct S { let a: Int 

                enum CodingKeys: String, CodingKey {
                    case a = "a"
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.a = try container.decode(Int.self, forKey: .a)
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(self.a, forKey: .a)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
