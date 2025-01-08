import FirebaseFirestore

struct Matchmaking: Codable {
    let timestamp: Timestamp
    let user: DocumentReference
    let game: DocumentReference?
}
