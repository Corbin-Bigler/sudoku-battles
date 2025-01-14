enum MatchmakingStatus: String, Codable {
    case serverError
    case unauthorized
    case unmatched
    case matched
}
