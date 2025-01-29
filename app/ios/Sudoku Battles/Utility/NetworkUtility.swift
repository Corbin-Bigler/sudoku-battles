//
//  NetworkUtility.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/29/24.
//
import Foundation
import Network

class NetworkUtility: ObservableObject {
    static let shared = NetworkUtility()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    @Published var isConnected: Bool = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
