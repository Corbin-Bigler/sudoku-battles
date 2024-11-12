import SwiftUI

struct PlayPage: View {
    @EnvironmentObject private var navState: NavigationState
    @ObservedObject var gamesState = GamesState.shared

    let user: AppUser
    let userData: UserData

    var body: some View {
        VStack(spacing: 40) {
            HStack(spacing: 0) {
                if gamesState.games.isEmpty {
                    Spacer()
                        .frame(width: 40, height: 40)
                } else {
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
                }
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
            
            VStack(spacing: 22) {
                Text("READY TO START PLAYING?")
                    .font(.sora(14, .semibold))
                    .kerning(1.4)
                VStack(spacing: 10) {
                    Button(action: {
                        navState.navigate { DifficultyPage() }
                    }) {
                        HStack(spacing: 16) {
                            Image("AloneIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            Text("Play Alone")
                                .font(.sora(22, .bold))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.green400)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.green500, lineWidth: 2)
                        )
                    }

                    Button(action: {
                        Main {
                            navState.navigate { MatchmakingPage(user: user, userData: userData) }
                        }
                    }) {
                        HStack(spacing: 16) {
                            Image("DuelIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            Text("Find a Duel")
                                .font(.sora(22, .bold))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.purple400)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.purple500, lineWidth: 2)
                        )
                    }

                    Button(action: {
                        navState.navigate { InvitePage() }
                    }) {
                        HStack(spacing: 16) {
                            Image("FriendsIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            Text("Challenge Friends")
                                .font(.sora(22, .bold))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.yellow400)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.yellow500, lineWidth: 2)
                        )
                    }
                }
                .foregroundStyle(.white)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .padding(16)
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
    PlayPage(user: Mock.appUser, userData: Mock.userData)
}
