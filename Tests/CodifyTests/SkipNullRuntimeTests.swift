import XCTest
import Codify

final class SkipNullRuntimeTests: XCTestCase {
    
    @Codify
    struct User: Codable {
        @SkipNull
        let nickname: String?
        
        let age: Int
        
        init(nickname: String?, age: Int) {
            self.nickname = nickname
            self.age = age
        }
    }
    
    func testEncodeOmitsNilOptional() throws {
        let u = User(nickname: nil, age: 10)
        let data = try JSONEncoder().encode(u)
        let s = String(data: data, encoding: .utf8)!
        XCTAssertTrue(s.contains(#""age":10"#))
        XCTAssertFalse(s.contains(#""nickname""#))
    }
    
    func testEncodeIncludesNonNilOptional() throws {
        let u = User(nickname: "neo", age: 18)
        let s = String(data: try JSONEncoder().encode(u), encoding: .utf8)!
        XCTAssertTrue(s.contains(#""nickname":"neo""#))
    }
    
    @Codify
    struct Bag: Codable {
        @SkipNull
        let tags: [String]?
        
        init(tags: [String]?) {
            self.tags = tags
        }
    }
    
    func testArrayNilOmitted() throws {
        let b = Bag(tags: nil)
        let s = String(data: try JSONEncoder().encode(b), encoding: .utf8)!
        XCTAssertFalse(s.contains(#""tags""#))
    }
    
    @Codify
    struct Profile: Codable {
        @LosslessValue
        var title: String
        
        @SkipNull
        let note: String?
        
        init(title: String, note: String?) {
            self.title = title
            self.note = note
        }
    }
    
    func testCombinedWithLosslessValue() throws {
        let p = Profile(title: "x", note: nil)
        let s = String(data: try JSONEncoder().encode(p), encoding: .utf8)!
        XCTAssertTrue(s.contains(#""title":"x""#))
        XCTAssertFalse(s.contains(#""note""#))
    }
}
