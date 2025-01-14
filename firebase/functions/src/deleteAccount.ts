import * as admin from 'firebase-admin';
import { onCall } from 'firebase-functions/v2/https'
import { DeleteAccountStatus } from './model/DeleteAccountStatus';

const storage = admin.storage().bucket()
const db = admin.firestore();
const auth = admin.auth()
const users = db.collection("users")
 
function response(status: DeleteAccountStatus): String {
    return JSON.stringify({status: status })
}
  
export const deleteAccount = onCall(async (request) => {
    const uid = request.auth?.uid;
    if(!uid) return response(DeleteAccountStatus.Unauthorized)
          
    try {
        await auth.deleteUser(uid)
        await users.doc(uid).delete()
        await storage.deleteFiles({prefix: `${uid}/`})
        return response(DeleteAccountStatus.Success)
    } catch (error) {
        return response(DeleteAccountStatus.ServerError)
    }
})