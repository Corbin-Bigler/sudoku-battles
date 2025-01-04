struct MatchmakingResponse: Codable {
    let status: Status
    let duel: String?
    let matchmaking: String?
    
    enum Status: String, Codable {
        case unauthorized = "unauthorized"
        case unmatched = "unmatched"
        case matched = "matched"
        case serverError = "serverError"
    }
}
