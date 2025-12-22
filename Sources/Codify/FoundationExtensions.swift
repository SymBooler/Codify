//
//  File.swift
//  Codify
//
//  Created by zhangguanglu.ray on 2025/12/18.
//

import Foundation
// 必须放在Codify 文件夹下，否则会找不到这个方法
public extension Array where Element: Hashable {
    func asSet() -> Set<Element> { Set(self) }
}

public protocol LosslessDecoding: Encodable {
    associatedtype Container: LosslessDecodingContainer where Container.Value == Self, Container: Codable
}

public protocol LosslessDecodingContainer: Codable {
    associatedtype Value
    
    var losslessValue: Value { get }
}

extension LosslessDecoding where Self == String {
    public typealias Container = LosslessStringDecodeContainer
}

extension String: LosslessDecoding {
//    `public typealias Container = StringLosslessDecodeContainer2` 可以覆盖默认实现
}

public struct LosslessStringDecodeContainer: LosslessDecodingContainer {
    public var losslessValue: String
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodeValue = Self.decode(
            container,
            types: String.self,
            Bool.self,
            Int8.self,
            UInt8.self,
            Int16.self,
            UInt16.self,
            Int32.self,
            UInt32.self,
            Int.self,
            UInt.self,
            Int64.self,
            UInt64.self
        )
        if let value = decodeValue {
            losslessValue = value
        } else if #available(macOS 15.0, *), let value = try? container.decode(Int128.self) {
            losslessValue = .init(value)
        } else {
            throw DecodingError.typeMismatch(Self.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected String or Int"))
        }
    }
    
    
    enum CodingKeys: CodingKey {
        case losslessValue
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.losslessValue)
    }
    
    static func decode(
        _ container: any SingleValueDecodingContainer,
        types: (LosslessStringConvertible & Decodable).Type...
    ) -> String? {
        for item in types {
            if let value = try? container.decode(item) {
                return .init(value)
            }
        }
        return nil
    }
}

@propertyWrapper
public struct LosslessValue<Value: LosslessDecoding>: Codable {
    public  var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public enum CodingKeys: String, CodingKey {
        case wrappedValue = "wrappedValue"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try container.decode(Value.Container.self).losslessValue
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    }
}
