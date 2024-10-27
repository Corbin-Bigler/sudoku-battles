import FirebaseFirestore

struct MatchmakingData: Codable {
    let timestamp: Timestamp
    let user: DocumentReference
    let game: DocumentReference?
}
