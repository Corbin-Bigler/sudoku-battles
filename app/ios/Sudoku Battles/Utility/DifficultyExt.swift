//
//  Difficulty.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/13/25.
//

import SwiftUI

extension Difficulty {
    var color: Color {
        switch self {
        case .easy: return .green400
        case .medium: return .blue400
        case .hard: return .purple400
        case .extreme: return .yellow400
        case .inhuman: return .red400
        }
    }
}
