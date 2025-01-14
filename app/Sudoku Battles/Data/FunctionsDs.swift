import FirebaseFunctions
import FirebaseAuth
import FirebaseFirestore

class FunctionsDs {
    static let shared = FunctionsDs()
    private let functions: Functions

    init() {
        self.functions = Functions.functions()
        if ProcessInfo.dev {
            self.functions.useEmulator(withHost: "\(ProcessInfo.firebaseHost)", port: 5001)
        }
    }

    private func callFunction<T: Decodable>(_ name: String, params: [String: Any]? = nil) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            functions.httpsCallable(name).call(params) { result, error in
                if let error = error {
                    logger.error("\(error)")
                    continuation.resume(throwing: error)
                } else {
                    guard let data = (result?.data as? String)?.data(using: .utf8) else {
                        continuation.resume(throwing: AppError.networkError)
                        return
                    }
                    do {
                        let response = try JSONDecoder().decode(T.self, from: data)
                        continuation.resume(returning: response)
                    } catch {
                        logger.error("\(error)")
                        continuation.resume(throwing: AppError.invalidResponse)
                    }
                }
            }
        }
    }

//    func sendInvite(uid: String) async throws -> InviteResponse {
//        try await callFunction("invite", params: ["invitee": uid])
//    }
//
    func setUsername(username: String) async throws -> FunctionsResponse<SetUsernameStatus, Never> {
        try await callFunction("setUsername", params: ["username": username])
    }
    
    func verifyDuelBoard(duelPath: String) async throws -> FunctionsResponse<VerifyDuelBoardStatus, Never> {
        try await callFunction("verifyDuelBoard", params: ["duelPath": duelPath])
    }
    func requestMatchmaking() async throws -> FunctionsResponse<MatchmakingStatus, MatchmakingData> {
        try await callFunction("matchmaking")
    }
    func deleteAccount() async throws -> FunctionsResponse<DeleteAccountStatus, MatchmakingData> {
        try await callFunction("deleteAccount")
    }
}

