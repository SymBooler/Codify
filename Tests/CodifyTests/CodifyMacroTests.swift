import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(CodifyMacros)
import CodifyMacros

let macroMap: [String: Macro.Type] = [
    "Codify": CodifyMacro.self,
    "DefaultValue": DefaultValueMacro.self,
    "CustomCodingKey": CustomCodingKeyMacro.self,
    "CodingKeyPrefix": CodingKeyPrefixMacro.self,
    "CodingKeySuffix": CodingKeySuffixMacro.self,
    "CamelCase": CamelCaseMacro.self,
    "FlatCase": FlatCaseMacro.self,
    "PascalCase": PascalCaseMacro.self,
    "UpperCase": UpperCaseMacro.self,
    "SnakeCase": SnakeCaseMacro.self,
    "CamelSnakeCase": CamelSnakeCaseMacro.self,
    "PascalSnakeCase": PascalSnakeCaseMacro.self,
    "ScreamingSnakeCase": ScreamingSnakeCaseMacro.self,
    "KebabCase": KebabCaseMacro.self,
    "CamelKebabCase": CamelKebabCaseMacro.self,
    "PascalKebabCase": PascalKebabCaseMacro.self,
    "ScreamingKebabCase": ScreamingKebabCaseMacro.self,
]
#endif

final class CodifyMacroTests: XCTestCase {
    func testGeneratesCodingKeysInitEncode() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                let id: Int
                let name: String
            }
            """,
            expandedSource:
            """
            struct S {
                let id: Int
                let name: String

                enum CodingKeys: String, CodingKey {
                    case id = "id"
                    case name = "name"
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.id = try container.decode(Int.self, forKey: .id)
                    self.name = try container.decode(String.self, forKey: .name)
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(self.id, forKey: .id)
                    try container.encode(self.name, forKey: .name)
                }
            }
            """,
            macros: macroMap
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testPrefixSuffixAndCustomKey() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @CodingKeyPrefix("pre_")
            @CodingKeySuffix("_suf")
            @Codify
            struct S {
                @CustomCodingKey("identifier")
                let id: Int
                let title: String
            }
            """,
            expandedSource:
            """
            struct S {
                let id: Int
                let title: String

                enum CodingKeys: String, CodingKey {
                    case id = "identifier"
                    case title = "pre_title_suf"
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.id = try container.decode(Int.self, forKey: .id)
                    self.title = try container.decode(String.self, forKey: .title)
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(self.id, forKey: .id)
                    try container.encode(self.title, forKey: .title)
                }
            }
            """,
            macros: macroMap
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCaseConversions() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                @SnakeCase
                let userName: String
                @CamelCase
                let user_name_id: String
                @PascalCase
                let user_name: String
                @UpperCase
                let kind: String
                @KebabCase
                let httpStatusCode: String
            }
            """,
            expandedSource:
            """
            struct S {
                let userName: String
                let user_name_id: String
                let user_name: String
                let kind: String
                let httpStatusCode: String

                enum CodingKeys: String, CodingKey {
                    case userName = "user_name"
                    case user_name_id = "userNameId"
                    case user_name = "UserName"
                    case kind = "KIND"
                    case httpStatusCode = "http-status-code"
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.userName = try container.decode(String.self, forKey: .userName)
                    self.user_name_id = try container.decode(String.self, forKey: .user_name_id)
                    self.user_name = try container.decode(String.self, forKey: .user_name)
                    self.kind = try container.decode(String.self, forKey: .kind)
                    self.httpStatusCode = try container.decode(String.self, forKey: .httpStatusCode)
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(self.userName, forKey: .userName)
                    try container.encode(self.user_name_id, forKey: .user_name_id)
                    try container.encode(self.user_name, forKey: .user_name)
                    try container.encode(self.kind, forKey: .kind)
                    try container.encode(self.httpStatusCode, forKey: .httpStatusCode)
                }
            }
            """,
            macros: macroMap
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    

    

    func testMissingDefaultValueError() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            struct S {
                @DefaultValue
                let title: String
            }
            """,
            expandedSource:
            """
            struct S {
                let title: String

                enum CodingKeys: String, CodingKey {
                    case title = "title"
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.title = try container.decode(String.self, forKey: .title)
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode(self.title, forKey: .title)
                }
            }
            """,
            diagnostics: [
                .init(message: #"[E009] EN: Property 'title' annotated with @DefaultValue requires a default value argument, e.g., @DefaultValue(""). | ZH: 属性 'title' 使用 @DefaultValue 时必须提供默认值，例如 @DefaultValue("")"#, line: 3, column: 5, severity: .error)
            ],
            macros: macroMap
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testRequiresCodifyErrorOnPrefix() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @CodingKeyPrefix("p_")
            struct S {
                let a: Int
            }
            """,
            expandedSource:
            """
            struct S {
                let a: Int
            }
            """,
            diagnostics: [
                .init(message: #"[E010] EN: @Codify is required to use @CodingKeyPrefix | ZH: 使用 @CodingKeyPrefix 需要先添加 @Codify"#, line: 1, column: 1)
            ],
            macros: macroMap
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodifyOnEnumProducesError() throws {
        #if canImport(CodifyMacros)
        assertMacroExpansion(
            """
            @Codify
            enum E { case a }
            """,
            expandedSource:
            """
            enum E { case a 
            }
            """,
            diagnostics: [
                .init(message: "[D001] EN: @DefaultCodable can only be applied to a struct. | ZH: @DefaultCodable 只能应用在结构体上", line: 1, column: 1, severity: .error)
            ],
            macros: macroMap
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
}
