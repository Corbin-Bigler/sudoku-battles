import * as admin from 'firebase-admin';
import { DocumentReference } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https'

const db = admin.firestore();
const duels = db.collection("duels")
const users = db.collection("users")

enum Status {
    Correct = "correct",
    Incorrect = "incorrect",
    ServerError = "serverError",
    InvalidRequest = "invalidRequest",
    Unauthorized = "unauthorized",
}
function response(status: Status): String {
    return JSON.stringify({status: status })
}
  
export const verifyDuelBoard = onCall(async (request) => {
    const uid = request.auth?.uid;
    if(!uid) return response(Status.Unauthorized)

    const data = request.data;

    const duelId: string | null = typeof data.duelId === 'string' ? data.duelId.trim() : null;
    if(!duelId) return response(Status.InvalidRequest);
          
    const duelRef = duels.doc(duelId);
    try {
        const duelData = (await duelRef.get()).data()
        const firstPlayer = duelData?.firstPlayer ? (duelData?.firstPlayer as DocumentReference) : null
        const secondPlayer = duelData?.secondPlayer ? (duelData?.secondPlayer as DocumentReference) : null
        const board = firstPlayer?.id == uid ? 
            (duelData?.firstPlayerBoard ? (duelData?.firstPlayerBoard as string) : null) : 
            secondPlayer?.id == uid ? 
            (duelData?.secondPlayerBoard ? (duelData?.secondPlayerBoard as string) : null) : null
        if(!board) throw ""

        const sudoku = duelData?.sudoku ? (duelData?.sudoku as DocumentReference) : null
        if(!sudoku) throw ""
        const sudokuData = (await sudoku.get()).data()
        const solution = sudokuData?.solution
        if(!solution) throw ""
        
        if(board == solution) {
            await duelRef.set({winner: users.doc(uid)}, {merge: true})
            return response(Status.Correct)
        } else {
            return response(Status.Incorrect)
        }
    } catch (error) {
        return response(Status.ServerError)
    }
})