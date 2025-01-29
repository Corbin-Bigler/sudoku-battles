import Foundation
import FirebaseFirestore

struct PlayerDuel: Codable {
    let firstPlayer: DocumentReference
    let firstPlayerBoard: String
    let secondPlayer: DocumentReference
    let secondPlayerBoard: String
    let given: String
    let startTime: Timestamp
    let endTime: Timestamp?
    let sudoku: DocumentReference
    let winner: DocumentReference?
    
    var difficulty: Difficulty { Difficulty(rawValue: sudoku.parent.collectionID) ?? .easy }
}
