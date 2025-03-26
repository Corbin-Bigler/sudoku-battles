// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Hardpack

struct Test: Codable {
    let string: String
    let int8: Int8
    let int16: Int16
    let int32: Int32
    let int64: Int64
    let uInt8: UInt8
    let uInt16: UInt16
    let uInt32: UInt32
    let uInt64: UInt64
    let float: Float
    let double: Double
    let bool: Bool
    let uuid: UUID
    let varInt: VarInt
    
    let arrayString: [String]
    let arrayInt8: [Int8]
    let arrayInt16: [Int16]
    let arrayInt32: [Int32]
    let arrayInt64: [Int64]
    let arrayUInt8: [UInt8]
    let arrayUInt16: [UInt16]
    let arrayUInt32: [UInt32]
    let arrayUInt64: [UInt64]
    let arrayFloat: [Float]
    let arrayDouble: [Double]
    let arrayBool: [Bool]
    let arrayUuid: [UUID]
    let arrayVarInt: [VarInt]
    let arrayNested: [Test]

    let dictionaryString: [String : String]
    let dictionaryInt8: [Int8 : Int8]
    let dictionaryInt16: [Int16 : Int16]
    let dictionaryInt32: [Int32 : Int32]
    let dictionaryInt64: [Int64 : Int64]
    let dictionaryUInt8: [UInt8 : UInt8]
    let dictionaryUInt16: [UInt16 : UInt16]
    let dictionaryUInt32: [UInt32 : UInt32]
    let dictionaryUInt64: [UInt64 : UInt64]
    let dictionaryFloat: [Float : Float]
    let dictionaryDouble: [Double : Double]
    let dictionaryBool: [Bool : Bool]
    let dictionaryUuid: [UUID : UUID]
    let dictionaryVarInt: [Int8 : VarInt]
    let dictionaryNested: [Int8 : Test]

    let optionalString: String?
    let optionalInt8: Int8?
    let optionalInt16: Int16?
    let optionalInt32: Int32?
    let optionalInt64: Int64?
    let optionalUInt8: UInt8?
    let optionalUInt16: UInt16?
    let optionalUInt32: UInt32?
    let optionalUInt64: UInt64?
    let optionalFloat: Float?
    let optionalDouble: Double?
    let optionalBool: Bool?
    let optionalUuid: UUID?
    let optionalVarInt: VarInt?

    let dictionaryDictionary: [Int8 : [Int8 : Int8]]
    let dictionaryArray: [Int8 : [Int8]]
    let dictionaryOptional: [Int8 : Int8?]
    
    let arrayArray: [[Int8]]
    let arrayDictionary: [[Int8 : Int8]]
    let arrayOptional: [Int8?]
    
    let optionalArray: [Int8]?
    let optionalDictionary: [Int8 : Int8]?
    let optionalOptional: Int8??
}

let uuid1 = UUID()
let uuid2 = UUID()

