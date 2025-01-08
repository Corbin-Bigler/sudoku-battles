import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https'

const db = admin.firestore();
const users = db.collection("users")
const invites = db.collection("invites")


function createInviteMessage(fcmToken: string, inviterUsername: String, inviteId: String): any {
    return {
        token: fcmToken,
        notification: {
            title: "Sudoku Battles",
            body: `${inviterUsername} has invited you to a duel!`,
        },
        data: {
            inviteId: "inviteId"
        },
    }
}

enum Status {
    Success = "success",
    ServerError = "serverError",
    InvalidRequest = "invalidRequest",
    Unauthorized = "unauthorized"
}

function response(status: Status): String {
    return JSON.stringify({ status: status })
}

export const invite = onCall(async (request) => {
    const uid = request.auth?.uid;
    if (!uid) return response(Status.Unauthorized)

    const inviterReference = users.doc(uid)
    const inviter = (await inviterReference.get()).data()
    console.log("inviter: " + inviter)
    if (!inviter) return response(Status.ServerError);
    const inverterUsername = inviter.username
    console.log("inverterUsername: " + inverterUsername)
    if(!inverterUsername) return response(Status.ServerError)

    const data = request.data;

    const inviteeUid: string | null = typeof data.invitee === 'string' ? data.invitee.trim() : null;
    if (!inviteeUid) return response(Status.InvalidRequest);

    const inviteeReference = users.doc(inviteeUid)
    const inviteeSnapshot = await inviteeReference.get()
    if (!inviteeSnapshot.exists) return response(Status.InvalidRequest);


    try {
        const inviteReference = invites.doc()
        await inviteReference.set({
            "inviter": inviterReference,
            "invitee": inviteeReference,
            "created": Timestamp.now()
        }, { merge: true });

        const invitee = inviteeSnapshot.data()
        const fcmTokens = invitee?.fcmTokens
        if (fcmTokens) {
            for (const key in fcmTokens) {
                if (fcmTokens.hasOwnProperty(key)) {
                    await admin.messaging().send(createInviteMessage(fcmTokens[key], inverterUsername, inviteReference.id));
                }
            }
        }

        return response(Status.Success)
    } catch (error) {
        console.log(error)
        return response(Status.ServerError)
    }
})