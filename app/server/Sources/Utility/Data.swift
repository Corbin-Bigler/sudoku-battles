//
//  Data.swift
//  SwiftNIOTutorial
//
//  Created by Corbin Bigler on 3/2/25.
//

import Foundation

extension Data {
    var hexString: String {
        return self.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    func getInteger<T: FixedWidthInteger>(from index: Int, endianness: Endianness = .little) -> T? {
        guard index >= 0, index + MemoryLayout<T>.size <= self.count else { return nil }
        
        var value: T = 0
        _ = Swift.withUnsafeMutableBytes(of: &value) { valuePtr in
            self.copyBytes(to: valuePtr, from: index..<(index + MemoryLayout<T>.size))
        }
        
        switch endianness {
        case .little:
            return T(littleEndian: value)
        case .big:
            return T(bigEndian: value)
        }
    }
}

enum Endianness {
    case little
    case big
}
