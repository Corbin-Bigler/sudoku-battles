import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https'
import { SetUsernameStatus } from './model/SetUsernameStatus';

const db = admin.firestore();

const usernameRegex = /^[a-zA-Z0-9._'’-]{4,30}$/;
const changeUsernameTimeout = 30 * 24 * 60 * 60 * 1000

function response(status: SetUsernameStatus): String {
    return JSON.stringify({status})
}
  
export const setUsername = onCall(async (request) => {
    const uid = request.auth?.uid;
    if(!uid) return response(SetUsernameStatus.Unauthorized)
    
    const data = request.data;
    console.log(data)
    const username: string | null = typeof data.username === 'string' ? data.username.trim() : null;
    if(!username) return response(SetUsernameStatus.InvalidUsername);
    if(!usernameRegex.test(username)) return response(SetUsernameStatus.InvalidUsername)

    const users = db.collection("users")

    try { 
        const usernameChangedAt = (await users.doc(uid).get())?.data()?.usernameChangedAt
        if(usernameChangedAt) {
            const lastChangedDate = usernameChangedAt.toDate();
            const currentDate = new Date();
            const differenceInTime = currentDate.getTime() - lastChangedDate.getTime();
            const hasBeenOneMonth = differenceInTime >= changeUsernameTimeout;

            if (!hasBeenOneMonth) {
                return response(SetUsernameStatus.InvalidUsername)
            }
        }
    } catch {
        return response(SetUsernameStatus.InvalidUsername)
    }
 
    try {
        const usernameQuery = await users.where('usernameLowercase', '==', username.toLowerCase()).get();
        console.log(usernameQuery.empty)
        if (!usernameQuery.empty) return response(SetUsernameStatus.UsernameTaken)
        
        const reference = users.doc(uid);

        let data: any = { 
            "username": username,
            "usernameLowercase": username.toLowerCase(),
            "usernameChangedAt": Timestamp.now()
        }
        if(!(await reference.get()).exists) data.ranking = 100
        
        await reference.set(data, { merge: true });
        return response(SetUsernameStatus.Success)
    } catch (error) {
        return response(SetUsernameStatus.ServerError)
    }
})