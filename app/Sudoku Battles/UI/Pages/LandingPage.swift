import SwiftUI

struct LandingPage: View {
    @EnvironmentObject private var navState: NavigationState
    @EnvironmentObject private var authState: AuthenticationState
    @State private var showEnterUsername = false
    @State private var settingUsername = false
    @FocusState private var usernameFieldFocused
    @State private var username = ""
    @State private var error: String?
    
    func submitUsername(user: AppUser) {
        settingUsername = true
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
            Main { settingUsername = false }
        }
    }

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Spacer()
                Image("DrawingHand")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 600, maxHeight: 600)
                    .padding(.horizontal, 16)
                    .padding(.top, 40)
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    if let user = authState.user, showEnterUsername {
                        Text("Enter a Username")
                            .font(.sora(28, .semibold))
                        Spacer()
                            .frame(height: 15)
                        InputField(text: $username, placeholder: "Type here...")
                            .textInputAutocapitalization(.never)
                            .focused($usernameFieldFocused)
                            .autocorrectionDisabled(true)
                        Spacer()
                            .frame(height: 30)
                        RoundedButton(
                            label: "Save",
                            color: .white,
                            loading: settingUsername
                        ) {
                            submitUsername(user: user)
                        }
                        .padding(.bottom, 25)
                    } else {
                        Text("Ready to Start Battling?")
                            .font(.sora(28, .semibold))
                        Spacer()
                            .frame(height: 15)
                        Text("Sudoku Battles lets you put your wits to the test against your friends. It’s not just about getting the right answer—it’s about being faster and smarter than your opponent")
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
                        Text("Continue with")
                            .font(.sora(28, .semibold))
                        Spacer()
                            .frame(height: 15)
                        HStack(spacing: 16) {
                            RoundedButton(
                                icon: Image("GoogleLogo"),
                                label: "Google",
                                color: .white,
                                outlined: false
                            ) {
                                Task {
                                    if let credential = await GoogleAuthDs.shared.requestCredential() {
                                        do {
                                            try await authState.logIn(credential: credential)
                                            if authState.user != nil && authState.userData == nil {
                                                Main {
                                                    usernameFieldFocused = true
                                                    showEnterUsername = true
                                                }
                                            }
                                        } catch AppError.firebaseConnectionError {
                                            self.error = "Unable to connect to server"
                                        }
                                    }
                                }
                            }
                            RoundedButton(
                                icon: Image("AppleLogo"),
                                label: "Apple",
                                color: .white,
                                outlined: false
                            ) {
                                Task {
                                    if let credential = try? await AppleAuthDs.shared.requestCredential() {
                                        do {
                                            try await authState.logIn(credential: credential)
                                            if authState.user != nil && authState.userData == nil {
                                                Main {
                                                    usernameFieldFocused = true
                                                    showEnterUsername = true
                                                }
                                            }
                                        } catch AppError.firebaseConnectionError {
                                            self.error = "Unable to connect to server"
                                        }
                                    }
                                }
                            }
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
            GeometryReader { geometry in
                Color.blue400
                Image("SquareNoise")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                LinearGradient(
                    gradient: Gradient(stops: [
                        Gradient.Stop(color: .blue400.opacity(0), location: 0.0),
                        Gradient.Stop(color: .blue400, location: 0.73)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                Image("BlurredHighlight")
                    .offset(x: -350, y: -475)
                Image("BlurredHighlight")
                    .offset(x: geometry.size.width - 400, y: geometry.size.width - 375)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment.topLeading)
            .ignoresSafeArea()
            .navigationBarBackButtonHidden()
        }
//        .errorOverlay(Binding(get: {
//            guard let error else { return nil }
//            return ErrorOverlayModel(title: "Error", body: error)
//        }, set: {
//            error = $0?.body
//        }))
    }
}

#Preview {
    NavigationContainerPreview { LandingPage() }
}
