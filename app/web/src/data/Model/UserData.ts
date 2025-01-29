import { Timestamp } from "firebase/firestore"

export default class UserData {
    username: String
    usernameChangedAt: Timestamp | null
    ranking: number

    constructor(username: string, ranking: number) {
        this.username = username
        this.usernameChangedAt = null
        this.ranking = ranking
    }
}