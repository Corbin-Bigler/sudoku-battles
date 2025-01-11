import FirebaseFirestore
import FirebaseAuth

class FirestoreDs {
    static let shared = FirestoreDs()
    
    private let firestore: Firestore
    private let matchmaking: CollectionReference
    private let users: CollectionReference
    private let duels: CollectionReference

    init() {
        self.firestore = Firestore.firestore()
        if Bundle.main.dev {
            let settings = Firestore.firestore().settings
            if(Bundle.main.dev) {
                settings.host = "\(DevEnvironment.emulatorHost):8080"
                settings.isSSLEnabled = false
            }
            settings.cacheSettings = MemoryCacheSettings()
            Firestore.firestore().settings = settings
        }
                
        self.matchmaking = firestore.collection("matchmaking")
        self.users = firestore.collection("users")
        self.duels = firestore.collection("duels")
    }
    
    func updateFcmToken(uid: String, fcmToken: String, deviceId: UUID) async throws {
        let userReference = users.document(uid)
        
        try await userReference.updateData(["fcmTokens.\(deviceId.uuidString.lowercased())" : fcmToken])
        
    }
    
    func subscribeToMatchmaking(id: String, callback: @escaping (Matchmaking) -> ()) async throws -> ListenerRegistration {
        let matchmakingReference = matchmaking.document(id)
        let matchmakingDocument = try? await matchmakingReference.getDocument()
        if let data = try? matchmakingDocument?.data(as: Matchmaking.self) {
            callback(data)
        }
        return matchmakingReference.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, let data = try? document.data(as: Matchmaking.self),
                  error == nil
            else {
                return
            }

            callback(data)
        }
    }
    func deleteMatchmaking(uid: String) async throws {
        let matchmakingReference = matchmaking.document(uid)
        try await matchmakingReference.delete()
    }

    func setUserDataProfile(path: String, uid: String) async throws {
        do {
            try await users.document(uid).updateData(["profilePicture" : path])
        } catch {
            logger.error("\(error)")
            throw SudokuError.networkError
        }
    }
    func getUserData(uid: String) async throws -> UserData? {
        var document: DocumentSnapshot!
        do {
            document = try await users.document(uid).getDocument()
            if !document.exists { return nil }
        } catch {
            logger.error("\(error)")
            throw SudokuError.networkError
        }
        
        do {
            return try document.data(as: UserData.self)
        } catch {
            logger.error("\(error)")
            throw SudokuError.invalidResponse
        }
    }
    func getUserDatas(usernamePartial: String) async throws -> [String : UserData]? {
        var query: QuerySnapshot!
        do {
            query = try await users
                .whereField("usernameLowercase", isGreaterThanOrEqualTo: usernamePartial.lowercased())
                .whereField("usernameLowercase", isLessThanOrEqualTo: usernamePartial.lowercased() + "\u{f8ff}")
                .limit(to: 5)
                .getDocuments()
        } catch {
            logger.error("\(error)")
            throw SudokuError.networkError
        }

        var results: [String: UserData] = [:]
        for document in query.documents {
            if let userData = try? document.data(as: UserData.self) {
                results[document.documentID] = userData
            }
        }
        return results
    }
    
    func updateGameBoard(duelId: String, firstPlayer: Bool, board: String) async throws {
        let field = firstPlayer ? "firstPlayerBoard" : "secondPlayerBoard"
        do {
            try await duels.document(duelId).updateData([field : board])
        } catch {
            logger.error("\(error)")
            throw SudokuError.networkError
        }
    }
    func getDuel(id: String) async throws -> Duel? {
        var document: DocumentSnapshot!
        do {
            document = try await duels.document(id).getDocument()
            if !document.exists { return nil }
        } catch {
            logger.error("\(error)")
            throw SudokuError.networkError
        }
        
        do {
            return try document.data(as: Duel.self)
        } catch {
            logger.error("\(error)")
            throw SudokuError.invalidResponse
        }
    }
    func subscribeToDuel(id: String, callback: @escaping (Duel) -> ()) async throws -> ListenerRegistration {
        let gameReference = duels.document(id)
        let gameDocument = try? await gameReference.getDocument()
        if let data = try? gameDocument?.data(as: Duel.self) { callback(data) }
        return gameReference.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, let data = try? document.data(as: Duel.self),
                  error == nil
            else {
                return
            }

            callback(data)
        }
    }
    
    func getSolution(duelId: String) async throws -> String? {
        guard let sudoku = (try? (try? await duels.document(duelId).getDocument())?.data(as: Duel.self))?.sudoku,
              let solution = (try? (try? await sudoku.getDocument())?.data(as: Sudoku.self))?.solution
        else {
            return nil
        }
        return solution
    }
}
