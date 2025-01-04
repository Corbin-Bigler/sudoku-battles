//
//  GamesState.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 11/11/24.
//

import Foundation

class GamesState: ObservableObject {
    static let shared = GamesState()
    
    @Published var games: [SoloGame] = []
}
