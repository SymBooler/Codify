import XCTest
import Codify

final class LosslessValueTests: XCTestCase {
    
    struct Response: Codable {
        @LosslessValue
        var title: String
    }
    
    func decode<T: Decodable>(_ json: String, as type: T.Type = T.self) throws -> T {
        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func encode<T: Encodable>(_ value: T) throws -> String {
        let data = try JSONEncoder().encode(value)
        return String(data: data, encoding: .utf8)!
    }
    
    func testStringPassThrough() throws {
        let r: Response = try decode(#"{ "title": "hello" }"#)
        XCTAssertEqual(r.title, "hello")
        let s = try encode(r)
        XCTAssertTrue(s.contains(#""title":"hello""#))
    }
    
    func testBoolToString() throws {
        let r: Response = try decode(#"{ "title": true }"#)
        XCTAssertEqual(r.title, "true")
    }
    
    func testInt8ToString() throws {
        let r: Response = try decode(#"{ "title": 7 }"#)
        XCTAssertEqual(r.title, "7")
    }
    
    func testUnsupportedTypeDecodingFailure() {
        XCTAssertThrowsError(try decode(#"{ "title": 3.14 }"#, as: Response.self)) { error in
            guard case DecodingError.typeMismatch = error else {
                XCTFail("Expected typeMismatch, got \(error)")
                return
            }
        }
    }
    
    func testNullDecodingFailure() {
        XCTAssertThrowsError(try decode(#"{ "title": null }"#, as: Response.self)) { _ in }
    }
    
    func testReflectionAccessWrapperType() throws {
        let r: Response = try decode(#"{ "title": 1 }"#)
        XCTAssertEqual(r.title, "1")
        let info = losslessWrapperInfo(r, for: "title")
        XCTAssertNotNil(info)
        XCTAssertEqual(String(describing: info!.wrapperType), String(describing: LosslessValue<String>.self))
        XCTAssertEqual(info!.wrappedValue as? String, "1")
    }
}

