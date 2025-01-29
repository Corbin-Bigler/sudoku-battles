import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

class GoogleAuthDs {
    static var shared = GoogleAuthDs()
    
    @MainActor
    func requestCredential() async -> AuthCredential? {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return nil }
        guard let clientID = FirebaseApp.app()?.options.clientID else { return nil }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            if let idToken = result.user.idToken?.tokenString {
                return GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
            }
        } catch { }

        return nil
    }
    
}
