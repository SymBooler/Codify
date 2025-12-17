import Codify
import Foundation

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