let sampleTest = Test(
    string: "Hello",
    int8: 1,
    int16: 2,
    int32: 3,
    int64: 4,
    uInt8: 5,
    uInt16: 6,
    uInt32: 7,
    uInt64: 8,
    float: 9.1,
    double: 10.2,
    bool: true,
    uuid: uuid1,
    varInt: 42,

    arrayString: ["a", "b"],
    arrayInt8: [1, 2],
    arrayInt16: [3, 4],
    arrayInt32: [5, 6],
    arrayInt64: [7, 8],
    arrayUInt8: [9, 10],
    arrayUInt16: [11, 12],
    arrayUInt32: [13, 14],
    arrayUInt64: [15, 16],
    arrayFloat: [1.1, 2.2],
    arrayDouble: [3.3, 4.4],
    arrayBool: [true, false],
    arrayUuid: [uuid1, uuid2],
    arrayVarInt: [100, 200],
    arrayNested: [],

    dictionaryString: ["key": "value"],
    dictionaryInt8: [1: 2],
    dictionaryInt16: [3: 4],
    dictionaryInt32: [5: 6],
    dictionaryInt64: [7: 8],
    dictionaryUInt8: [9: 10],
    dictionaryUInt16: [11: 12],
    dictionaryUInt32: [13: 14],
    dictionaryUInt64: [15: 16],
    dictionaryFloat: [1.1: 2.2],
    dictionaryDouble: [3.3: 4.4],
    dictionaryBool: [true: false],
    dictionaryUuid: [uuid1: uuid2],
    dictionaryVarInt: [1: 300],
    dictionaryNested: [:],

    optionalString: "optional",
    optionalInt8: 1,
    optionalInt16: 2,
    optionalInt32: 3,
    optionalInt64: 4,
    optionalUInt8: 5,
    optionalUInt16: 6,
    optionalUInt32: 7,
    optionalUInt64: 8,
    optionalFloat: 9.9,
    optionalDouble: 10.1,
    optionalBool: true,
    optionalUuid: uuid1,
    optionalVarInt: 999,

    dictionaryDictionary: [1: [2: 3]],
    dictionaryArray: [4: [5, 6]],
    dictionaryOptional: [7: 8],

    arrayArray: [[1, 2], [3, 4]],
    arrayDictionary: [[9: 10], [11: 12]],
    arrayOptional: [13, nil, 14],

    optionalArray: [15, 16],
    optionalDictionary: [17: 18],
    optionalOptional: 19
)

protocol HardpackEncodable: Encodable {
    func encode(hardpack: HEncoder) throws
}
extension HardpackEncodable {
    func encode(hardpack: HEncoder) throws { try self.encode(to: hardpack) }
}

protocol HardpackPrimitive: Encodable {}
extension String: HardpackEncodable {}
extension Int8: HardpackEncodable {}
extension Int16: HardpackEncodable {}
extension Int32: HardpackEncodable {}
extension Int64: HardpackEncodable {}
extension UInt8: HardpackEncodable {}
extension UInt16: HardpackEncodable {}
extension UInt32: HardpackEncodable {}
extension UInt64: HardpackEncodable {}
extension Float: HardpackEncodable {}
extension Double: HardpackEncodable {}
extension Bool: HardpackEncodable {}
extension Data: HardpackEncodable {}
extension UUID: HardpackEncodable {
    func encode(hardpack: HEncoder) throws {
        let bytes = [uuid.0, uuid.1, uuid.2, uuid.3, uuid.4, uuid.5, uuid.6, uuid.7, uuid.8, uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15]
        hardpack.data.append(contentsOf: bytes)
    }
}
extension Date: HardpackEncodable {
    func encode(hardpack: HEncoder) throws {
        let timeInterval = UInt64(timeIntervalSince1970 * 1000)
        try timeInterval.encode(to: hardpack)
    }
}
extension VarInt: HardpackEncodable {
    func encode(hardpack: HEncoder) throws {
        hardpack.data.append(bytes)
    }
}
extension Optional: HardpackEncodable where Wrapped: Encodable {
    func encode(hardpack: HEncoder) throws {
        if let unwrapped = self {
            try unwrapped.encode(to: hardpack)
        } else {
            try false.encode(to: hardpack)
        }
    }
}
extension Array: HardpackEncodable where Element: Encodable {
    
}
extension Dictionary: HardpackEncodable where Key: Encodable, Value: Encodable {
    
}

protocol HardpackOptional: Encodable {
    associatedtype Wrapped: HardpackPrimitive
    var unwrapped: Wrapped? { get }
}
extension Optional: HardpackOptional where Wrapped: HardpackPrimitive {
    var unwrapped: Wrapped? {
        return self
    }
}

protocol HardpackContainer: Encodable {
    var count: Int { get }
}
extension Array: HardpackContainer where Element: Encodable {}
extension Dictionary: HardpackContainer where Key: Encodable, Value: Encodable {}

