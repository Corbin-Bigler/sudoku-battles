import * as admin from 'firebase-admin';
import { onCall } from 'firebase-functions/v2/https'
import { InviteStatus } from './model/InviteStatus';
import { Invite } from './model/Invite';
import { Timestamp } from 'firebase-admin/firestore';
import attemptGetRandomSudoku from './utility/attemptGetRandomSudoku';
import { PlayerDuel } from './model/PlayerDuel';

const db = admin.firestore();
const users = db.collection("users")
const playerDuels = db.collection('player-duels')

function response(status: InviteStatus, duelPath: String | null = null): String {
    return JSON.stringify({ status, data: {duelPath}})
}

export const acceptInvite = onCall(async (request) => {
    const uid = request.auth?.uid;
    if (!uid) return response(InviteStatus.Unauthorized)

    const inviteeReference = users.doc(uid)

    const data = request.data;

    const invitePath: string | null = typeof data.invitePath === 'string' ? data.invitePath.trim() : null;
    if (!invitePath) return response(InviteStatus.InvalidRequest);

    try {            
        const inviteReference = db.doc(invitePath)
        const inviteSnapshot = await inviteReference.get()
        if (!inviteSnapshot.exists) return response(InviteStatus.InvalidRequest);
        
        const invite = inviteSnapshot.data() as Invite
        if(inviteeReference.id != invite.invitee.id) { return response(InviteStatus.Unauthorized) }

        var randomGame = await attemptGetRandomSudoku(db, invite.difficulty)
        let randomSudoku = randomGame?.data()?.puzzle
        if(randomGame == null || !randomSudoku) { return response(InviteStatus.ServerError) }

        const duel: PlayerDuel = {
            "firstPlayer": invite.inviter,
            "secondPlayer": invite.invitee,
            "firstPlayerBoard": randomSudoku,
            "secondPlayerBoard": randomSudoku,
            "startTime": Timestamp.fromMillis(Timestamp.now().toMillis() + 3000),
            "given": randomSudoku,
            "sudoku": randomGame.ref,
            "winner": null
        };
        const newPlayerDuelRef = playerDuels.doc();
        await newPlayerDuelRef.set(duel)
        
        inviteReference.update({game: newPlayerDuelRef})

        return response(InviteStatus.Success, newPlayerDuelRef.path)
    } catch (error) {
        console.error(error)
        return response(InviteStatus.ServerError)
    }
})