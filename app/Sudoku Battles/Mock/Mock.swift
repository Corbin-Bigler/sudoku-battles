//
//  Mock.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/13/25.
//

import FirebaseFirestore

struct Mock {
    static let appUser = AppUser(uid: "mockUid")
    static let userData = UserData(username: "mockUsername", ranking: 1234)
    static let sudokuBoard = SudokuBoard(
        given: "040397185078450032059208060423081570090060040086740219060105890910074620834629050",
        board: "040397185078450032059208060423081570090060040086740219060105890910074620834629050"
    )!
    static let solution = "642397185178456932359218467423981576791562348586743219267135894915874623834629751"
    static let solvedSudokuBoard = SudokuBoard(
        given: "040397185078450032059208060423081570090060040086740219060105890910074620834629050",
        board: solution
    )!
    static let duelRepo = DuelRepo(strategy: MockDuelStrategy(enemyName: "Mock Enemy", enemyRanking: 100, enemyPercentage: 0.5, startTime: Timestamp(), difficulty: .easy))
}
