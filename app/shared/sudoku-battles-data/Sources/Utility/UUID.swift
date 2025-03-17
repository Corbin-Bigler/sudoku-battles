//
//  UUID.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/16/25.
//

import Foundation
import MongoKitten

extension UUID: @retroactive PrimitiveEncodable {
    public func encodePrimitive() -> Primitive {
        let uuidBytes = withUnsafeBytes(of: uuid) { Data($0) }
        return Binary(subType: .uuid, buffer: ByteBuffer(bytes: uuidBytes))
    }

    public static func decodePrimitive(from primitive: Primitive) throws -> UUID {
           guard let binary = primitive as? Binary, binary.data.count == 16 else {
               throw DecodingError.typeMismatch(UUID.self, DecodingError.Context(
                   codingPath: [],
                   debugDescription: "Invalid UUID format"
               ))
           }
           
           let uuid = binary.data.withUnsafeBytes { rawPtr in
               rawPtr.load(as: uuid_t.self)
           }
           
           return UUID(uuid: uuid)
       }
   }
