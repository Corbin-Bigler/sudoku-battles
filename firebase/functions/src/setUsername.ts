import * as admin from 'firebase-admin';
import { onCall } from 'firebase-functions/v2/https'

const db = admin.firestore();

enum Status {
    Success = "success",
    ServerError = "serverError",
    InvalidRequest = "invalidRequest",
    Unauthorized = "unauthorized",
    UsernameTaken = "usernameTaken"
}

const usernameRegex = /^[a-zA-Z0-9._-]{4,30}$/;

function response(status: Status): String {
    return JSON.stringify({status: status })
}
  
export const setUsername = onCall(async (request) => {
    const uid = request.auth?.uid;
    if(!uid) return response(Status.Unauthorized)

    const data = request.data;

    const username: string | null = typeof data.username === 'string' ? data.username.trim() : null;
    if(!username) return response(Status.InvalidRequest);
    if(!usernameRegex.test(username)) return response(Status.InvalidRequest)
          
    const users = db.collection("users")

    const usernameQuery = await users.where('usernameLowercase', '==', username.toLowerCase()).get();
    if (!usernameQuery.empty) return response(Status.UsernameTaken)
  
    const reference = users.doc(uid);
    try {
        await reference.set({ 
            "username": username,
            "usernameLowercase": username.toLowerCase()
        }, { merge: true });
        return response(Status.Success)
    } catch (error) {
        return response(Status.ServerError)
    }
})