//
//  SetUsernameResponse.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/26/24.
//

struct SetUsernameResponse: Codable {
    let status: Status
    
    enum Status: String, Codable{
        case success = "success"
        case serverError = "serverError"
        case unauthorized = "unauthorized"
        case usernameTaken = "usernameTaken"
        case invalidRequest = "invalidRequest"
    }
}
