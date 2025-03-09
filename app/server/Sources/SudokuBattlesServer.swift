//
//  SudokuBattlesServer.swift
//  server
//
//  Created by Corbin Bigler on 3/9/25.
//

import Foundation
import NIO
import NIOSSL

final class SudokuBattlesServer: Sendable {
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private let host: String
    private let port: Int
    private let sslContext: NIOSSLContext

    private init(host: String, port: Int) throws {
        self.host = host
        self.port = port
        
        let certPath = Bundle.module.path(forResource: "cert", ofType: "pem")!
        let keyPath = Bundle.module.path(forResource: "server", ofType: "key")!
        
        let cert = try NIOSSLCertificate.fromPEMFile(certPath).map { NIOSSLCertificateSource.certificate($0) }
        let key = try NIOSSLPrivateKey(file: keyPath, format: .pem)
        let tlsConfig = TLSConfiguration.makeServerConfiguration(
            certificateChain: cert,
            privateKey: .privateKey(key)
        )
        
        self.sslContext = try NIOSSLContext(configuration: tlsConfig)
    }

    private var serverBootstrap: ServerBootstrap {
        return ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.addHandler(NIOSSLServerHandler(context: self.sslContext)).flatMap {
                    channel.pipeline.addHandler(BackPressureHandler())//.flatMap {
//                        channel.pipeline.addHandlers([
//                            ByteToMessageHandler(SudokuBattlesFrameDecoder()),
//                            MessageToByteHandler(SudokuBattlesFrameEncoder()),
//                            SudokuBattlesHandler(),
//                        ])
//                    }
                }
            }
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
    }

    func run() throws {
        defer { shutdown() }
        do {
            let channel = try serverBootstrap.bind(host: host, port: port).wait()
            print("\(channel.localAddress!) is now open")
            try channel.closeFuture.wait()
        } catch let error {
            throw error
        }
    }

    func shutdown() {
        do {
            try group.syncShutdownGracefully()
        } catch let error {
            print("Could not shutdown gracefully - forcing exit (\(error.localizedDescription))")
            exit(0)
        }
        print("Server closed")
    }
}
