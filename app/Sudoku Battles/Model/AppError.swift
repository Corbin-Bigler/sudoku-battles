import Foundation

enum AppError: Error {
    case networkError
    case appOutdated
    case invalidResponse
    case unauthorized
    case serverUpdating
    case serverError
    case unknown
}
