import Foundation

enum AppError: Swift.Error {
    case networkError
    case firebaseConnectionError
    case invalidResponse
    case unauthorized
}
