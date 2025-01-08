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
    let darkModeKey = "dark_mode_key"

    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    func save(game: SoloGame, difficulty: Difficulty) {
        let encoded = try? jsonEncoder.encode(game)
        userDefaults.set(encoded, forKey: savedGameKey + "_\(difficulty.title)")
    }
    func deleteGame(difficulty: Difficulty) {
        userDefaults.removeObject(forKey: savedGameKey + "_\(difficulty.title)")
    }
    func getGame(difficulty: Difficulty) -> SoloGame? {
        if let boardModel = userDefaults.data(forKey: savedGameKey + "_\(difficulty.title)") {
            return try? jsonDecoder.decode(SoloGame.self, from: boardModel)
        }
        return nil
    }
    
    func save(darkMode: Bool) {
        userDefaults.set(String(darkMode), forKey: darkModeKey)
    }
    func getDarkMode() -> Bool? {
        return userDefaults.string(forKey: darkModeKey).flatMap { Bool($0) }
    }
}
