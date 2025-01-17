//
//  GamesState.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/14/25.
//
import Foundation

class GamesState: ObservableObject {
    static let shared = GamesState()
    
    @Published var games: [Challenge] = []
}
