import FirebaseAuth
import CryptoKit
import AuthenticationServices

@MainActor
class AppleAuthDs: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static var shared = AppleAuthDs()
    
    private var continuation : CheckedContinuation<AuthCredential?,Error>?

    private var currentNonce: String?

    func requestCredential() async throws -> AuthCredential? {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let request = createAppleIdRequest()
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])

            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self

            authorizationController.performRequests()
        }
    }

    private func createAppleIdRequest() -> ASAuthorizationRequest  {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName]

        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce

        return request
    }
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    private func randomNonceString(length: Int = 32) -> String {
       precondition(length > 0)
       let charset: [Character] =
       Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
       var result = ""
       var remainingLength = length
       
       while remainingLength > 0 {
           let randoms: [UInt8] = (0 ..< 16).map { _ in
               var random: UInt8 = 0
               let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
               if errorCode != errSecSuccess {
                   fatalError(
                       "[ContinueWithApple] Unable to generate nonce. error: \(errorCode)"
                   )
               }
               return random
           }

           randoms.forEach { random in
               if remainingLength == 0 {
                   return
               }
               
               if random < charset.count {
                   result.append(charset[Int(random)])
                   remainingLength -= 1
               }
           }
       }
       return result
   }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else  {
                continuation?.resume(throwing: SudokuError.unauthorized)
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                continuation?.resume(throwing: SudokuError.unauthorized)
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                continuation?.resume(throwing: SudokuError.unauthorized)
                return
            }
            let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: idTokenString, rawNonce: nonce)
            
            continuation?.resume(returning: credential)
        } else {
            continuation?.resume(returning: nil)
        }
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first ?? UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(returning: nil)
    }
}
