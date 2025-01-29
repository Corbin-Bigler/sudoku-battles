import FirebaseAuth

struct AppUser {
    let uid: String
    let authUser: User?
    
    init(uid: String, user: User? = nil) {
        self.uid = uid
        self.authUser = user
    }
    init(_ authUser: User) {
        self.uid = authUser.uid
        self.authUser = authUser
    }
}
