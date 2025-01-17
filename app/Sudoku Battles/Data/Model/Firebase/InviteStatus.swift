//
//  InviteStatus.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/15/25.
//

enum InviteStatus: String, Codable {
    case success
    case serverError
    case invalidRequest
    case unauthorized
}
