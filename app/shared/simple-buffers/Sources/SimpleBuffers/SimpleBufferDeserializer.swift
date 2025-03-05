//
//  SimpleBufferDeserializer.swift
//  SwiftNIOTutorial
//
//  Created by Corbin Bigler on 3/3/25.
//

import Foundation

public class SimpleBufferDeserializer: Decoder {
    var data: Data!
    var offset: Int!
    
    public var codingPath: [any CodingKey] = []
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    
    public init() {}
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        self.data = data
        self.offset = 0

        return try T.init(from: self)
    }

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        .init(KeyedContainer(deserializer: self))
    }
    public func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        return UnkeyedContainer(deserializer: self)
    }
    public func singleValueContainer() throws -> any SingleValueDecodingContainer {
        return SingleValueContainer(deserializer: self)
    }

    struct SingleValueContainer: SingleValueDecodingContainer {
        private let deserializer: SimpleBufferDeserializer
        
        var data: Data { deserializer.data }
        var offset: Int { deserializer.offset }

        var codingPath: [CodingKey] { return deserializer.codingPath }
        var unexpectedEndOfData: DecodingError { DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Unexpected end of data")) }
        
        init(deserializer: SimpleBufferDeserializer) {
            self.deserializer = deserializer
        }
        
        func decodeNil() -> Bool { fatalError("Optional types not supported") }
        func decodeInteger<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
            let size = MemoryLayout<T>.size
            guard offset + size <= data.count else { throw unexpectedEndOfData }
            let value = data.subdata(in: offset..<(offset + size)).withUnsafeBytes { $0.loadUnaligned(as: T.self) }
            deserializer.offset += size
            return T(littleEndian: value)
        }
        func decodeFloat() throws -> Float {
            return Float(bitPattern: try decodeInteger(UInt32.self))
        }
        
        func decodeDouble() throws -> Double {
            return Double(bitPattern: try decodeInteger(UInt64.self))
        }
        func decodeString() throws -> String {
            let varLength = try decodeVarInt()
            let length = Int(varLength.value)
            guard offset + length <= data.count else { throw unexpectedEndOfData }
            let stringData = data.subdata(in: offset..<offset + length)
            deserializer.offset += length
            guard let string = String(data: stringData, encoding: .utf8) else {
                throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Invalid UTF-8 string"))
            }
            return string
        }
        func decodeVarInt() throws -> VarInt {
            var result: UInt64 = 0
            var shift: UInt64 = 0
            var bytesRead = 0
            
            while offset < data.count {
                let byte = data[offset]
                deserializer.offset += 1
                bytesRead += 1
                
                let value = UInt64(byte & 0x7F)
                result |= value << shift
                shift += 7
                
                if byte & 0x80 == 0 { return VarInt(result) }
                
                if bytesRead >= 10 {
                    throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "VarInt too long"))
                }
            }
            
            throw unexpectedEndOfData
        }
        func decodeUUID() throws -> UUID {
            guard offset + 16 <= data.count else {
                throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Unexpected end of data for UUID"))
            }
            let bytes = Array(data[offset..<offset+16])
            deserializer.offset += 16
            return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
        }
        func decodeDate() throws -> Date {
            let timeInterval = try decodeInteger(UInt64.self)
            return Date(timeIntervalSince1970: TimeInterval(timeInterval) / 1000)
        }
        func decodeBool() throws -> Bool {
            return try decodeInteger(UInt8.self) != 0
        }

        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            switch type {
            case is Float.Type: return try decodeFloat() as! T
            case is Double.Type: return try decodeDouble() as! T
            case is String.Type: return try decodeString() as! T
            case is Date.Type: return try decodeDate() as! T
            case is Bool.Type: return try decodeBool() as! T
            case is UUID.Type: return try decodeUUID() as! T
            case is VarInt.Type: return try decodeVarInt() as! T
            case is Int8.Type: return try decodeInteger(Int8.self) as! T
            case is Int16.Type: return try decodeInteger(Int16.self) as! T
            case is Int32.Type: return try decodeInteger(Int32.self) as! T
            case is Int64.Type: return try decodeInteger(Int64.self) as! T
            case is UInt8.Type: return try decodeInteger(UInt8.self) as! T
            case is UInt16.Type: return try decodeInteger(UInt16.self) as! T
            case is UInt32.Type: return try decodeInteger(UInt32.self) as! T
            case is UInt64.Type: return try decodeInteger(UInt64.self) as! T
            default:
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Unsupported value of type \(type)"))
            }
        }
    }
    
    struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        private let deserializer: SimpleBufferDeserializer
        var codingPath: [CodingKey] { return deserializer.codingPath }
        var allKeys: [Key] = []

        init(deserializer: SimpleBufferDeserializer) { self.deserializer = deserializer }

        private func deserializer(with key: CodingKey) -> SimpleBufferDeserializer {
            deserializer.codingPath += [key]
            return deserializer
        }

        func contains(_ key: Key) -> Bool { return true }
        func decodeNil(forKey key: Key) throws -> Bool { fatalError("Optional types not supported") }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            try deserializer(with: key).container(keyedBy: type)
        }
        func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer { try deserializer(with: key).unkeyedContainer() }
        func superDecoder() throws -> any Decoder { deserializer }
        func superDecoder(forKey key: Key) throws -> any Decoder { deserializer(with: key) }

        func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
            return try T.init(from: deserializer(with: key))
        }
    }
    
    struct UnkeyedContainer: UnkeyedDecodingContainer {
        private let deserializer: SimpleBufferDeserializer
        var codingPath: [CodingKey] { return deserializer.codingPath }
        var count: Int?
        var isAtEnd: Bool = false
        var currentIndex: Int = 0
        
        init(deserializer: SimpleBufferDeserializer) {
            let varCount = try! (try! deserializer.singleValueContainer() as! SingleValueContainer).decodeVarInt()
            count = Int(varCount.value)
            self.deserializer = deserializer
        }
        
        mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
            currentIndex += 1
            isAtEnd = currentIndex == count!
            return try T.init(from: deserializer)
        }
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            try deserializer.container(keyedBy: type)
        }
        func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
            try deserializer.unkeyedContainer()
        }
        func superDecoder() throws -> any Decoder { deserializer }
        func decodeNil() -> Bool { fatalError() }
    }

}
