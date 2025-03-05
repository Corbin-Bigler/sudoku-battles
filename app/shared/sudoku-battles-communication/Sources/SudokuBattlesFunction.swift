//
//  AppboundFunction.swift
//  SwiftNIOTutorial
//
//  Created by Corbin Bigler on 3/3/25.
//

public enum SudokuBattlesFunction: UInt16, Codable {
    case test = 0x0001
    
    var serverbound: Decodable.Type {
        switch self {
        case .test: TestServerboundFrame.self
        }
    }
    var clientbound: Decodable.Type {
        switch self {
        case .test: TestClientboundFrame.self
        }
    }
}