class HEncoder: Encoder {
    var data = Data()
    var codingPath: [any CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        try value.encode(to: self)
        return data
    }
    
//    private func _encode<T: Encodable>(_ value: T) throws {
//        var singleValueContainer = singleValueContainer()
//        if let wrapped = value as? any HardpackOptional {
//            try singleValueContainer.encode(wrapped)
//        } else if let container = value as? HardpackContainer {
//            try singleValueContainer.encode(VarInt(container.count))
//            try container.encode(to: self)
//        } else if value is HardpackPrimitive {
//            try singleValueContainer.encode(value)
//        } else {
//            try value.encode(to: self)
//        }
//    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(KeyedContainer(encoder: self))
    }
    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        return UnkeyedContainer(encoder: self)
    }
    func singleValueContainer() -> any SingleValueEncodingContainer {
        return SingleValueContainer(encoder: self)
    }
        
    private struct SingleValueContainer: SingleValueEncodingContainer {
        var encoder: HEncoder
        var codingPath: [any CodingKey] { encoder.codingPath }
        
        mutating func encodeNil() throws {
            try encode(false)
        }
        mutating func encode(_ value: Bool) throws {
            encoder.data.append(value ? 0x01 : 0x00)
        }
        mutating func encode(_ value: String) throws {
            let utf8Data = Data(value.utf8)
            try encode(VarInt(UInt(utf8Data.count)))
            encoder.data.append(utf8Data)
        }
        mutating func encode(_ value: Float) throws {
            var littleEndianValue = value.bitPattern.littleEndian
            withUnsafeBytes(of: &littleEndianValue) { encoder.data.append(contentsOf: $0) }
        }
        mutating func encode(_ value: Double) throws {
            var littleEndianValue = value.bitPattern.littleEndian
            withUnsafeBytes(of: &littleEndianValue) { encoder.data.append(contentsOf: $0) }
        }
//        mutating func encode(_ value: VarInt) throws {
//            encoder.data.append(value.bytes)
//        }
//        mutating func encode(_ uuid: UUID) throws {
//            let uuid = uuid.uuid
//            let bytes = [uuid.0, uuid.1, uuid.2, uuid.3, uuid.4, uuid.5, uuid.6, uuid.7, uuid.8, uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15]
//            encoder.data.append(contentsOf: bytes)
//        }
//        mutating func encode(_ date: Date) throws {
//            let timeInterval = UInt64(date.timeIntervalSince1970 * 1000)
//            try encode(fixed: timeInterval)
//        }
        mutating func encode<T: FixedWidthInteger>(fixed: T) throws {
            if T.self is Int.Type || T.self is UInt.Type {
                throw encoder.unsupported(value: fixed)
            }
            
            var littleEndianValue = fixed.littleEndian
            withUnsafeBytes(of: &littleEndianValue) { encoder.data.append(contentsOf: $0) }
        }
        mutating func encode(_ value: UInt64) throws {
            try encode(fixed: value)
        }
        mutating func encode(_ value: UInt32) throws {
            try encode(fixed: value)
        }
        mutating func encode(_ value: UInt16) throws {
            try encode(fixed: value)
        }
        mutating func encode(_ value: UInt8) throws {
            try encode(fixed: value)
        }
        mutating func encode(_ value: Int64) throws {
            try encode(fixed: value)
        }
        mutating func encode(_ value: Int32) throws {
            try encode(fixed: value)
        }
        mutating func encode(_ value: Int16) throws {
            try encode(fixed: value)
        }
        mutating func encode(_ value: Int8) throws {
            try encode(fixed: value)
        }
        mutating func encode(_ value: UInt) throws {
            throw encoder.unsupported(value: value)
        }
        mutating func encode(_ value: Int) throws {
            throw encoder.unsupported(value: value)
        }
        mutating func encode(_ value: any HardpackOptional) throws {
            if let unwrapped = value.unwrapped {
                try encode(true)
                try encode(unwrapped)
            } else {
                try encode(false)
            }
        }
        
        mutating func encode<T>(_ value: T) throws where T : Encodable {
            if let encodable = value as? any HardpackEncodable {
                try encodable.encode(hardpack: encoder)
            }
            throw encoder.unsupported(value: value)
//            switch value {
//            case let wrapped as any HardpackOptional: try encode(wrapped)
//            case let varInt as VarInt: try encode(varInt)
//            case let uuid as UUID: try encode(uuid)
//            case let date as Date: try encode(date)
//            case let primitive as HardpackPrimitive: try primitive.encode(to: encoder)
//            default: throw encoder.unsupported(value: value)
//            }
        }
    }
    
    private struct UnkeyedContainer: UnkeyedEncodingContainer {
        var encoder: HEncoder
        var codingPath: [any CodingKey] { encoder.codingPath }
        var count: Int = 0
        
        mutating func encodeNil() throws {
            try false.encode(to: encoder)
        }
        mutating func encode<T: Encodable>(_ value: T) throws {
//            try encoder._encode(value)
            try value.encode(to: encoder)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return encoder.container(keyedBy: keyType)
        }
        mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
            return encoder.unkeyedContainer()
        }
        mutating func superEncoder() -> any Encoder {
            return encoder
        }
    }
    
    private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        var encoder: HEncoder
        var codingPath: [any CodingKey] { encoder.codingPath }

        mutating func encodeNil(forKey key: Key) throws {
            try false.encode(to: superEncoder(with: key))
        }
        mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            let encoder = encoder(forKey: key)
            try key.stringValue.encode(to: encoder)
            try value.encode(to: encoder)

