import FirebaseFunctions
import FirebaseAuth
import FirebaseFirestore

class FunctionsDs {
    static let shared = FunctionsDs()
    
    private let functions: Functions

    init() {
        self.functions = Functions.functions()
        if Bundle.main.dev { self.functions.useEmulator(withHost: "localhost", port: 5001) }
    }

    func setUsername(username: String) async throws -> SetUsernameResponse {
        return try await withCheckedThrowingContinuation { continuation in
            functions.httpsCallable("setUsername").call(["username": username]) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    guard let data = (result?.data as? String)?.data(using: .utf8) else {
                        continuation.resume(throwing: AppError.firebaseConnectionError)
                        return
                    }
                    do {
                        let response = try JSONDecoder().decode(SetUsernameResponse.self, from: data)
                        continuation.resume(returning: response)
                    } catch {
                        continuation.resume(throwing: AppError.invalidResponse)
                        logger.error("\(error)")
                        return
                    }
                }
            }
        }
    }
    
    func requestMatchmaking() async throws -> MatchmakingResponse {
        return try await withCheckedThrowingContinuation { continuation in
            functions.httpsCallable("matchmaking").call() { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    guard let data = (result?.data as? String)?.data(using: .utf8) else {
                        continuation.resume(throwing: AppError.firebaseConnectionError)
                        return
                    }
                    do {
                        let response = try JSONDecoder().decode(MatchmakingResponse.self, from: data)
                        continuation.resume(returning: response)
                    } catch {
                        continuation.resume(throwing: AppError.invalidResponse)
                        logger.error("\(error)")
                        return
                    }
                }
            }
        }
    }
    
    func deleteAccount() async throws {
        fatalError("not implemented")
    }
}

//class OldFunctionsDs {
//    static let shared = OldFunctionsDs()
//
//    private let functions: Functions
//    private var timer: Timer?
//
//    init() {
//        self.functions = Functions.functions()
//        self.functions.useEmulator(withHost: "localhost", port: 5001)
//    }
//    
//    private func callMatchmakingFunction() async throws -> [String: Any]? {
//        return try await withCheckedThrowingContinuation { continuation in
//            functions.httpsCallable("matchmaking").call() { result, error in
//                if let error {
//                    continuation.resume(throwing: error)
//                } else {
//                    guard let data = result?.data as? [String: Any] else {
//                        continuation.resume(throwing: AppError.firebaseConnectionError)
//                        return
//                    }
//                    continuation.resume(returning: data)
//                }
//            }
//        }
//    }
//    
//    func startMatchmaking(user: User, callback: @escaping (String) -> ()) {
//        cancelMatchmaking(user: user)
//        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
//            self?.executeMatchmaking(user: user, callback: callback)
//        }
//        executeMatchmaking(user: user, callback: callback)
//    }
//    func cancelMatchmaking(user: User) {
//        matchmakingListener?.remove()
//        matchmakingListener = nil
//        OldFirestoreDs.shared.deleteMatchmaking(id: user.uid)
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    var matchmakingListener: ListenerRegistration?
//    private func executeMatchmaking(user: User, callback: @escaping (String) -> ()) {
//        Task { [weak self] in
//            guard let self else { return }
//            print("running timed matchmaking call")
//            
//            do {
//                let results = try await callMatchmakingFunction()
//                print("received initial result of \(results)")
//
//                if results?["matched"] as? Int == 1 {
//                    if let gameId = results?["game"] as? String {
//                        cancelMatchmaking(user: user)
//                        logger.debug("Matched game from call \(gameId)")
//                        callback(gameId)
//                    }
//                } else if let id = results?["matchmaking"] as? String, matchmakingListener == nil {
//                    matchmakingListener = try await OldFirestoreDs.shared.subscribeToMatchmaking(id: id) { [weak self] data in
//                        guard let self else {return}
//                        print("received subscribed data of \(data)")
//                        
//                        if let game = data["game"] as? DocumentReference {
//                            cancelMatchmaking(user: user)
//                            logger.debug("Matched game from subscription \(game.documentID)")
//                            callback(game.documentID)
//                        }
//                    }
//                }
//            } catch {
//                logger.debug("Error during matchmaking: \(error)")
//            }
//        }
//    }
//}

