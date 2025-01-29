import { type User } from "firebase/auth"

export default class AppUser {
    uid: string
    authUser: User | null

    constructor(user: User) {
        this.uid = user.uid
        this.authUser = user
    }
}