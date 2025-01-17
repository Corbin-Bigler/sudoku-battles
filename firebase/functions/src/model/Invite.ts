import { DocumentReference, Timestamp } from "firebase-admin/firestore";
import { Difficulty } from "./Difficulty";

export type Invite = {
    inviter: DocumentReference,
    invitee: DocumentReference,
    difficulty: Difficulty,
    game: DocumentReference | null,
    created: Timestamp
}