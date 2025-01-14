//
//  VerifyDuelBoardStatus.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/13/25.
//


enum VerifyDuelBoardStatus: String, Codable {
    case correct
    case incorrect
    case serverError
    case invalidRequest
    case unauthorized
}
