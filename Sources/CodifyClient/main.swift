import Codify
import Foundation

//@CodingKeyPrefix("prefix1_")
//@CodingKeySuffix("_suffix1")
@Codify
public struct Cat: Codable {
    @CodingKeyPrefix("prefix_")
    @CodingKeySuffix("_suffix")
    @CustomCodingKey("custom_id")
    let id: Int

    @DefaultValue("title")
    @Lossless
    var title: String

    @DefaultValue(1)
    @CodingKeyPrefix("prefix_")
    @CodingKeySuffix("_suffix")
    var count: Int? = 2
    
    let description: Optional<String>
    let name: String?
    
    @CamelCase
    let cat_name: String
    @SkipNull
    let children: [String: String]
    @SkipNull
    let friends: Set<Int>?
}

// 响应结构体
@Codify
struct Response: Codable {
//    let values: [String: String]  // 非 Optional 值字典，过滤 null 键值对
    @Lossless
//    @LosslessValue
    var title: String
    
    // 自定义解码
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.Container.self, forKey: .title).losslessValue
    }
}

// 测试代码
let json = #"{ "custom_id": 0, "catName": "name", "title": 1, "friends": [1, 2, null, 4, 5, null], "children": {"a": "A", "b": "B", "c": null } }"#.data(using: .utf8)!
//let json = #"{ "title": 1 }"#.data(using: .utf8)!
do {
    let result = try JSONDecoder().decode(Cat.self, from: json)
    print(result)  // 输出: ["a": "A", "b": "B"]
    let encodeResult = String(data: try JSONEncoder().encode(result), encoding: .utf8)!
    print(encodeResult)
} catch {
    print("解码失败: \(error)")
}


