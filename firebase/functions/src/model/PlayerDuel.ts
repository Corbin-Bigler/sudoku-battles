import { DocumentReference, Timestamp } from "firebase-admin/firestore";

export type PlayerDuel = {
    firstPlayer: DocumentReference,
    firstPlayerBoard: string,
    secondPlayer: DocumentReference,
    secondPlayerBoard: string,
    given: string,
    startTime: Timestamp,
    sudoku: DocumentReference,
    winner: DocumentReference | null
}