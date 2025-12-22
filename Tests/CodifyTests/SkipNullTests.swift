import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(CodifyMacros)
import CodifyMacros

private let macrosSkipNull: [String: Macro.Type] = [
    "Codify": CodifyMacro.self,
    "SkipNull": SkipNullMacro.self,
    "DefaultValue": DefaultValueMacro.self,
    "CustomCodingKey": CustomCodingKeyMacro.self,
    "CodingKeyPrefix": CodingKeyPrefixMacro.self,
    "CodingKeySuffix": CodingKeySuffixMacro.self,
]
#endif

final class SkipNullTests: XCTestCase {

    func testOptionalPropertyUsesEncodeIfPresent() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                @SkipNull
                let nick: String?
            }
            """,
            expandedSource:
            """
            struct S {
                let nick: String?

                enum CodingKeys: String, CodingKey {
                    case nick = "nick"
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.nick = try container.decodeIfPresent(String.self, forKey: .nick)
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encodeIfPresent(self.nick, forKey: .nick)
                }
            }
            """,
            macros: macrosSkipNull
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testNestedOptionalObjectUsesEncodeIfPresent() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                @SkipNull
                let child: Child?
            }
            """,
            expandedSource:
            """
            struct S {
                let child: Child?

                enum CodingKeys: String, CodingKey {
                    case child = "child"
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.child = try container.decodeIfPresent(Child.self, forKey: .child)
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encodeIfPresent(self.child, forKey: .child)
                }
            }
            """,
            macros: macrosSkipNull
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testOptionalArrayUsesEncodeIfPresent() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                @SkipNull
                let values: [Int]?
            }
            """,
            expandedSource:
            """
            struct S {
                let values: [Int]?

                enum CodingKeys: String, CodingKey {
                    case values = "values"
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.values = try container.decodeIfPresent([Int?].self, forKey: .values)
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encodeIfPresent(self.values, forKey: .values)
                }
            }
            """,
            macros: macrosSkipNull
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testSkipNullOnNonOptionalHasNoEffect() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                @SkipNull
                let age: Int
            }
            """,
            expandedSource:
            """
            struct S {
                let age: Int

                enum CodingKeys: String, CodingKey {
                    case age = "age"
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.age = try container.decode(Int.self, forKey: .age)
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(self.age, forKey: .age)
                }
            }
            """,
            macros: macrosSkipNull
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
