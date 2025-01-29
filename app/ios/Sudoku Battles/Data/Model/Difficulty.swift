//
//  Difficulty.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/13/25.
//

enum Difficulty: String, CaseIterable, Codable {
    case easy
    case medium
    case hard
    case extreme
    case inhuman
    
    var title: String {
        rawValue.capitalized
    }
}
