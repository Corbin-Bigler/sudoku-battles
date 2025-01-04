import SwiftUI

struct UserSettingsPage: View {
    @ObservedObject var authState = AuthenticationState.shared
    @EnvironmentObject private var navState: NavigationState

    @State private var showDeleteAccountConfirm = false
    @State private var showChangeUsername = false
    @State private var usernameChanging = false
    @State private var newUsername: String
    @State private var newUsernameError: String?
    @State private var error: String?
    
    let user: AppUser
    
    init(user: AppUser, userData: UserData) {
        self.user = user
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
        Task {
            do {
                let response = try await FunctionsDs.shared.deleteAccount()
                if response.status != .success {
                    self.error = "Unable to delete account"
                } else {
                    Main {
                        authState.logOut()
                        navState.clear()
                    }
                }
            } catch {
                self.error = "Unable to delete account"
            }
            
        }
    }

    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 0) {
                ZStack {
                    Image("ChevronIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                        .foregroundStyle(Color.black)
                }
                .frame(width: 40, height: 40)
                .circleButton(outline: .black) {
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
                    Text("1023")
                        .font(.sora(14, .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.blue400)
                        .cornerRadius(.infinity)
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(height: 83)
            .background(.blue900)
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
                        SudokuToggle(isOn: .constant(false))
                    }
                    .contentShape(Rectangle())
                }
                .padding(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.blue200, lineWidth: 2)
                }
                Text("General Details")
                    .font(.sora(20, .bold))
                    .padding(.horizontal, 5)
                    .background(.white)
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
                    .background(.white)
                    .offset(x: 18, y: -13)
            }
            .padding(.top, 13)

            
            Spacer()
        }
        .padding(.horizontal, 16)
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
            .background(Color.white)
            .cornerRadius(11)
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(.gray100, lineWidth: 1)
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
                
                InputField(text: $newUsername, placeholder: "Type here...", color: .gray600, error: newUsernameError)
                
                HStack {
                    RoundedButton(label: "Cancel", color: .black, outlined: true) {
                        showChangeUsername = false
                    }
                    RoundedButton(label: "Continue", color: .blue400, loading: usernameChanging) {
                        changeUsername()
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(11)
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(.gray100, lineWidth: 1)
            }
            .padding(16)
        }
        .overlay(isPresented: showDeleteAccountConfirm) {
            VStack(spacing: 16) {
                Text("Delete Account")
                    .font(.sora(20, .semibold))
                Text("Are you sure you want to delete your account? This cannot be undone.")
                    .font(.sora(16))
                    .multilineTextAlignment(.center)
                                
                HStack {
                    RoundedButton(label: "Cancel", color: .black, outlined: true) {
                        showDeleteAccountConfirm = false
                    }
                    RoundedButton(label: "Delete", color: .red400, loading: usernameChanging) {
                        deleteAccount()
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(11)
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(.gray100, lineWidth: 1)
            }
            .padding(16)
        }

        .navigationBarBackButtonHidden()
    }
}

#Preview {
    UserSettingsPage(user: Mock.appUser, userData: Mock.userData)
}
