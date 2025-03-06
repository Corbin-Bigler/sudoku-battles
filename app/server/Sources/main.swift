//
//  main.swift
//  SwiftNIOTutorial
//
//  Created by Corbin Bigler on 3/2/25.
//

import Foundation
import SimpleBuffers
import SudokuBattlesData
import NIO

let server = try SudokuBattlesServer(host: "0.0.0.0", port: 8080)
try server.run()
