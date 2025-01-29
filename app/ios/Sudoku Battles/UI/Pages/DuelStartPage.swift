//
//  DuelView.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/15/25.
//
import SwiftUI

struct DuelStartPage: View {
    @ObservedObject var duelRepo: DuelRepo
    @State var subscribing: Bool = true
    
    var user: AppUser
    var userData: UserData

    var secondsSinceStart: Int {
        Int(Date().timeIntervalSince1970) - Int(duelRepo.startTime.seconds)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            if subscribing {
                Text("FOUND A DUEL")
                    .foregroundStyle(.white)
                    .font(.sora(14, .semibold))
                    .kerning(1.4)
                    .onAppear {
                        Task {
                            try? await duelRepo.subscribe()
                            Main {subscribing = false}
                        }
                    }
            } else if secondsSinceStart >= 0 {
                DuelPage(duelRepo: duelRepo, user: user, userData: userData)
                    .frame(maxHeight: .infinity)
                    .background(.white)
            } else {
                VStack {
                    Text("STARTING IN")
                        .font(.sora(14, .semibold))
                        .kerning(1.4)
                    let startingIn = abs(secondsSinceStart)
                    Spacer()
                        .frame(height: 20)
                    ZStack {
                        let transition = AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
                        
                        Text("\(startingIn)")
                            .frame(maxWidth: .infinity)
                            .font(.sora(96, .semibold))
                            .id(startingIn)
                            .transition(transition)
                            .animation(.easeInOut(duration: 0.5), value: startingIn)
                    }
                }
                .foregroundStyle(.white)
            }
        }
    }
}
