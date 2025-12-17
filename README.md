<a id="top"></a>

English | [中文](README_zh.md#zh)

# Codify

<a id="english"></a>

## Features
- Generate `CodingKeys`, `init(from:)`, and `encode(to:)` for structs with `@Codify`.
- Customize coding keys per property via `@CustomCodingKey("...")`.
- Apply struct- or property-level `CodingKeyPrefix`/`CodingKeySuffix`.
- Transform key casing with macros like `CamelCase`, `SnakeCase`, `PascalCase`, etc.
- Provide default decoding values using `@DefaultValue(T)` or `let age: Int = 0`.
- Centralized macro diagnostics with bilingual error codes and hints.

## Installation
- Add this repository as a dependency in your Swift Package Manager `Package.swift`.
- Import `Codify` in your target source files.
- Build with `swift build` and run tests with `swift test`.

Example dependency entry (replace URL and version to match your setup):

```swift
dependencies: [
    .package(url: "https://github.com/your-org/Codify.git", from: "0.1.0")
]
```

## Usage
```swift
import Codify

@CodingKeyPrefix("prefix1_")
@CodingKeySuffix("_suffix1")
@Codify
public struct Cat: Codable {
    @CodingKeyPrefix("prefix_")
    @CodingKeySuffix("_suffix")
    @CustomCodingKey("custom_id")
    let id: Int

    @DefaultValue("title")
    let title: String

    @DefaultValue(1)
    @CodingKeyPrefix("prefix_")
    @CodingKeySuffix("_suffix")
    var count: Int = 2

    let description: Optional<String>
    let name: String?

    @CamelCase
    let cat_name: String
}
```

Build and test:

```bash
swift build
swift test -q
```

## Macros Reference
- `@Codify`: Attaches generated `CodingKeys`, `init(from:)`, and `encode(to:)` to a struct.
- `@DefaultValue<T>(value)`: Supplies a default when decoding missing or null fields.
- `@CustomCodingKey("string")`: Overrides the coding key for a property.
- `@CodingKeyPrefix("string")`, `@CodingKeySuffix("string")`: Adds prefix/suffix to coding keys.
- Case macros:
  - `@CamelCase`, `@FlatCase`, `@PascalCase`, `@UpperCase`
  - `@SnakeCase`, `@CamelSnakeCase`, `@PascalSnakeCase`, `@ScreamingSnakeCase`
  - `@KebabCase`, `@CamelKebabCase`, `@PascalKebabCase`, `@ScreamingKebabCase`

[Back to top](#top)

