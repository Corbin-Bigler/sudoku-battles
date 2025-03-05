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
import SudokuBattlesCommunication

final class BattleHandler: ChannelInboundHandler, Sendable {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    
    func channelActive(context: ChannelHandlerContext) {
        print("Client connected: \(context.remoteAddress?.description ?? "Unknown")")
    }

    func channelInactive(context: ChannelHandlerContext) {
        print("Client disconnected: \(context.remoteAddress?.description ?? "Unknown")")
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = unwrapInboundIn(data)
        guard let data = buffer.data else { return }
        
        let deserializer = SimpleBufferDeserializer()
        guard let frame = try? deserializer.decode(SudokuBattlesFrame.self, from: data),
              let test = try? deserializer.decode(TestServerboundFrame.self, from: frame.payload)
        else { return }
        
        print(data.hexString)
        print(frame.payload.hexString)
        print(test)
        
        let response = TestClientboundFrame(message: "Hello, \(test.name)!", randomNumber: Int64.random(in: Int64.min...Int64.max))
        let serializer = SimpleBufferSerializer()
        let encodedResponse = try! serializer.encode(response)
        let responsePacket = SudokuBattlesFrame(function: .test, payload: encodedResponse)
        let encodedPacket = try! serializer.encode(responsePacket)
        
        context.writeAndFlush(wrapOutboundOut(ByteBuffer(bytes: encodedPacket)), promise: nil)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        if let nioError = error as? NIOSSLError, nioError == .uncleanShutdown { return }

        print("Error caught in BattleHandler: \(error)")
        context.close(promise: nil)
    }
}
