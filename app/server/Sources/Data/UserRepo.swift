//
//  UserRepo.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/16/25.
//

import SudokuBattlesData

protocol UserRepo: Sendable {    
    func insert(user: User) async throws
}
