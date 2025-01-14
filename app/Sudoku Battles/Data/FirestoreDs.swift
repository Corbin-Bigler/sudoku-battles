import FirebaseFirestore
import FirebaseAuth

class FirestoreDs {
    static let shared = FirestoreDs()
    static let usersCollectionId = "users"
    static let matchmakingCollectionId = "matchmaking"
    static let playerDuelsCollectionId = "player-duels"
    static let botDuelsCollectionId = "bot-duels"
    
    private let firestore: Firestore
    private let matchmaking: CollectionReference
    private let users: CollectionReference

    init() {
        self.firestore = Firestore.firestore()
        if ProcessInfo.dev {
            let settings = Firestore.firestore().settings
            settings.host = "\(ProcessInfo.firebaseHost):\(ProcessInfo.firestorePort)"
            settings.isSSLEnabled = false
            settings.cacheSettings = MemoryCacheSettings()
            Firestore.firestore().settings = settings
        }
                
        self.matchmaking = firestore.collection(Self.matchmakingCollectionId)
        self.users = firestore.collection(Self.usersCollectionId)
    }
    
    func reference(of path: String) -> DocumentReference {
        return firestore.document(path)
    }
    
    func updateDocument(_ reference: DocumentReference, fields: [String: Any]) async throws {
        try await reference.updateData(fields)
    }
    func updateDocument(_ path: String, fields: [String: Any]) async throws {
        try await updateDocument(firestore.document(path), fields: fields)
    }

    func deleteDocument(_ reference: DocumentReference) async throws {
        try await reference.delete()
    }
    func deleteDocument(_ path: String) async throws {
        try await deleteDocument(firestore.document(path))
    }


    func getDocument<T : Decodable>(_ reference: DocumentReference) async throws -> T? {
        var document: DocumentSnapshot!
        do {
            document = try await reference.getDocument()
            if !document.exists { return nil }
        } catch {
            logger.error("\(error)")
            throw AppError.networkError
        }
        
        do {
            return try document.data(as: T.self)
        }
        catch {
            logger.error("\(error)")
            throw AppError.invalidResponse
        }
    }
    func getDocument<T : Decodable>(_ path: String) async throws -> T? {
        return try await getDocument(firestore.document(path))
    }

    func subscribeToDocument<T : Decodable>(_ reference: DocumentReference, callback: @escaping (T) -> ()) async throws -> ListenerRegistration {
        let document = try? await reference.getDocument()
        if let data = try? document?.data(as: T.self) { callback(data) }
        return reference.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot,
                  document.exists,
                  let data = try? document.data(as: T.self),
                  error == nil
            else { return }

            callback(data)
        }
    }
    func subscribeToDocument<T : Decodable>(_ path: String, callback: @escaping (T) -> ()) async throws -> ListenerRegistration {
        return try await subscribeToDocument(firestore.document(path), callback: callback)
    }

        
    func queryUserData(uid: String) async throws -> UserData? {
        return try await getDocument(users.document(uid))
    }
    func queryUserDatas(usernamePartial: String) async throws -> [String : UserData]? {
        var query: QuerySnapshot!
        do {
            query = try await users
                .whereField("usernameLowercase", isGreaterThanOrEqualTo: usernamePartial.lowercased())
                .whereField("usernameLowercase", isLessThanOrEqualTo: usernamePartial.lowercased() + "\u{f8ff}")
                .limit(to: 5)
                .getDocuments()
        } catch {
            logger.error("\(error)")
            throw AppError.networkError
        }

        var results: [String: UserData] = [:]
        for document in query.documents {
            if let userData = try? document.data(as: UserData.self) {
                results[document.documentID] = userData
            }
        }
        return results
    }
    func updateFcmToken(uid: String, fcmToken: String, deviceId: UUID) async throws {
        try await updateDocument(users.document(uid), fields: ["fcmTokens.\(deviceId.uuidString.lowercased())" : fcmToken])
    }
    
    func deleteMatchmaking(uid: String) async throws {
        try await deleteDocument(matchmaking.document(uid))
    }
    
}
