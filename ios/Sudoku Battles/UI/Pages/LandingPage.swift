import SwiftUI

struct LandingPage: View {
    @EnvironmentObject private var navState: NavigationState
    @EnvironmentObject private var authState: AuthenticationState
    @State private var showEnterUsername: Bool = false
    @State private var username = ""
    @State private var error: String?

    func submitUsername(user: AppUser) {
        Task {
            do {
                let response = try await FunctionsDs.shared.setUsername(username: username)
                switch response.status {
                case .success:
                    await authState.logIn(user: user)
                    navState.clear()
                case .serverError: Main { error = "Server Error" }
                case .unauthorized: Main { error = "Unauthorized" }
                case .usernameTaken: Main { error = "Username taken" }
                case .invalidRequest: Main { error = "Invalid Request" }
                }
            } catch {
                logger.error("\(error)")
                self.error = error.localizedDescription
            }
        }
    }

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Image("DrawingHand")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 374, height: 352)
                    .padding(.top, 40)
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    if let user = authState.user, showEnterUsername {
                        Text("Enter a Username")
                            .font(.sora(28, .semibold))
                        Spacer()
                            .frame(height: 15)
                        InputField(text: $username, placeholder: "Type here...")
                        Spacer()
                            .frame(height: 30)
                        RoundedButton(
                            label: "Save",
                            outlined: false
                        ) {
                            submitUsername(user: user)
                        }
                        .padding(.bottom, 25)
                    } else {
                        Text("Heading Here")
                            .font(.sora(28, .semibold))
                        Spacer()
                            .frame(height: 15)
                        Text("Explication of app lorem ipsum dolor sit amet consectetur. Id maecenas magna dolor pulvinar. Et tortor as volutpat libero dictum felis faucibus sed vive vulputate. Blandit asu semper dictum volutpat eu sed in cursus shu eleifend nec. Aliqu lacus eu nunc sagittis vit.")
                            .font(.sora(16))
                        Spacer()
                            .frame(height: 30)
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0), .white, .white.opacity(0)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 1)
                        Spacer()
                            .frame(height: 30)
                        Text("Create an account")
                            .font(.sora(28, .semibold))
                        Spacer()
                            .frame(height: 15)
                        HStack(spacing: 16) {
                            RoundedButton(
                                icon: Image("GoogleLogo"),
                                label: "Google",
                                outlined: false
                            ) {
                                Task {
                                    if let credential = await GoogleAuthDs.shared.requestCredential() {
                                        do {
                                            try await authState.logIn(credential: credential)
                                            if authState.user != nil && authState.userData == nil {
                                                Main { showEnterUsername = true }
                                            }
                                        } catch AppError.firebaseConnectionError {
                                            logger.error("Unhandled error on landing page")
                                        }
                                    }
                                }
                            }
                            RoundedButton(
                                icon: Image("AppleLogo"),
                                label: "Apple",
                                outlined: false
                            ) {}
                        }
                        .padding(.bottom, 25)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            NoiseBackground()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    LandingPage()
}
