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
                } catch {
                    Main { self.unableToContactFirebase = true }
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
            
//            let granted = try? await PushNotificationsUtility.requestPermissions()
            
            if let fcmToken,
               let deviceId = await UIDevice.current.identifierForVendor {
                try? await FirestoreDs.shared.updateFcmToken(uid: user.uid, fcmToken: fcmToken, deviceId: deviceId)
            }
        }
        await Main.async { self.gettingUserData = false }
    }
    
    func logOut() {
        try? auth.signOut()
        user = nil
        userData = nil
    }
}
