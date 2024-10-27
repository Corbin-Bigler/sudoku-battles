import FirebaseFirestore
import FirebaseAuth

class FirestoreDs {
    static let shared = FirestoreDs()
    
    private let firestore: Firestore
    private let matchmaking: CollectionReference
    private let users: CollectionReference
    private let games: CollectionReference

    init() {
        self.firestore = Firestore.firestore()
        if Bundle.main.dev {
            let settings = Firestore.firestore().settings
            if(Bundle.main.dev) {
                settings.host = "localhost:8080"
                settings.isSSLEnabled = false
            }
            Firestore.firestore().settings = settings
        }
        self.matchmaking = firestore.collection("matchmaking")
        self.users = firestore.collection("users")
        self.games = firestore.collection("games")
    }
    
    func subscribeToMatchmaking(id: String, callback: @escaping (MatchmakingData) -> ()) async throws -> ListenerRegistration {
        let matchmakingReference = matchmaking.document(id)
        let matchmakingDocument = try? await matchmakingReference.getDocument()
        if let data = try? matchmakingDocument?.data(as: MatchmakingData.self) {
            callback(data)
        }
        return matchmakingReference.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, let data = try? document.data(as: MatchmakingData.self),
                  error == nil
            else {
                return
            }

            callback(data)
        }
    }
    func deleteMatchmaking(uid: String) {
        let matchmakingReference = matchmaking.document(uid)
        matchmakingReference.delete()
    }

    func getUserData(uid: String) async throws -> UserData? {
        var document: DocumentSnapshot!
        do {
            document = try await users.document(uid).getDocument()
            if !document.exists { return nil }
        } catch {
            logger.error("\(error)")
            throw AppError.firebaseConnectionError
        }
        
        do {
            return try document.data(as: UserData.self)
        } catch {
            logger.error("\(error)")
            throw AppError.invalidResponse
        }
    }
    
    func updateGameBoard(gameId: String, firstPlayer: Bool, board: String) async throws {
        let field = firstPlayer ? "firstPlayerBoard" : "secondPlayerBoard"
        do {
            try await games.document(gameId).updateData([field : board])
        } catch {
            logger.error("\(error)")
            throw AppError.firebaseConnectionError
        }
    }
    func getGame(id: String) async throws -> GameData? {
        var document: DocumentSnapshot!
        do {
            document = try await games.document(id).getDocument()
            if !document.exists { return nil }
        } catch {
            logger.error("\(error)")
            throw AppError.firebaseConnectionError
        }
        
        do {
            return try document.data(as: GameData.self)
        } catch {
            logger.error("\(error)")
            throw AppError.invalidResponse
        }
    }
    func subscribeToGame(id: String, callback: @escaping (GameData) -> ()) async throws -> ListenerRegistration {
        let gameReference = games.document(id)
        let gameDocument = try? await gameReference.getDocument()
        if let data = try? gameDocument?.data(as: GameData.self) { callback(data) }
        return gameReference.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, let data = try? document.data(as: GameData.self),
                  error == nil
            else {
                return
            }

            callback(data)
        }
    }

}
