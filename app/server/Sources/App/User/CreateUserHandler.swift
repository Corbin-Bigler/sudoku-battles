//
//  CreateUserHandler.swift
//  sudoku-battles-server
//
//  Created by Corbin Bigler on 3/17/25.
//

import Piste
import SudokuBattlesData
import Foundation

struct CreateUserHandler: PisteServiceHandler {
    typealias Service = UserCreateService
    
    let userRepo: UserRepo
    
    func handle(inbound: PisteFrame<UserCreateService.ServerBound>) async -> PisteResponse<UserCreateService.ClientBound> {
        let newUser = User(id: UUID(), username: nil, usernameChangedAt: nil, ranking: 100, admin: false, devices: [inbound.payload])
        do {
            try await userRepo.insert(user: newUser)
            return .success(newUser)
        } catch {
            return .failure(SudokuBattlesError.failedToSave.rawValue)
        }
    }
}
