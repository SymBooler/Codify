# Codify

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fowner%2Fname%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/)
[![](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-333333.svg)](https://developer.apple.com/swift/)

**Codify** is a powerful Swift Macro library designed to eliminate the boilerplate code often associated with `Codable`. It provides a declarative way to customize JSON key mapping, set default values, and apply naming strategies directly via attributes.

**Codify** 是一个强大的 Swift Macro 库，旨在消除 `Codable` 中常见的样板代码。它提供了一种声明式的方法，通过注解直接定制 JSON 键映射、设置默认值并应用命名策略。

---

## 🌍 Language / 语言

- [English](#english)
- [中文 (Chinese)](#中文-chinese)

---

<a id="english"></a>
## 🇬🇧 English

### Features

* **@DefaultValue**: Provide default values for properties when JSON fields are missing or `null`.
* **@CodingKeyPrefix / @CodingKeySuffix**: Automatically add prefixes or suffixes to mapping keys (supports both Struct level and Property level).
* **@CustomCodingKey**: Map a property to a completely different JSON key.
* **@CamelCase**: Easily handle snake_case to camelCase conversion.
* **Zero Boilerplate**: No need to manually write `CodingKeys` enum or `init(from:)` decoder logic.

### Installation

Add Codify to your project using Swift Package Manager.

```swift
dependencies: [
    .package(url: "[https://github.com/yourname/Codify.git](https://github.com/yourname/Codify.git)", from: "1.0.0")
]
