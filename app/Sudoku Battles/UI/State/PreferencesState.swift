//
//  PreferencesState.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/7/25.
//

import Foundation

class PreferencesState: ObservableObject {
    static let shared = PreferencesState()

    @Published var darkMode: Bool?
    
    init() {
        self.darkMode = UserDefaultsDs.shared.getDarkMode()
    }
    
    func setDarkMode(_ value: Bool) {
        UserDefaultsDs.shared.save(darkMode: value)
        darkMode = value
    }
}
