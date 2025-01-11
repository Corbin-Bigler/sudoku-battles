import { DocumentReference, Timestamp } from "firebase-admin/firestore";

export type Duel = {
    firstPlayer: DocumentReference,
    firstPlayerBoard: string,
    given: string,
    secondPlayer: DocumentReference | null,
    secondPlayerBoard: string | null,
    startTime: Timestamp,
    sudoku: DocumentReference,
    botEndTime: Timestamp
}