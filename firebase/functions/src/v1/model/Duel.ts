import { DocumentReference, Timestamp } from "firebase-admin/firestore";

export type Duel = {
    firstPlayer: DocumentReference,
    firstPlayerBoard: string,
    given: string,
    secondPlayer: DocumentReference,
    secondPlayerBoard: string,
    startTime: Timestamp,
    sudoku: DocumentReference
}