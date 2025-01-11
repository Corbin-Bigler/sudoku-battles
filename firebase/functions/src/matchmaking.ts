import { onCall } from 'firebase-functions/v2/https'
import { DocumentSnapshot, Timestamp } from 'firebase-admin/firestore';
import * as admin from 'firebase-admin';
import { MatchmakingStatus } from './model/MatchmakingStatus';
import { Matchmaking } from './model/Matchmaking';
import { Duel } from './model/Duel';

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

const matchmakingTimeout = (8 * 1000)
const botTimeout = 1 //(15 * 1000)

async function attemptGetRandomSudoku(): Promise<DocumentSnapshot | null> {
    for(let i = 0; i < 3; i++) {
        const randomValue = sudoku.easy.doc().id
        const queryRef = sudoku.easy
            .where("__name__", '>=', randomValue)
            .orderBy("__name__")
            .limit(1);
        
        try {        
            const randomSnapshot = await queryRef.get();
            if (randomSnapshot.empty) return null
            
            if(randomSnapshot != null) {
                return randomSnapshot.docs[0]
            }    
        } catch (error) {
            console.error(error)
        }
    }
    return null
}


export const matchmaking = onCall({
    maxInstances: 1
}, async (request) => {
    const unsafeUid = request.auth?.uid;
    if(!unsafeUid) JSON.stringify({status: MatchmakingStatus.Unauthorized})
    const uid = unsafeUid as string

    const recentTimestamp = Timestamp.fromMillis(Timestamp.now().toMillis() - matchmakingTimeout);

    const matchmaking = db.collection('matchmaking')

    try {
        const querySnapshot = await matchmaking
        .where('game', '==', null)
        .where('timestamp', '>=', recentTimestamp)
        .get();

        const filteredDocs = querySnapshot.docs.filter(doc => doc.id !== uid)
        if(filteredDocs.length == 0) {
            const matchmakingRef = matchmaking.doc(uid)

            if(querySnapshot.docs.length > 0) {
                let matchmakingSnap = querySnapshot.docs[0]
                let matchmakingData = matchmakingSnap.data() as Matchmaking

                const nowInMillis = Timestamp.now().toMillis();
                const startInMillis = matchmakingData.start.toMillis();

                if(nowInMillis - startInMillis >= botTimeout) {
                    var randomGame = await attemptGetRandomSudoku()
                    let randomSudoku = randomGame?.data()?.puzzle
                    if(randomGame == null || !randomSudoku) {
                        return JSON.stringify({ status: MatchmakingStatus.ServerError })    
                    }

                    console.log(randomSudoku)
                    console.log("YOU REALLY NEED A BOT")
                    const gameData: Duel = {
                        "firstPlayer": users.doc(uid),
                        "secondPlayer": null,
                        "firstPlayerBoard": randomSudoku,
                        "secondPlayerBoard": null,
                        "startTime": Timestamp.fromMillis(Timestamp.now().toMillis() + 3000),
                        "given": randomSudoku,
                        "sudoku": randomGame.ref,
                        "botEndTime": Timestamp.fromMillis(Timestamp.now().toMillis() + (5 * 60000))
                    };
                    const newDuelRef = duels.doc();
                    await newDuelRef.set(gameData)

                    return JSON.stringify({
                        status: MatchmakingStatus.Matched,
                        data: {duel: newDuelRef.id}
                    })
                } else {
                    await matchmakingRef.update({
                        timestamp: Timestamp.now()
                    })
                    return JSON.stringify({
                        status: MatchmakingStatus.Unmatched,
                        data: {matchmaking: matchmakingSnap.ref}
                    })        
                }
            } else {
                await matchmakingRef.set({
                    user: users.doc(uid),
                    timestamp: Timestamp.now(),
                    game: null,
                    start: Timestamp.now()
                })
                return JSON.stringify({
                    status: MatchmakingStatus.Unmatched,
                    data: {matchmaking: matchmakingRef.id} 
                })
            }
        } else {
            const otherMatchmakingRef = filteredDocs[0].ref

            var randomGame = await attemptGetRandomSudoku()
            let randomSudoku = randomGame?.data()?.puzzle
            if(randomGame == null || !randomSudoku) {
                return JSON.stringify({ status: MatchmakingStatus.ServerError })    
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
                status: MatchmakingStatus.Matched,
                data: {duel: newDuelRef.id}
            })
        }
    } catch (error) {
        console.error(error)
        return JSON.stringify({status: MatchmakingStatus.ServerError})
    }
})