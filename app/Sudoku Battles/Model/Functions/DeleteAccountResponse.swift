struct DeleteAccountResponse: Codable {
    let status: Status
    
    enum Status: String, Codable{
        case success = "success"
        case serverError = "serverError"
        case unauthorized = "unauthorized"
    }
}
