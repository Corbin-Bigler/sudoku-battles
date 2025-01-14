import { DocumentReference, Timestamp } from "firebase-admin/firestore";

export type BotDuel = {
    startTime: Timestamp,
    player: DocumentReference,
    playerBoard: string,
    endTime: Timestamp | null,
    given: string,
    botEndTime: Timestamp,
    botRanking: number,
    sudoku: DocumentReference,
}