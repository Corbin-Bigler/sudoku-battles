//
//  TestClientboundPayload.swift
//  SwiftNIOTutorial
//
//  Created by Corbin Bigler on 3/3/25.
//

import SimpleBuffers

public struct TestClientboundPayload: Codable {
    public var message: String
    public var randomNumber: Int64
    
    public init(message: String, randomNumber: Int64) {
        self.message = message
        self.randomNumber = randomNumber
    }
}
