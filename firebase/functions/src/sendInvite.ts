import * as admin from 'firebase-admin';
import { onCall } from 'firebase-functions/v2/https'
import { InviteStatus } from './model/InviteStatus';
import { decodeDifficulty, Difficulty } from './model/Difficulty';
import { Invite } from './model/Invite';
import { Timestamp } from 'firebase-admin/firestore';
import { UserData } from './model/UserData';

const db = admin.firestore();
const users = db.collection("users")
const invites = db.collection("invites")

function createInviteMessage(fcmToken: string, inviterUsername: String, invitePath: String): any {
    return {
        token: fcmToken,
        notification: {
            title: "Sudoku Battles",
            body: `${inviterUsername} has invited you to a duel!`,
        },
        data: {
            invitePath
        },
    }
}

function response(status: InviteStatus, invitePath: String | null = null): String {
    return JSON.stringify({ status, data: {invitePath}})
}

export const sendInvite = onCall(async (request) => {
    const uid = request.auth?.uid;
    if (!uid) return response(InviteStatus.Unauthorized)

    const inviterReference = users.doc(uid)
    const inviter = (await inviterReference.get()).data()

    if (!inviter) {
        console.error("Could not get inviter user data")
        return response(InviteStatus.ServerError);
    }
    const inverterUsername = inviter.username
    if(!inverterUsername) {
        console.error("Could not get inviter username")
        return response(InviteStatus.ServerError)
    }

    const data = request.data;

    const inviteeUid: string | null = typeof data.invitee === 'string' ? data.invitee.trim() : null;
    if (!inviteeUid) return response(InviteStatus.InvalidRequest);
    const difficulty: Difficulty | null = decodeDifficulty(data.difficulty);
    if (!difficulty) return response(InviteStatus.InvalidRequest);

    const inviteeReference = users.doc(inviteeUid)
    const inviteeSnapshot = await inviteeReference.get()
    if (!inviteeSnapshot.exists) return response(InviteStatus.InvalidRequest);

    try {
        const invite: Invite = {
            inviter: inviterReference,
            invitee: inviteeReference,
            difficulty: difficulty,
            game: null,
            created: Timestamp.now()
        }

        const inviteReference = invites.doc()
        await inviteReference.set(invite);

        const invitee = inviteeSnapshot.data() as UserData
        const fcmTokens = invitee?.fcmTokens
        if (fcmTokens) {
            for (const key in fcmTokens) {
                if (fcmTokens.hasOwnProperty(key)) {
                    try {
                        await admin.messaging().send(createInviteMessage(fcmTokens[key], inverterUsername, inviteReference.path));
                    } catch (error) {
                        console.error(error)
                    }
                }
            }
        }

        return response(InviteStatus.Success, inviteReference.path)
    } catch (error) {
        console.error(error)
        return response(InviteStatus.ServerError)
    }
})