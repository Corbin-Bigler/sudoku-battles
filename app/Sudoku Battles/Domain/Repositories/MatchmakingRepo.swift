import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

class MatchmakingRepo {
    static let shared = MatchmakingRepo()
    
    private var timer: Timer?
    var matchmakingListener: ListenerRegistration?

    func startMatchmaking(uid: String, callback: @escaping (DocumentReference) -> ()) {
        cancelMatchmaking(uid: uid)
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.executeMatchmaking(uid: uid, callback: callback)
        }
        executeMatchmaking(uid: uid, callback: callback)
    }
    func cancelMatchmaking(uid: String) {
        matchmakingListener?.remove()
        matchmakingListener = nil
        timer?.invalidate()
        timer = nil
        Task { try? await FirestoreDs.shared.deleteMatchmaking(uid: uid) }
    }

    private func executeMatchmaking(uid: String, callback: @escaping (DocumentReference) -> ()) {
        Task { [weak self] in
            guard let self else { return }
            logger.trace("running timed matchmaking call")

            do {
                let results = try await FunctionsDs.shared.requestMatchmaking()
                logger.trace("\("received initial result of \(results)")")

                switch results.status {
                case .unauthorized: return
                case .serverError: return
                case .unmatched:
                    if let matchmakingPath = results.data?.matchmakingPath, matchmakingListener == nil {
                        matchmakingListener = try await FirestoreDs.shared.subscribeToDocument(matchmakingPath) { [weak self] (data: Matchmaking) in
                            guard let self else {return}
                            logger.trace("\("received subscribed data of \(data)")")
                            
                            if let game = data.game {
                                cancelMatchmaking(uid: uid)
                                logger.debug("\("Matched game from subscription \(game.documentID)")")
                                callback(game)
                            }
                        }
                    }
                case .matched:
                    if let duelPath = results.data?.duelPath {
                        cancelMatchmaking(uid: uid)
                        logger.debug("\("Matched game from call \(duelPath)")")
                        callback(FirestoreDs.shared.reference(of: duelPath))
                    }
                }
            } catch {
                logger.debug("\("Error during matchmaking: \(error)")")
            }
        }
    }

}
