import SwiftUI

struct LandingPage: View {
    @EnvironmentObject private var navState: NavigationState
    @EnvironmentObject private var authState: AuthenticationState

    var body: some View {
        VStack {
            Text("Landing Page")
            Button(action: {
                Task {
                    if let credential = await GoogleAuthDs.shared.requestCredential() {
                        do {
                            try await authState.logIn(credential: credential)
                            if let user = authState.user, authState.userData == nil {
                                navState.navigate { OnboardingPage(user: user) }
                            }
                        } catch AppError.firebaseConnectionError {
                            logger.error("Unhandled error on landing page")
                        }
                    }
                }
            }) {
                Text("Continue With Google")
            }
            Button(action: {}) {
                Text("Continue With Facebook")
            }
        }
    }
}

#Preview {
    LandingPage()
}
