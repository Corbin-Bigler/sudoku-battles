//
//  SudokuBattlesFrameEncoder.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/5/25.
//

import NIO
import SimpleBuffers
import SudokuBattlesData

final class SudokuBattlesFrameEncoder: MessageToByteEncoder, Sendable {
    public typealias OutboundIn = SudokuBattlesFrame
    public typealias OutboundOut = ByteBuffer


    func encode(data: SudokuBattlesFrame, out: inout ByteBuffer) throws {
        let encoder = SimpleBuffersEncoder()
        
        let encodedData = try encoder.encode(data)
        out.writeBytes(encodedData)
    }
}
