import SwiftUI

struct InvitePage: View {
    @EnvironmentObject private var navState: NavigationState
    @Environment(\.colorScheme) var colorScheme

    @State private var username = ""
    @State private var results: [String : UserData] = [:]
    @State private var recents: [String]
    @State private var recentsResults: [String : UserData] = [:]
    @State private var loading = false
    @State private var sendingInvite = false
    @State private var selectedUser: String?
    @State private var difficultyIndex = 0
    @State private var gameVariantIndex = 0
    @State private var waiting = false
    @State private var error: InviteStatus?
    @State private var duelRepo: DuelRepo?

    let user: AppUser
    var userData: UserData

    var difficulty: Difficulty { Difficulty.allCases[difficultyIndex] }
    var gameVariant: GameVariant { GameVariant.allCases[gameVariantIndex] }
    
    init(user: AppUser, userData: UserData, duelRepo: DuelRepo? = nil) {
        self.user = user
        self.userData = userData
        self._duelRepo = .init(wrappedValue: duelRepo)
        recents = UserDefaultsDs.shared.getRecentInvites()
    }

    @State private var debounceWorkItem: DispatchWorkItem?
    func sendRecentResultsRequest() {
        debounceWorkItem?.cancel()
        
        debounceWorkItem = DispatchWorkItem { Task {
            Main {self.loading = true}
            print(recents)
            if let recentsResults = try? await FirestoreDs.shared.queryUserDatas(uids: recents) {
                print(recentsResults)
                Main { self.recentsResults = recentsResults }
            }
            Main {self.loading = false}
        } }
        
        if let workItem = debounceWorkItem {
            DispatchQueue.main.async(execute: workItem)
        }
    }
    func sendResultsRequest() {
        debounceWorkItem?.cancel()
        results = [:]
        
        guard username.count >= 3 else { return }
        debounceWorkItem = DispatchWorkItem { Task {
            Main {self.loading = true}
            results = (try? await FirestoreDs.shared.queryUserDatas(usernamePartial: username)) ?? [:]
            Main {self.loading = false}
        } }
        
        if let workItem = debounceWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
        }
    }
    
    var backgroundColor: Color { colorScheme == .dark ? .gray900 : .white }
    var foregroundColor: Color { colorScheme == .dark ? .white : .gray900 }
    
    var errorTitle: String {
        switch error {
        case .success: return ""
        case .serverError: return "Server Error"
        case .invalidRequest, .unauthorized: return "App Error"
        case nil: return ""
        }
    }
    var errorBody: String {
        switch error {
        case .success: return ""
        case .serverError: return "An server error has occured. Please try again later."
        case .invalidRequest, .unauthorized: return "An unknown app error has occured. Check the app store for updates."
        case nil: return ""
        }
    }
    
    var body: some View {
        VStack {
            if let duelRepo {
                DuelStartPage(duelRepo: duelRepo, user: user, userData: userData)
            } else {
                HStack(spacing: 0) {
                    ZStack {
                        Image("ChevronIcon")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12)
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 40, height: 40)
                    .circleButton(outline: .white) {
                        if waiting {
                            InviteRepo.shared.cancelInvite()
                            waiting = false
                        } else if selectedUser != nil {
                            withAnimation {
                                selectedUser = nil
                            }
                        } else {
                            navState.navigate(back: 1)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    Image("FriendsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)

                    if waiting {
                        Spacer().frame(height: 20)
                        Text("WAITING FOR OPPONENT...")
                            .font(.sora(14, .semibold))
                            .kerning(1.4)
                            .foregroundStyle(.white)
                    } else if let selectedUser {
                        VStack {
                            Spacer().frame(height: 40)
                            
                            VStack(spacing: 0) {
                                VStack(spacing: 8) {
                                    let gameVariantBinding = Binding(
                                        get: { gameVariantIndex },
                                        set: { gameVariantIndex = $0 }
                                    )
                                    HorizontalSelector(options: GameVariant.allCases, index: gameVariantBinding)
                                    
                                    let difficultyBinding = Binding(
                                        get: { difficultyIndex },
                                        set: { difficultyIndex = $0 }
                                    )
                                    HorizontalSelector(options: Difficulty.allCases, index: difficultyBinding)
                                }
                                
                                Spacer().frame(height: 30)
                                
                                VStack(spacing: 16) {
                                    let label = gameVariant == .duel ? "Send Invite" : "Start Game"
                                    RoundedButton(label: label, color: .white, loading: sendingInvite) {
                                        if gameVariant == .duel {
                                            sendingInvite = true
                                            Task {
                                                do {
                                                    try await InviteRepo.shared.startInvite(uid: selectedUser, difficulty: difficulty) { duelReference in
                                                        Task {
                                                            do {
                                                                let duelStrategy = try await PlayerDuelStrategy(duelReference, friendlyUid: user.uid)
                                                                Main {
                                                                    self.duelRepo = DuelRepo(strategy: duelStrategy)
                                                                    self.waiting = false
                                                                }
                                                            } catch {
                                                                logger.error("\(error)")
                                                            }
                                                        }
                                                    }
                                                    Main { self.waiting = true }
                                                    Main { self.sendingInvite = false }
                                                } catch {
                                                    logger.error("\(error)")
                                                    self.error = .invalidRequest
                                                }
                                            }
                                        }
                                    }
                                    .shadow(color: .yellow700.opacity(0.5), radius: 16, x: 0, y: 6)
                                }
                            }
                            .frame(width: 250)
                        }
                        .transition(.move(edge: .top))
                    }
                    
                    if selectedUser == nil {
                        Spacer().frame(height: 12)

                        VStack(spacing: 0) {
                            let usernameBinding = Binding<String>(
                                get: {username},
                                set: {
                                    username = $0
                                    sendResultsRequest()
                                }
                            )
                            
                            let inputFieldColor: Color = colorScheme == .dark ? .white : .gray600
                            InputField(text: usernameBinding, placeholder: "Search by username", color: inputFieldColor, leftIcon: Image("search-outline"))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                            
                            if loading {
                                Spacer()
                                LoadingIndicator(size: 35, color: .yellow400)
                                Spacer()
                            } else {
                                if results.isEmpty {
                                    Spacer().frame(height: 25)
                                    Text("RECENT")
                                        .font(.sora(14, .semibold))
                                        .kerning(1.4)
                                }
                                let source = results.isEmpty ? recentsResults : results
                                let filtered = Array(source).filter({ $0.key != user.uid })
                                ForEach(filtered, id: \.key) { (uid, userData) in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(userData.username)
                                                .font(.sora(16, .semibold))
                                            HStack(spacing: 8) {
                                                Text("Skill Rating:")
                                                    .font(.sora(14))
                                                Pill(text: String(userData.ranking), fontSize: 14, color: .blue400)
                                            }
                                        }
                                        
                                        Spacer()
                                        Image("ArrowIcon")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 12)
                                    }

                                    .frame(height: 75)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        UserDefaultsDs.shared.addRecentInvite(uid: uid)
                                        withAnimation {
                                            selectedUser = uid
                                        }
                                    }
                                }
                            }
                        }
                        .zIndex(1)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(16)
                        .background(backgroundColor)
                        .foregroundStyle(foregroundColor)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 25, topTrailingRadius: 25))
                        .transition(.move(edge: .bottom))
                    }
                }
                .ignoresSafeArea()
                .frame(maxHeight: .infinity)
            }
        }
        
        .onAppear {
            if !recents.isEmpty {
                sendRecentResultsRequest()
            }
        }
        .alert(errorTitle, isPresented: Binding(get: {error != nil}, set: {_ in error = nil})) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(errorBody)
        }
        .frame(maxHeight: .infinity)
        .background {
            ZStack {
                Color.yellow400
                Image("SquareNoise")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationContainerPreview {
        InvitePage(user: Mock.appUser, userData: Mock.userData)
    }
}
