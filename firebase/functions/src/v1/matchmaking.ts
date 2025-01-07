import { onCall } from 'firebase-functions/v2/https'
import { DocumentSnapshot, Timestamp } from 'firebase-admin/firestore';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const duels = db.collection('duels')
const users = db.collection('users')
const sudoku = {
    easy: db.collection("sudoku-easy"),
    medium: db.collection("sudoku-medium"),
    hard: db.collection("sudoku-hard"),
    extreme: db.collection("sudoku-extreme"),
    inhuman: db.collection("sudoku-inhuman")
}

const matchmakingTimeout = (8 * 1000) // 8 seconds

enum Status {
    ServerError = "serverError",
    Unauthorized = "unauthorized",
    Unmatched = "unmatched",
    Matched = "matched"
}


async function attemptGetRandomSudoku(): Promise<DocumentSnapshot | null> {
    const randomValue = sudoku.easy.doc().id
    console.log(`random value: ${randomValue}`)
    const queryRef = sudoku.easy
        .where("__name__", '>=', randomValue)
        .orderBy("__name__")
        .limit(1);
    
    try {        
        const snapshot = await queryRef.get();
        if (snapshot.empty) return null
        return snapshot.docs[0]
    } catch (error) {
        console.error('Error fetching documents: ', error);
        return null
    }
}

export const matchmaking = onCall({
    maxInstances: 1
}, async (request) => {
    const unsafeUid = request.auth?.uid;
    if(!unsafeUid) JSON.stringify({status: Status.Unauthorized})
    const uid = unsafeUid as string

    const recentTimestamp = Timestamp.fromMillis(Timestamp.now().toMillis() - matchmakingTimeout);

    const matchmaking = db.collection('matchmaking')
    const querySnapshot = await matchmaking
        .where('game', '==', null)
        .where('timestamp', '>=', recentTimestamp)
        .get();

    const filteredDocs = querySnapshot.docs.filter(doc => doc.id !== uid)
    if(filteredDocs.length == 0) {
        console.log('No other players for matchmaking found');
        const matchmakingRef = matchmaking.doc(uid)
        await matchmakingRef.set({
            user: users.doc(uid),
            timestamp: Timestamp.now(),
            game: null
        })
        return JSON.stringify({
            status: Status.Unmatched,
            matchmaking: matchmakingRef.id
        })
    } else {
        const otherMatchmakingRef = filteredDocs[0].ref

        // try three times to get a random doc if not throw error
        var randomGame: DocumentSnapshot | null = null
        for(let i = 0; i < 3; i++) {
            const randomSnapshot = await attemptGetRandomSudoku()
            if(randomSnapshot != null) {
                randomGame = randomSnapshot
                break
            }
        }
        let randomSudoku = randomGame?.data()?.puzzle
        if(randomGame == null || !randomSudoku) {
            
            return JSON.stringify({ status: Status.ServerError })    
        }
        

        const gameData = {
            "firstPlayer": users.doc(uid),
            "secondPlayer": filteredDocs[0].data().user,
            "firstPlayerBoard": randomSudoku,
            "secondPlayerBoard": randomSudoku,
            "startTime": Timestamp.fromMillis(Timestamp.now().toMillis() + 3000),
            "given": randomSudoku,
            "difficulty": "easy",
            "sudoku": randomGame.ref
        };
        const newDuelRef = duels.doc();
        await newDuelRef.set(gameData)

        otherMatchmakingRef.update({game: newDuelRef})

        return JSON.stringify({
            status: Status.Matched,
            duel: newDuelRef.id
        })
    }
})