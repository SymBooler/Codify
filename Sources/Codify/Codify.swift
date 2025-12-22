/*
 EN: Public macro entrypoints for the Codify library. These macros attach CodingKeys generation, Codable conformances, default values, and key case transformations to Swift types and properties.
 ZH: Codify 库的宏入口。通过这些宏为 Swift 类型和属性附加 CodingKeys 生成、Codable 协议、默认值以及键名大小写转换。
 */
// EN: See Swift language documentation for macro usage examples
// ZH: 宏使用示例可参考 Swift 语言官方文档
// https://docs.swift.org/swift-book

@attached(member, names: named(CodingKeys), arbitrary)
@attached(extension, conformances: Decodable, Encodable, names: named(==))
public macro Codify() = #externalMacro(module: "CodifyMacros", type: "CodifyMacro")

@attached(peer, names: named(==))
public macro DefaultValue<T>(_ value: T) = #externalMacro(module: "CodifyMacros", type: "DefaultValueMacro")

@attached(peer, names: named(==))
public macro SkipNull() = #externalMacro(module: "CodifyMacros", type: "SkipNullMacro")

@attached(peer, names: named(==))
public macro Lossless() = #externalMacro(module: "CodifyMacros", type: "LosslessMacro")

/// EN: Use a custom String value for a property's CodingKey
/// ZH: 为属性的 CodingKey 指定自定义字符串值
@attached(peer)
public macro CustomCodingKey(_ name: StringLiteralType) = #externalMacro(module: "CodifyMacros", type: "CustomCodingKeyMacro")

/// EN: Prefix the CodingKey with a custom value
/// ZH: 为 CodingKey 添加自定义前缀
@attached(peer)
public macro CodingKeyPrefix(_ name: StringLiteralType) = #externalMacro(module: "CodifyMacros", type: "CodingKeyPrefixMacro")

/// EN: Add a custom suffix to the CodingKey
/// ZH: 为 CodingKey 添加自定义后缀
@attached(peer)
public macro CodingKeySuffix(_ name: StringLiteralType) = #externalMacro(module: "CodifyMacros", type: "CodingKeySuffixMacro")

/// EN: CodingKey value will be `camelCase`
/// ZH: CodingKey 值转换为 `camelCase`
@attached(peer)
public macro CamelCase() = #externalMacro(module: "CodifyMacros", type: "CamelCaseMacro")

/// EN: CodingKey value will be `flatcase`
/// ZH: CodingKey 值转换为 `flatcase`
@attached(peer)
public macro FlatCase() = #externalMacro(module: "CodifyMacros", type: "FlatCaseMacro")

/// EN: CodingKey value will be `PascalCase`
/// ZH: CodingKey 值转换为 `PascalCase`
@attached(peer)
public macro PascalCase() = #externalMacro(module: "CodifyMacros", type: "PascalCaseMacro")

/// EN: CodingKey value will be `UPPERCASE`
/// ZH: CodingKey 值转换为 `UPPERCASE`
@attached(peer)
public macro UpperCase() = #externalMacro(module: "CodifyMacros", type: "UpperCaseMacro")

/// EN: CodingKey value will be `snake_case`
/// ZH: CodingKey 值转换为 `snake_case`
@attached(peer)
public macro SnakeCase() = #externalMacro(module: "CodifyMacros", type: "SnakeCaseMacro")

/// EN: CodingKey value will be `camel_Snake_Case`
/// ZH: CodingKey 值转换为 `camel_Snake_Case`
@attached(peer)
public macro CamelSnakeCase() = #externalMacro(module: "CodifyMacros", type: "CamelSnakeCaseMacro")

/// EN: CodingKey value will be `Pascal_Snake_Case`
/// ZH: CodingKey 值转换为 `Pascal_Snake_Case`
@attached(peer)
public macro PascalSnakeCase() = #externalMacro(module: "CodifyMacros", type: "PascalSnakeCaseMacro")

/// EN: CodingKey value will be `SCREAMING_SNAKE_CASE`
/// ZH: CodingKey 值转换为 `SCREAMING_SNAKE_CASE`
@attached(peer)
public macro ScreamingSnakeCase() = #externalMacro(module: "CodifyMacros", type: "ScreamingSnakeCaseMacro")

/// EN: CodingKey value will be `kebab-case`
/// ZH: CodingKey 值转换为 `kebab-case`
@attached(peer)
public macro KebabCase() = #externalMacro(module: "CodifyMacros", type: "KebabCaseMacro")

/// EN: CodingKey value will be `camel-Kebab-Case`
/// ZH: CodingKey 值转换为 `camel-Kebab-Case`
@attached(peer)
public macro CamelKebabCase() = #externalMacro(module: "CodifyMacros", type: "CamelKebabCaseMacro")

/// EN: CodingKey value will be `Pascal-Kebab-Case`
/// ZH: CodingKey 值转换为 `Pascal-Kebab-Case`
@attached(peer)
public macro PascalKebabCase() = #externalMacro(module: "CodifyMacros", type: "PascalKebabCaseMacro")

/// EN: CodingKey value will be `SCREAMING-KEBAB-CASE`
/// ZH: CodingKey 值转换为 `SCREAMING-KEBAB-CASE`
@attached(peer)
public macro ScreamingKebabCase() = #externalMacro(module: "CodifyMacros", type: "ScreamingKebabCaseMacro")
