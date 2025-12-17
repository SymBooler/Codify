# Codify 错误处理规范

- 统一格式：`[CODE] EN: ... | ZH: ... | HINT: ...`
- 语言支持：英文与中文并列，必要时附加 `HINT`
- 错误码范围：`E001`–`E999`，保留 `D***` 作为诊断类信息

## 错误码清单

- E001 CodingKey 必须是字符串字面量
- E002 CodingKey 必须提供非空值
- E003 CodingKey 值不能为空
- E004 使用 `@Codify` 前需移除已有 `CodingKeys`
- E005 `@CustomCodingKey` 只能应用在属性上
- E006 只能应用在结构体上
- E007 只能应用在属性或结构体上
- E008 仅能应用到结构体（宏级别通用）
- E009 `@DefaultValue` 必须提供默认值参数，例如 `@DefaultValue("")`
- E010 使用装饰宏需先添加 `@Codify`
- E099 透传底层错误信息（调试用途）

## 触发位置与修复建议

- 当错误与具体属性相关时，定位到属性上的宏节点；否则定位到声明节点
- 修复建议通过 `HINT` 提供，如“传入非空字符串”“移除已有 CodingKeys”等

## 代码位置

- 统一格式构建：`Sources/CodifyMacros/CodingKeys/CodingKeyMacroDiagnostic.swift`
- 默认值宏诊断：`Sources/CodifyMacros/Macros/DefaultValueMacro.swift`

## 示例

- `[E009] EN: Property 'title' annotated with @DefaultValue requires a default value argument, e.g., @DefaultValue(""). | ZH: 属性 'title' 使用 @DefaultValue 时必须提供默认值，例如 @DefaultValue("")`

