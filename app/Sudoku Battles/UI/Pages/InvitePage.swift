import SwiftUI

struct InvitePage: View {
    @State private var status: String?
    @State private var username = ""
    @State private var results: [String : UserData] = [:]
    
    @State private var debounceWorkItem: DispatchWorkItem?
    func sendResultsRequest() {
        debounceWorkItem?.cancel()
        
        guard username.count >= 3 else { return }
        debounceWorkItem = DispatchWorkItem { Task {
            results = (try? await FirestoreDs.shared.getUserDatas(usernamePartial: username)) ?? [:]
        } }
        
        if let workItem = debounceWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Invite Page")
                if let status { Text("Status: \(status)") }
                
                let binding = Binding(
                    get: { username },
                    set: {
                        username = $0
                        sendResultsRequest()
                    }
                )
                TextField("Username", text: binding)
                    .textInputAutocapitalization(.never)
                    
                ForEach(Array(results), id: \.key) { key, value in
                    HStack {
                        Button(action:{
                            Task {
                                do {
                                    let response = try await FunctionsDs.shared.sendInvite(uid: key)
                                    self.status = "\(response.status)"
                                } catch {
                                    self.status = "ERROR"
                                }
                            }
                        }) {
                            Text("Invite")
                        }
                        Text(value.username)
                        Text(key)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    InvitePage()
}
