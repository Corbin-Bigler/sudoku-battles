import SwiftUI

struct UserSettingsPage: View {
    @ObservedObject var authState = AuthenticationState.shared
    @EnvironmentObject private var navState: NavigationState
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var preferencesState = PreferencesState.shared

    @State private var deleting = false
    @State private var showDeleteAccountConfirm = false
    @State private var showChangeUsername = false
    @State private var usernameChanging = false
    @State private var newUsername: String
    @State private var newUsernameError: String?
    @State private var error: String?
    
    let user: AppUser
    let userData: UserData

    init(user: AppUser, userData: UserData) {
        self.user = user
        self.userData = userData
        self._newUsername = State(initialValue: userData.username)
    }
    
    func changeUsername() {
        usernameChanging = true
        Task {
            let response = try? await FunctionsDs.shared.setUsername(username: newUsername)
            await AuthenticationState.shared.updateUserData()
            
            Main {
                newUsernameError = nil
                usernameChanging = false
                if response?.status == .usernameTaken {
                    newUsernameError = "Username is already taken"
                } else if response?.status != .success {
                    newUsernameError = "Unable to change username"
                } else {
                    showChangeUsername = false
                }
            }
        }
    }
    
    func deleteAccount() {
        deleting = true
        Task {
            do {
                let response = try await FunctionsDs.shared.deleteAccount()
                Main {
                    if response.status != .success {
                        self.error = "Unable to delete account"
                    } else {
                        authState.logOut()
                        navState.clear()
                    }
                }
            } catch {
                Main { self.error = "Unable to delete account" }
            }
            Main { self.deleting = false }
        }
    }
    
    var backgroundColor: Color { colorScheme == .dark ? .gray900 : .white }
    var foregroundColor: Color { colorScheme == .dark ? .white : .black }
    var outlineColor: Color { colorScheme == .dark ? .gray800 : .gray100 }

    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 0) {
                ZStack {
                    Image("ChevronIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                        .foregroundStyle(foregroundColor)
                }
                .frame(width: 40, height: 40)
                .circleButton(outline: foregroundColor) {
                    navState.navigate(back: 1)
                }
                Spacer()
                Text("Settings")
                    .font(.sora(24, .bold))
                Spacer()
                Spacer()
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(authState.userData?.username ?? "")
                        .font(.sora(24, .semibold))
                    Spacer()
                    Image("Sparkle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                }
                HStack {
                    Text("Skill Rating:")
                        .font(.sora(16))
                    Text(String(userData.ranking))
                        .font(.sora(14, .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.blue400)
                        .cornerRadius(.infinity)
                        .foregroundStyle(.white)
                }
            }
            .foregroundStyle(colorScheme == .dark ? .black : .white)
            .padding(.horizontal, 16)
            .frame(height: 83)
            .background(colorScheme == .dark ? .blue50 : .blue900)
            .cornerRadius(20)
            
            ZStack(alignment: .topLeading) {
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        Image("LineEditIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18)
                            .frame(width: 40, height: 40)
                            .background(.blue400.opacity(0.1))
                            .clipShape(Circle())
                        Text("Change Username")
                            .font(.sora(14, .semibold))
                        Spacer()
                        Image("ArrowIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12.25)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if(authState.userData?.oneMonthSinceUsernameChange == false) {
                            error = "It hasn't been a month since your last username change."
                            return
                        }
                        showChangeUsername = true
                    }
                    
                    let darkMode = preferencesState.darkMode ?? (colorScheme == .dark)
                    HStack(spacing: 15) {
                        Image("ColorInversionIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18)
                            .frame(width: 40, height: 40)
                            .background(.blue400.opacity(0.1))
                            .clipShape(Circle())
                        Text("Dark Theme")
                            .font(.sora(14, .semibold))
                        Spacer()
                        
                        SudokuToggle(isOn: .constant(darkMode))
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            preferencesState.setDarkMode(!darkMode)
                        }
                    }
                }
                .padding(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.blue200, lineWidth: 2)
                }
                Text("General Details")
                    .font(.sora(20, .bold))
                    .padding(.horizontal, 5)
                    .background(backgroundColor)
                    .offset(x: 18, y: -13)
            }
            .padding(.top, 13)
            
            ZStack(alignment: .topLeading) {
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        Image("LogoutIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18)
                            .frame(width: 40, height: 40)
                            .background(.blue400.opacity(0.1))
                            .clipShape(Circle())
                        Text("Log Out")
                            .font(.sora(14, .semibold))
                        Spacer()
                        Image("ArrowIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12.25)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        authState.logOut()
                        navState.clear()
                    }
                    HStack(spacing: 15) {
                        Image("RemoveUserIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18)
                            .frame(width: 40, height: 40)
                            .background(.red400.opacity(0.1))
                            .clipShape(Circle())
                        Text("Delete Account")
                            .font(.sora(14, .semibold))
                            .foregroundStyle(.red400)
                        Spacer()
                        Image("ArrowIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12.25)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showDeleteAccountConfirm = true
                    }
                }
                .padding(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.blue200, lineWidth: 2)
                }
                Text("Account")
                    .font(.sora(20, .bold))
                    .padding(.horizontal, 5)
                    .background(backgroundColor)
                    .offset(x: 18, y: -13)
            }
            .padding(.top, 13)

            
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(backgroundColor)
        .overlay(isPresented: error != nil) {
            VStack(spacing: 16) {
                Text("Account Error")
                    .font(.sora(20, .semibold))
                Text(error!)
                    .font(.sora(16))
                    .multilineTextAlignment(.center)
                
                HStack {
                    RoundedButton(label: "OK", color: .blue400) {
                        error = nil
                    }
                }
            }
            .frame(maxWidth: 275)
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(11)
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(outlineColor, lineWidth: 1)
            }
            .padding(16)
        }
        .overlay(isPresented: showChangeUsername) {
            VStack(spacing: 16) {
                Text("Change Username")
                    .font(.sora(20, .semibold))
                Text("You can only change your username once every month")
                    .font(.sora(16))
                    .multilineTextAlignment(.center)
                
                let inputFieldColor: Color = colorScheme == .dark ? .white : .gray600
                InputField(text: $newUsername, placeholder: "Type here...", color: inputFieldColor, error: newUsernameError)
                
                HStack {
                    let cancelButtonColor: Color = colorScheme == .dark ? .white : .black
                    RoundedButton(label: "Cancel", color: cancelButtonColor, outlined: true) {
                        showChangeUsername = false
                    }
                    RoundedButton(label: "Continue", color: .blue400, loading: usernameChanging) {
                        changeUsername()
                    }
                }
            }
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(11)
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(outlineColor, lineWidth: 1)
            }
            .padding(16)
        }
        .overlay(isPresented: showDeleteAccountConfirm || deleting) {
            VStack(spacing: 16) {
                Text("Delete Account")
                    .font(.sora(20, .semibold))
                Text("Are you sure you want to delete your account? This cannot be undone.")
                    .font(.sora(16))
                    .multilineTextAlignment(.center)
                                
                HStack {
                    RoundedButton(label: "Cancel", color: colorScheme == .dark ? .white : .black, outlined: true) {
                        showDeleteAccountConfirm = false
                    }
                    RoundedButton(label: "Delete", color: .red400, loading: deleting) {
                        deleteAccount()
                    }
                }
            }
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(11)
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(outlineColor, lineWidth: 1)
            }
            .padding(16)
        }

        .navigationBarBackButtonHidden()
    }
}

#Preview {
    UserSettingsPage(user: Mock.appUser, userData: Mock.userData)
}
