import * as admin from 'firebase-admin';
import { onCall } from 'firebase-functions/v2/https'

const storage = admin.storage().bucket()
const db = admin.firestore();
const auth = admin.auth()
const users = db.collection("users")

enum Status {
    Success = "success",
    ServerError = "serverError",
    Unauthorized = "unauthorized"
}

function response(status: Status): String {
    return JSON.stringify({status: status })
}
  
export const deleteAccount = onCall(async (request) => {
    const uid = request.auth?.uid;
    if(!uid) return response(Status.Unauthorized)
          
    try {
        await auth.deleteUser(uid)
        await users.doc(uid).delete()
        await storage.deleteFiles({prefix: `${uid}/`})
        return response(Status.Success)
    } catch (error) {
        return response(Status.ServerError)
    }
})