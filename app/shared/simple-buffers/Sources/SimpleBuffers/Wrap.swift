//
//  NullEncodable.swift
//  simple-buffers
//
//  Created by Corbin Bigler on 3/5/25.
//

@propertyWrapper
public struct Wrap<T>: Codable where T: Codable {
    
    public var wrappedValue: T?

    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(_): try container.encode(wrappedValue)
        case .none: try container.encodeNil()
        }
    }
}
