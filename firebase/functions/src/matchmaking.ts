import { onCall } from 'firebase-functions/v2/https'
import { Timestamp } from 'firebase-admin/firestore';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const matchmakingTimeout = (8 * 1000) // 8 seconds

enum Status {
    Unauthorized = "unauthorized",
    Unmatched = "unmatched",
    Matched = "matched"
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

    const games = db.collection('games')
    const users = db.collection('users')

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
        const board = "530070000600195000098000060800060003400803001700020006060000280000419005000080079"
        const gameData = {
            "firstPlayer": users.doc(uid),
            "secondPlayer": filteredDocs[0].data().user,
            "firstPlayerBoard": board,
            "secondPlayerBoard": board,
            "startTime": Timestamp.fromMillis(Timestamp.now().toMillis() + 5000),
            "given": board
        };
        const newGameRef = games.doc();
        await newGameRef.set(gameData)

        otherMatchmakingRef.update({game: newGameRef})

        return JSON.stringify({
            status: Status.Matched,
            game: newGameRef.id
        })
    }
})