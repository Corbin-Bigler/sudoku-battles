//
//  TestServerboundPayload.swift
//  SwiftNIOTutorial
//
//  Created by Corbin Bigler on 3/3/25.
//

import SimpleBuffers

public struct TestServerboundPayload: Codable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
