import SwiftUI

struct PlayPage: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var navState: NavigationState
    @ObservedObject var gamesState = GamesState.shared

    let user: AppUser
    let userData: UserData
    
    var backgroundColor: Color { colorScheme == .dark ? .gray900 : .white }
    var foregroundColor: Color { colorScheme == .dark ? .white : .black }
    
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
                    }
                    .frame(width: 40, height: 40)
                    .circleButton(outline: foregroundColor) {
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
                }
                .frame(width: 40, height: 40)
                .circleButton(outline: foregroundColor) {
                    navState.navigate { UserSettingsPage(user: user, userData: userData) }
                }
            }
            .foregroundStyle(foregroundColor)
            
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 150, height: 150)
                    .shadow(color: Color.blue400, radius: 90)
                Image("SudokuBattlesLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            
            VStack(spacing: 22) {
                Spacer().frame(height: 50)
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

//                    Button(action: {
//                        navState.navigate { InvitePage() }
//                    }) {
//                        HStack(spacing: 16) {
//                            Image("FriendsIcon")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 50, height: 50)
//                            Text("Challenge Friends")
//                                .font(.sora(22, .bold))
//                        }
//                        .padding(16)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color.yellow400)
//                        .cornerRadius(15)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                                .stroke(.yellow500, lineWidth: 2)
//                        )
//                    }
                }
                .foregroundStyle(.white)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
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
