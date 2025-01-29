//
//  FunctionsResponse.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/10/25.
//

struct FunctionsResponse<Status: RawRepresentable & Codable, Body: Codable>: Codable where Status.RawValue == String {
    var status: Status
    var data: Body?
}
