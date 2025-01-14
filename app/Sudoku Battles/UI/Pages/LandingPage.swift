import SwiftUI

struct LandingPage: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var navState: NavigationState
    @EnvironmentObject private var authState: AuthenticationState
    @State private var showEnterUsername = false
    @State private var settingUsername = false
    @State private var authenticating = false
    @FocusState private var usernameFieldFocused
    @State private var username = ""
    
    @State private var status: SetUsernameStatus?
    @State private var error: AppError?
    
    func submitUsername(user: AppUser) {
        settingUsername = true
        Task {
            do {
                let response = try await FunctionsDs.shared.setUsername(username: username)
                await AuthenticationState.shared.logIn(user: user)
                print(response)
                if response.status != .success { status = response.status }
            } catch {
                logger.error("\(error)")
                if let error = error as? AppError { self.error = error }
                else { self.error = .unknown }
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
                                if !NetworkUtility.shared.isConnected {
                                    error = .networkError
                                    return
                                }

                                Task {
                                    if let credential = await GoogleAuthDs.shared.requestCredential() {
                                        do {
                                            await Main.async { self.authenticating = true }
                                            try await authState.logIn(credential: credential)
                                            if authState.user != nil && authState.userData == nil {
                                                Main {
                                                    usernameFieldFocused = true
                                                    showEnterUsername = true
                                                }
                                            }
                                        } catch {
                                            logger.error("\(error)")
                                            if let error = error as? AppError { self.error = error }
                                            else { self.error = .unknown }
                                        }
                                    }
                                    Main { self.authenticating = false }
                                }
                            }
                            RoundedButton(
                                icon: Image("AppleLogo"),
                                label: "Apple",
                                color: .white,
                                outlined: false
                            ) {
                                if !NetworkUtility.shared.isConnected {
                                    error = .networkError
                                    return
                                }
                                Task {
                                    if let credential = try? await AppleAuthDs.shared.requestCredential() {
                                        await Main.async { self.authenticating = true }
                                        do {
                                            try await authState.logIn(credential: credential)
                                            if authState.user != nil && authState.userData == nil {
                                                Main {
                                                    usernameFieldFocused = true
                                                    showEnterUsername = true
                                                }
                                            }
                                        } catch {
                                            logger.error("\(error)")
                                            if let error = error as? AppError { self.error = error }
                                            else { self.error = .unknown }
                                        }
                                    }
                                    
                                    Main { self.authenticating = false }
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
        .alert("Network Error", isPresented: Binding(get: {error == .networkError}, set: {_ in error = nil})) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("Unable to connect to server.")
        }
        .alert("Invalid Username", isPresented: Binding(get: {status == .invalidUsername}, set: {_ in status = nil})) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("This username is invalid.")
        }
        .alert("Username Taken", isPresented: Binding(get: {status == .usernameTaken}, set: {_ in status = nil})) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("This username is taken.")
        }
        .alert("Server Error", isPresented: Binding(get: {status == .serverError}, set: {_ in status = nil})) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("An server error has occured. Please try again later.")
        }
        .background {
            GeometryReader { geometry in
                let color: Color = colorScheme == .dark ? .gray900 : .blue400
                
                color
                Image("SquareNoise")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                LinearGradient(
                    gradient: Gradient(stops: [
                        Gradient.Stop(color: color.opacity(0), location: 0.0),
                        Gradient.Stop(color: color, location: 0.73)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                Image("BlurredHighlight")
                    .renderingMode(.template)
                    .offset(x: -400, y: -475)
                Image("BlurredHighlight")
                    .renderingMode(.template)
                    .offset(x: geometry.size.width - 350, y: geometry.size.height - 750)
            }
            .foregroundStyle(colorScheme == .dark ? .blue200 : .white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment.topLeading)
            .ignoresSafeArea()
            .navigationBarBackButtonHidden()
        }
        .overlay(isPresented: authenticating) {
            ProgressView()
                .preferredColorScheme(.light)
        }
    }
}

#Preview {
    NavigationContainerPreview { LandingPage() }
}
