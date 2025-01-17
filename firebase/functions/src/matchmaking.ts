import { onCall } from 'firebase-functions/v2/https'
import { Timestamp } from 'firebase-admin/firestore';
import * as admin from 'firebase-admin';
import { MatchmakingStatus } from './model/MatchmakingStatus';
import { Matchmaking } from './model/Matchmaking';
import { BotDuel } from './model/BotDuel';
import attemptGetRandomSudoku from './utility/attemptGetRandomSudoku';
import { Difficulty } from './model/Difficulty';
import { PlayerDuel } from './model/PlayerDuel';
// import { PlayerDuel } from './model/PlayerDuel';

const db = admin.firestore();
const botDuels = db.collection('bot-duels')
const playerDuels = db.collection('player-duels')
const users = db.collection('users')

const matchmakingTimeout = (8 * 1000)
const botTimeout = (9 * 1000)

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
                    var randomGame = await attemptGetRandomSudoku(db, Difficulty.Easy)
                    let randomSudoku = randomGame?.data()?.puzzle
                    if(randomGame == null || !randomSudoku) {
                        return JSON.stringify({ status: MatchmakingStatus.ServerError })    
                    }

                    let userSnap = await users.doc(uid).get()
                    let userData = userSnap.data()

                    let startTime = Timestamp.fromMillis(Timestamp.now().toMillis() + 3000)
                    const botDuelData: BotDuel = {
                        startTime: startTime,
                        player: users.doc(uid),
                        playerBoard: randomSudoku,
                        endTime: null,
                        given: randomSudoku,
                        botEndTime: Timestamp.fromMillis(startTime.toMillis() + 300000),
                        botRanking: userData?.ranking ?? 100,
                        sudoku: randomGame.ref,
                    }
                    const newBotDuelRef = botDuels.doc();
                    await newBotDuelRef.set(botDuelData)

                    return JSON.stringify({
                        status: MatchmakingStatus.Matched,
                        data: {duelPath: newBotDuelRef.path}
                    })
                } else {
                    await matchmakingRef.update({
                        timestamp: Timestamp.now()
                    })
                    return JSON.stringify({
                        status: MatchmakingStatus.Unmatched,
                        data: {matchmakingPath: matchmakingSnap.ref.path}
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
                    data: {matchmakingPath: matchmakingRef.path} 
                })
            }
        } else {
            const otherMatchmakingRef = filteredDocs[0].ref

            var randomGame = await attemptGetRandomSudoku(db, Difficulty.Easy)
            let randomSudoku = randomGame?.data()?.puzzle
            if(randomGame == null || !randomSudoku) {
                return JSON.stringify({ status: MatchmakingStatus.ServerError })    
            }

            const gameData: PlayerDuel = {
                "firstPlayer": users.doc(uid),
                "secondPlayer": filteredDocs[0].data().user,
                "firstPlayerBoard": randomSudoku,
                "secondPlayerBoard": randomSudoku,
                "startTime": Timestamp.fromMillis(Timestamp.now().toMillis() + 3000),
                "given": randomSudoku,
                "sudoku": randomGame.ref,
                "winner": null
            };
            const newPlayerDuelRef = playerDuels.doc();
            await newPlayerDuelRef.set(gameData)

            otherMatchmakingRef.update({game: newPlayerDuelRef})

            return JSON.stringify({
                status: MatchmakingStatus.Matched,
                data: {duelPath: newPlayerDuelRef.path}
            })
        }
    } catch (error) {
        console.error(error)
        return JSON.stringify({status: MatchmakingStatus.ServerError})
    }
})