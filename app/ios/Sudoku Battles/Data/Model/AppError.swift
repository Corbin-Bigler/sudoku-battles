//
//  AppError.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/13/25.
//

enum AppError: Error {
    case networkError
    case appOutdated
    case invalidResponse
    case invalidUsername
    case usernameTaken
    case unauthorized
    case serverUpdating
    case serverError
    case unknown
}
