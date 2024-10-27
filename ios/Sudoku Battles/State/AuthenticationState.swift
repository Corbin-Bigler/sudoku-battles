import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthenticationState: ObservableObject {
    static let shared = AuthenticationState()
    
    private var auth: Auth!
    
    @Published var user: AppUser? = nil
    @Published var userData: UserData? = nil
    @Published var validating = true
    @Published var gettingUserData = false

    func initialize() {
        self.auth = Auth.auth()
        if Bundle.main.dev { auth.useEmulator(withHost: "localhost", port: 9099) }
        
        Task {
            if let user = auth.currentUser {
                let _ = try? await user.getIDTokenResult(forcingRefresh: true)
                await logIn(user: AppUser(user))
            }
            
            Main { self.validating = false }
        }
    }
    func logIn(credential: AuthCredential) async throws {
        do {
            let authData = try await auth.signIn(with: credential)
            await logIn(user: AppUser(authData.user))
        } catch {
            throw AppError.firebaseConnectionError
        }
    }
    func logIn(user: AppUser) async {
        Main {
            self.gettingUserData = true
            self.user = user
        }
        if let userData = try? await FirestoreDs.shared.getUserData(uid: user.uid) {
            await Main.async { self.userData = userData }
        }
        await Main.async { self.gettingUserData = false }
    }
    
    func logOut() {
        try? auth.signOut()
        user = nil
        userData = nil
    }
}
