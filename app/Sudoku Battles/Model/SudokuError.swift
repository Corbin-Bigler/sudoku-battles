import Foundation

enum SudokuError: String, Codable, Error {
    case networkError
    case appOutdated
    case invalidResponse
    case invalidUsername
    case usernameTaken
    case unauthorized
    case serverUpdating
    case serverError
    case unknown
}
