import { DocumentReference, Timestamp } from "firebase-admin/firestore";

export type Matchmaking = {
    duel: DocumentReference,
    timestamp: Timestamp,
    user: DocumentReference
}