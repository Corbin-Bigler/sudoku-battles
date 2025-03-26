//
//  ContentView.swift
//  SudokuBattles
//
//  Created by Corbin Bigler on 3/5/25.
//

import SwiftUI
import Hardpack
import Piste
import SudokuBattlesData

struct ContentView: View {
    @State private var isConnected = false
    let client = try! PisteClient(host: "127.0.0.1", port: 8080)

    func connect() {
        Task {
            do {
                try await client.run()
                send()
                DispatchQueue.main.async {
                    isConnected = true
                }
            } catch {
                print("Client error: \(error)")
            }
        }
    }
    
    func disconnect() {
        client.shutdown()
        isConnected = false
    }
    
    func send() {
        let encoder = HardpackEncoder()
        guard let deviceId = UIDevice.current.identifierForVendor else { return }
        let encoded = try! encoder.encode(UserCreateService.ServerBound(id: deviceId))
        client.send(frame: EncodedPisteFrame(function: UserCreateService.function, version: VarInt(UserCreateService.version), payload: encoded))
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            if !isConnected {
                Button(action: connect) {
                    Text("Connect")
                }
            } else {
                Button(action: send) {
                    Text("Send")
                }
                Button(action: disconnect) {
                    Text("Disconnect")
                }
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
