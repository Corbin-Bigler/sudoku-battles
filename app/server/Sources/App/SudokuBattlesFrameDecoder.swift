//
//  SudokuBattlesFrameDecoder.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/5/25.
//

import NIO
import SimpleBuffers
import SudokuBattlesData
import Foundation

final class SudokuBattlesFrameDecoder: ByteToMessageDecoder, Sendable {
    typealias InboundOut = SudokuBattlesFrame
    
    func decode(context: NIOCore.ChannelHandlerContext, buffer: inout NIOCore.ByteBuffer) throws -> NIOCore.DecodingState {
        let decoder = SimpleBuffersDecoder()

        guard let data = buffer.getBytes(at: buffer.readerIndex, length: buffer.readableBytes) else {
            return .needMoreData
        }
        
        guard let encoded = try? decoder.decode(SudokuBattlesFrame.self, from: Data(data)) else {
            return .needMoreData
        }

        buffer.moveReaderIndex(forwardBy: data.count)

        context.fireChannelRead(wrapInboundOut(encoded))
        return .continue
    }
}
