//
//  UserCreateService.swift
//  sudoku-battles-data
//
//  Created by Corbin Bigler on 3/16/25.
//


import Piste
import Foundation

public struct UserCreateService: PisteService {
    public static let function: PisteFunction = "user-create"
    public static let version: Int = 1
    
    public typealias ServerBound = Device
    public typealias ClientBound = User
}
