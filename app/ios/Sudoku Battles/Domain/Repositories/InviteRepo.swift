//
//  InviteRepo.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/15/25.
//
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

class InviteRepo {
    static let shared = InviteRepo()
    var inviteListener: ListenerRegistration?
    var invitePath: String?

    func startInvite(uid: String, difficulty: Difficulty, callback: @escaping (DocumentReference) -> ()) async throws {
        cancelInvite()
        logger.trace("Running invite listener")

        let results = try await FunctionsDs.shared.sendInvite(uid: uid, difficulty: difficulty)
        logger.trace("\("received initial result of \(results)")")

        switch results.status {
        case .unauthorized: throw AppError.unknown
        case .serverError: throw AppError.serverError
        case .invalidRequest: throw AppError.unknown
        case .success:
            guard let invitePath = results.data?.invitePath else { throw AppError.unknown }
            inviteListener = try await FirestoreDs.shared.subscribeToDocument(invitePath) { [weak self] (data: Invite) in
                guard let self else {return}
                logger.trace("\("received subscribed data of \(data)")")
                self.invitePath = invitePath
                
                if let game = data.game {
                    self.cancelInvite()
                    logger.debug("\("Matched game from invite subscription \(game.documentID)")")
                    callback(game)
                }
            }
        }
    }
    
    func cancelInvite() {
        inviteListener?.remove()
        inviteListener = nil
        if let invitePath {
            Task { try? await FirestoreDs.shared.deleteDocument(invitePath) }
        }
        invitePath = nil
    }
}
