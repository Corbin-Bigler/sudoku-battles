//
//  TestPacket.swift
//  SwiftNIOTutorial
//
//  Created by Corbin Bigler on 3/3/25.
//

import SimpleBuffers

public struct TestServerboundFrame: Codable {
    public let name: String
}