//            try encoder._encode(key.stringValue)
//            try encoder._encode(value)
        }

        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return encoder(with: key).container(keyedBy: keyType)
        }
        
        mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
            return encoder(with: key).unkeyedContainer()
        }
        
        private func encoder(forKey key: Key) -> HEncoder {
            encoder.codingPath = [key]
            return encoder
        }
        mutating func superEncoder(forKey key: Key) -> any Encoder { encoder(forKey: key) }
        
        private func encoder(with key: Key) -> HEncoder {
            encoder.codingPath = [key]
            return encoder
        }
        mutating func superEncoder(with key: Key) -> any Encoder { encoder(with: key) }

        mutating func superEncoder() -> any Encoder {
            encoder
        }
    }
    
    private func unsupported(value: Any) -> EncodingError {
        EncodingError.invalidValue(
           value,
           EncodingError.Context(
               codingPath: codingPath,
               debugDescription: "Unsupported value of type \(type(of: value))"
           )
       )
    }
}

//let encoded = try! HEncoder().encode([Optional<Int8>]([123, nil, nil, 12]))
let hardpackEncoded = try! HEncoder().encode(sampleTest)
let hardpackStart = Date()
for _ in 0..<10000 {
    _ = try! HEncoder().encode(sampleTest)
}
print("hardpackEncoded", hardpackEncoded)
print("hardpackTime", Date().timeIntervalSince(hardpackStart))

let jsonEncoded = try! JSONEncoder().encode(sampleTest)
let jsonStart = Date()
for _ in 0..<10000 {
    _ = try! JSONEncoder().encode(sampleTest)
}
print("jsonEncoded", jsonEncoded)
print("jsonTime", Date().timeIntervalSince(jsonStart))

//import Piste
//import SudokuBattlesData
//
//let certPath = Bundle.module.path(forResource: "cert", ofType: "pem")!
//let keyPath = Bundle.module.path(forResource: "server", ofType: "key")!
//let server = try PisteServer(host: "0.0.0.0", port: 8080, cert: certPath, key: keyPath)
//let mongoDs = try await MongoDs()
//
//server.register(handler: CreateUserHandler(userRepo: mongoDs))
//
//try server.run()
