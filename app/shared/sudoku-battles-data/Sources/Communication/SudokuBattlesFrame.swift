//
//  SimpleBuffer.swift
//  sudoku-battles-communication
//
//  Created by Corbin Bigler on 3/4/25.
//

import Foundation
import SimpleBuffers

public struct SudokuBattlesFrame: Codable {
    public let function: SudokuBattlesFunction
    public let payload: Data
    
    public init(function: SudokuBattlesFunction, payload: Data) {
        self.function = function
        self.payload = payload
    }
}
