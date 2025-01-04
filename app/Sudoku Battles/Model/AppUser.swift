//
//  AppUser.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/26/24.
//
import FirebaseAuth

struct AppUser {
    let uid: String
    let authUser: User?
    
    init(uid: String, user: User? = nil) {
        self.uid = uid
        self.authUser = user
    }
    init(_ authUser: User) {
        self.uid = authUser.uid
        self.authUser = authUser
    }
}
