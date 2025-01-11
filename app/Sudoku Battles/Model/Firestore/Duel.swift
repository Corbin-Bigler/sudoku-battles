import Foundation
import FirebaseFirestore

struct Duel: Codable {
    let firstPlayer: DocumentReference
    let secondPlayer: DocumentReference?
    let firstPlayerBoard: String
    let secondPlayerBoard: String?
    let given: String
    let startTime: Timestamp
    let endTime: Timestamp?
    let botEndTime: Timestamp?
    let sudoku: DocumentReference
    let winner: DocumentReference?
    
    var enemyIsBot: Bool { botEndTime != nil }
    var difficulty: Difficulty { Difficulty(rawValue: sudoku.parent.collectionID) ?? .easy }
}
