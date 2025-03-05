//
//  SimpleBufferSerializer.swift
//  SwiftNIOTutorial
//
//  Created by Corbin Bigler on 3/3/25.
//

import Foundation

public class SimpleBufferSerializer: Encoder {
    private var data = Data()
    private var array: [Data] = []

    public var codingPath: [any CodingKey] = []
    public var userInfo: [CodingUserInfoKey: Any] = [:]
    
    public init() {}

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        data = Data()
        array = []
        try value.encode(to: self)
        encodeArray()
        return data
    }

    private func encodeArray() {
        if !array.isEmpty {
            let container = SingleValueContainer(serializer: self)
            container.encodeVarInt(VarInt(UInt(array.count)))
            for element in array {
                data.append(contentsOf: element)
            }
            array = []
        }
    }

    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        encodeArray()
        return .init(KeyedContainer(serializer: self))
    }
    public func unkeyedContainer() -> any UnkeyedEncodingContainer {
        encodeArray()
        return UnkeyedContainer(serializer: self)
    }
    public func singleValueContainer() -> any SingleValueEncodingContainer {
        encodeArray()
        return SingleValueContainer(serializer: self)
    }

    fileprivate struct SingleValueContainer: SingleValueEncodingContainer {
        let serializer: SimpleBufferSerializer
        var codingPath: [any CodingKey] { serializer.codingPath }

        func encodeNil() throws { fatalError("Optional types not supported") }

        func encodeBool(_ value: Bool) {
            serializer.data.append(value ? 0x01 : 0x00)
        }
        func encodeInteger<T: FixedWidthInteger>(_ value: T) {
            var littleEndianValue = value.littleEndian
            withUnsafeBytes(of: &littleEndianValue) { serializer.data.append(contentsOf: $0) }
        }
        func encodeFloat(_ value: Float) {
            var littleEndianValue = value.bitPattern.littleEndian
            withUnsafeBytes(of: &littleEndianValue) { serializer.data.append(contentsOf: $0) }
        }
        func encodeDouble(_ value: Double) {
            var littleEndianValue = value.bitPattern.littleEndian
            withUnsafeBytes(of: &littleEndianValue) { serializer.data.append(contentsOf: $0) }
        }
        func encodeString(_ string: String) {
            let utf8Data = Data(string.utf8)
            encodeVarInt(VarInt(UInt(utf8Data.count)))
            serializer.data.append(utf8Data)
        }
        func encodeUUID(_ uuid: UUID) {
            let uuid = uuid.uuid
            let bytes = [uuid.0, uuid.1, uuid.2, uuid.3, uuid.4, uuid.5, uuid.6, uuid.7, uuid.8, uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15]
            serializer.data.append(contentsOf: bytes)
        }
        func encodeVarInt(_ value: VarInt) {
            serializer.data.append(value.bytes)
        }
        func encodeDate(_ value: Date) {
            let timeInterval = UInt64(value.timeIntervalSince1970 * 1000)
            encodeInteger(timeInterval)
        }

        func encode<T: Encodable>(_ value: T) throws {
            if let bool = value as? Bool { encodeBool(bool) }
            else if let integer = value as? any FixedWidthInteger { encodeInteger(integer) }
            else if let varInt = value as? VarInt { encodeVarInt(varInt) }
            else if let float = value as? Float { encodeFloat(float) }
            else if let double = value as? Double { encodeDouble(double) }
            else if let string = value as? String { encodeString(string) }
            else if let uuid = value as? UUID { encodeUUID(uuid) }
            else if let date = value as? Date { encodeDate(date) }
            else if let data = value as? Data { try data.encode(to: serializer) }
            else {
                throw EncodingError.invalidValue(
                    value,
                    EncodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Unsupported value of type \(type(of: value))"
                    )
                )
            }
        }
    }
    
    struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        let serializer: SimpleBufferSerializer
        var codingPath: [CodingKey] { return serializer.codingPath }

        private func serializer(with key: CodingKey) -> SimpleBufferSerializer {
            serializer.codingPath += [key]
            return serializer
        }
        
        func encodeNil(forKey key: Key) throws { fatalError("Optional types not supported") }
        func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            print(key)
            try value.encode(to: serializer(with: key))
        }
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
            serializer(with: key).container(keyedBy: type)
        }
        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            serializer(with: key).unkeyedContainer()
        }
        func superEncoder() -> Encoder { return serializer }
        func superEncoder(forKey key: Key) -> Encoder { serializer(with: key) }
    }
    
    struct UnkeyedContainer: UnkeyedEncodingContainer {
        let serializer: SimpleBufferSerializer
        var codingPath: [CodingKey] { return serializer.codingPath }
        var count: Int = 0
        
        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            serializer.container(keyedBy: keyType)
        }
        func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer { serializer.unkeyedContainer() }
        func superEncoder() -> any Encoder { serializer }
        func encodeNil() throws {
            fatalError("Optional types not supported")
        }
        func encode<T: Encodable>(_ value: T) throws {
            let serializer = SimpleBufferSerializer()
            self.serializer.array.append(try serializer.encode(value))
        }
    }
}

extension Optional where Wrapped : Encodable {
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .none: try container.encodeNil()
        case .some(let wrapped): try container.encode(wrapped)
        }
    }
}
