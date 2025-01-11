import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

class AuthenticationState: ObservableObject {
    static let shared = AuthenticationState()
    
    private var auth: Auth!
    private var fcmToken: String?
    
    @Published var user: AppUser? = nil
    @Published var userData: UserData? = nil
    @Published var validating = true
    @Published var gettingUserData = false
    @Published var unableToContactFirebase = false
    
    func initialize() {
        self.auth = Auth.auth()
        if Bundle.main.dev { auth.useEmulator(withHost: "\(DevEnvironment.emulatorHost)", port: 9099) }
        
        Main {
            self.validating = true
            self.gettingUserData = false
            self.unableToContactFirebase = false
        }
        
        Task {
            if let user = auth.currentUser {
                do {
                    let _ = try await user.getIDTokenResult(forcingRefresh: true)
                    await logIn(user: AppUser(user))
                } catch let error as NSError {
                    if error.code == 17020 {
                        Main { self.unableToContactFirebase = true }
                    } else {
                        logOut()
                    }
                }
            }
            
            Main { self.validating = false }
        }
    }
    func setFcmToken(_ token: String) {
        fcmToken = token
    }
    
    func logIn(credential: AuthCredential) async throws {
        do {
            
            try await TimeoutTask(seconds: 5) {
                let authData = try await self.auth.signIn(with: credential)
                await self.logIn(user: AppUser(authData.user))
            }
        } catch {
            throw AppError.networkError
        }
    }

    func logIn(user: AppUser) async {
        await Main.async { self.user = user }
        await updateUserData()
    }
    func updateUserData() async {
        guard let user else { return }
        await Main.async { self.gettingUserData = true }
        if let userData = try? await FirestoreDs.shared.getUserData(uid: user.uid) {
            await Main.async {
                self.userData = userData
            }
                        
            if let fcmToken,
               let deviceId = await UIDevice.current.identifierForVendor {
                try? await FirestoreDs.shared.updateFcmToken(uid: user.uid, fcmToken: fcmToken, deviceId: deviceId)
            }
        }
        await Main.async { self.gettingUserData = false }
    }
    
    func logOut() {
        try? auth.signOut()
        Main {
            self.user = nil
            self.userData = nil
        }
    }
}
