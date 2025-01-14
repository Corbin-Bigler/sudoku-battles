enum SetUsernameStatus: String, Codable {
    case success
    case serverError
    case unauthorized
    case usernameTaken
    case invalidUsername
}
