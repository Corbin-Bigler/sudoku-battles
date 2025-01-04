struct VerifyDuelBoardResponse: Codable {
    let status: Status
    
    enum Status: String, Codable{
        case correct = "correct"
        case incorrect = "incorrect"
        case serverError = "serverError"
        case invalidRequest = "invalidRequest"
        case unauthorized = "unauthorized"
    }
}
