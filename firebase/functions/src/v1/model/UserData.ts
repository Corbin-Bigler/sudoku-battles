import { Timestamp } from "firebase-admin/firestore";

export type UserData = {
    fcmTokens: { [key: string]: string },
    username: string,
    usernameChangedAt: Timestamp,
    usernameLowercase: string
}