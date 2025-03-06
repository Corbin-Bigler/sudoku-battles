//
//  BattleHandler.swift
//  SwiftNIOTutorial
//
//  Created by Corbin Bigler on 3/2/25.
//

import Foundation
import NIO
import NIOSSL
import SimpleBuffers
import SudokuBattlesData

final class SudokuBattlesHandler: ChannelInboundHandler, Sendable {
    public typealias InboundIn = SudokuBattlesFrame
    public typealias OutboundOut = SudokuBattlesFrame

    func channelActive(context: ChannelHandlerContext) {
        print("Client connected: \(context.remoteAddress?.description ?? "Unknown")")
    }

    func channelInactive(context: ChannelHandlerContext) {
        print("Client disconnected: \(context.remoteAddress?.description ?? "Unknown")")
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = unwrapInboundIn(data)

        print(frame)
        
        let decoder = SimpleBuffersDecoder()
        guard let test = try? decoder.decode(TestServerboundPayload.self, from: frame.payload) else { return }
        
        let response = TestClientboundPayload(message: "Hello, \(test.name)!", randomNumber: Int64.random(in: Int64.min...Int64.max))
        let serializer = SimpleBuffersEncoder()
        let encodedResponse = try! serializer.encode(response)
        let responsePacket = SudokuBattlesFrame(function: .test, payload: encodedResponse)

        context.writeAndFlush(wrapOutboundOut(responsePacket), promise: nil)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        if let nioError = error as? NIOSSLError, nioError == .uncleanShutdown { return }

        print("Error caught in BattleHandler: \(error)")
        context.close(promise: nil)
    }
}
