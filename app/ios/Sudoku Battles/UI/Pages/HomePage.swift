import SwiftUI
import FirebaseFirestore

struct HomePage: View {
    @EnvironmentObject private var authState: AuthenticationState
    @EnvironmentObject private var navState: NavigationState

    let user: AppUser
    let userData: UserData
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 40) {
                HStack {
                    Spacer()
                    ZStack {
                        Image("GearIcon")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.black)
                    }
                    .frame(width: 40, height: 40)
                    .circleButton(outline: .black) {
                        navState.navigate { UserSettingsPage(user: user, userData: userData) }
                    }
                }
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 150, height: 150)
                        .shadow(color: Color.blue.opacity(0.5), radius: 90)
                    Image("SudokuBattlesLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                
                VStack(spacing: 20) {
                    Text("WAITING FOR YOU")
                        .font(.sora(14, .semibold))
                        .kerning(1.4)
                    Text("WAITING FOR RESPONSE")
                        .font(.sora(14, .semibold))
                        .kerning(1.4)
                    Spacer()
                }
            }
            .padding(16)
            RoundedButton(label: "Play", color: .blue400, outlined: false) {
                navState.navigate {
                    PlayPage(user: user, userData: userData)
                }
            }
            .padding(16)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray400),
                alignment: .top
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("SplatterNoise")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .offset(y: -200)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    HomePage(user: Mock.appUser, userData: Mock.userData)
}
