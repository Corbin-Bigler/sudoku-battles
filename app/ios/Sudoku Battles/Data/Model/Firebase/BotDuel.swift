import Foundation
import FirebaseFirestore

struct BotDuel: Codable {
    let startTime: Timestamp
    let player: DocumentReference
    let playerBoard: String
    let endTime: Timestamp?
    let given: String
    let botEndTime: Timestamp
    let sudoku: DocumentReference
    let botRanking: Int

    var difficulty: Difficulty { Difficulty(rawValue: sudoku.parent.collectionID) ?? .easy }
}
