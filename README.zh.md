<a id="top"></a>

[English](README.en.md#english) | 中文

# Codify

<a id="zh"></a>

## 功能特性
- 通过 `@Codify` 为结构体生成 `CodingKeys`、`init(from:)` 与 `encode(to:)`。
- 使用 `@CustomCodingKey("...")` 按属性自定义编码键。
- 支持结构体或属性级的 `CodingKeyPrefix`/`CodingKeySuffix` 前后缀。
- 提供多种键名大小写转换宏：`CamelCase`、`SnakeCase`、`PascalCase` 等。
- 使用 `@DefaultValue(T)`或者`let age: Int = 0` 在解码缺失或空值时提供默认值。
- 集中式宏诊断，提供双语错误码与提示信息。

## 安装指南
- 在 Swift Package Manager 的 `Package.swift` 中添加本仓库依赖。
- 在目标源码中 `import Codify`。
- 使用 `swift build` 构建，`swift test` 运行测试。

依赖示例（请替换为你的仓库 URL 与版本）：

```swift
dependencies: [
    .package(url: "https://github.com/your-org/Codify.git", from: "0.1.0")
]
```

## 使用说明
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

构建与测试：

```bash
swift build
swift test -q
```

## 宏参考
- `@Codify`：为结构体附加生成的 `CodingKeys`、`init(from:)` 与 `encode(to:)`。
- `@DefaultValue<T>(value)`：在解码缺失或空值时提供默认值。
- `@CustomCodingKey("string")`：覆盖某属性的编码键。
- `@CodingKeyPrefix("string")`、`@CodingKeySuffix("string")`：为编码键添加前缀/后缀。
- 键名大小写宏：
  - `@CamelCase`、`@FlatCase`、`@PascalCase`、`@UpperCase`
  - `@SnakeCase`、`@CamelSnakeCase`、`@PascalSnakeCase`、`@ScreamingSnakeCase`
  - `@KebabCase`、`@CamelKebabCase`、`@PascalKebabCase`、`@ScreamingKebabCase`

[返回顶部](#top)

