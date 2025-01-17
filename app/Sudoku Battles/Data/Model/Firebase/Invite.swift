import FirebaseFirestore

struct Invite: Codable {
    let inviter: DocumentReference
    let invitee: DocumentReference
    let difficulty: Difficulty
    let game: DocumentReference?
    let created: Timestamp
}
