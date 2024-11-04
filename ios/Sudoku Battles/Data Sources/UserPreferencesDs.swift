//
//  UserPreferencesDs.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 11/2/24.
//
import SwiftUI

class UserPreferencesDs {
    static let shared = UserPreferencesDs()
    
    let userDefaults = UserDefaults.standard
    let savedGameKey = "solo_game_key"
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    func save(sudokuBoard: SudokuBoardModel) {
        let encoded = try? jsonEncoder.encode(sudokuBoard)
        userDefaults.set(encoded, forKey: savedGameKey)
    }
    func getSudokuBoard() -> SudokuBoardModel? {
        if let boardModel = userDefaults.string(forKey: savedGameKey)?.data(using: .utf8) {
            return try? jsonDecoder.decode(SudokuBoardModel.self, from: boardModel)
        }
        return nil
    }
}
