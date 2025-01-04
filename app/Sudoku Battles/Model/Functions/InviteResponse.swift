//
//  InviteResponse.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/27/24.
//

struct InviteResponse: Codable {
    let status: Status
    
    enum Status: String, Codable{
        case success = "success"
        case serverError = "serverError"
        case unauthorized = "unauthorized"
        case invalidRequest = "invalidRequest"
    }
}
