import * as admin from 'firebase-admin';
import { DocumentReference } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https'
import { VerifyDuelBoardStatus } from './model/VerifyDuelBoardStatus';
import { BotDuel } from './model/BotDuel';

const db = admin.firestore();
const users = db.collection("users")

function response(status: VerifyDuelBoardStatus, endTime: Date | null = null): String {
    return JSON.stringify({status, endTime})
}
  
export const verifyDuelBoard = onCall(async (request) => {
    const uid = request.auth?.uid;
    if(!uid) return response(VerifyDuelBoardStatus.Unauthorized)

    const data = request.data;

    const duelPath: string | null = data.duelPath
    if(!duelPath) return response(VerifyDuelBoardStatus.InvalidRequest);
    const duelRef = db.doc(duelPath)

    try {
        if(duelPath.startsWith("bot-duels")) {
            const duelData = (await duelRef.get()).data() as BotDuel
            const board = duelData.playerBoard
            const sudoku = duelData?.sudoku ? (duelData?.sudoku as DocumentReference) : null
            if(!sudoku) throw ""
            const sudokuData = (await sudoku.get()).data()
            const solution = sudokuData?.solution
            if(!solution) throw ""

            if(board == solution) {
                let endTime = new Date()
                await duelRef.set({endTime}, {merge: true})
                return response(VerifyDuelBoardStatus.Correct)
            }
            
            return response(VerifyDuelBoardStatus.Incorrect) 
        } else if(duelPath.startsWith("player-duels")) {
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
                let endTime = new Date()
                await duelRef.set({winner: users.doc(uid), endTime }, {merge: true})
                return response(VerifyDuelBoardStatus.Correct)
            } else {
                return response(VerifyDuelBoardStatus.Incorrect)
            }    
        }
        return response(VerifyDuelBoardStatus.ServerError)
    } catch (error) {
        return response(VerifyDuelBoardStatus.ServerError)
    }
})