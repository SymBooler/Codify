import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main

struct CodifyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CodifyMacro.self,
        DefaultValueMacro.self,
        CustomCodingKeyMacro.self,
        CodingKeyPrefixMacro.self,
        CodingKeySuffixMacro.self,
        SnakeCaseMacro.self,
        CamelCaseMacro.self,
        FlatCaseMacro.self,
        PascalCaseMacro.self,
        UpperCaseMacro.self,
        SnakeCaseMacro.self,
        CamelSnakeCaseMacro.self,
        PascalSnakeCaseMacro.self,
        ScreamingSnakeCaseMacro.self,
        KebabCaseMacro.self,
        CamelKebabCaseMacro.self,
        PascalKebabCaseMacro.self,
        ScreamingKebabCaseMacro.self,
    ]
}
