//
//  Untitled.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/13/25.
//

import Firebase
import Foundation

class MockDuelStrategy: DuelStrategy {
    private var onWinner: ((won: Bool, endTime: Timestamp)) -> () = {_ in}
    
    let startTime: Timestamp
    let difficulty: Difficulty
    var enemyName: String
    var enemyPercentage: Double
    let enemyRanking: Int
    
    private(set) var endTime: Timestamp?
    private(set) var friendlyBoard: SudokuBoard

    init(enemyName: String, enemyRanking: Int, enemyPercentage: Double, startTime: Timestamp, difficulty: Difficulty) {
        self.startTime = startTime
        self.difficulty = difficulty
        self.enemyName = enemyName
        self.enemyPercentage = enemyPercentage
        self.enemyRanking = enemyRanking
        self.friendlyBoard = Mock.sudokuBoard
    }
    
    func getSolution() async throws -> String {
        return Mock.solution
    }
    func updateBoard(_ board: SudokuBoard) async throws {
        friendlyBoard = board
    }
    func verifyBoard() async throws -> VerifyDuelBoardStatus {
        if friendlyBoard.correct { return .correct }
        else { return .incorrect }
    }
    func subscribe(onWinner: @escaping ((won: Bool, endTime: Timestamp)) -> (), onEnemyPercentage: @escaping (Double) -> ()) async throws {
        self.onWinner = onWinner
    }
    func unsubscribe() {}
}
