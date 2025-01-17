import { DocumentSnapshot } from 'firebase-admin/firestore';
import * as admin from 'firebase-admin';
import { Difficulty } from '../model/Difficulty';

export default async function attemptGetRandomSudoku(db: admin.firestore.Firestore, difficulty: Difficulty): Promise<DocumentSnapshot | null> {    
    const collection = db.collection("sudoku-" + difficulty)
    for(let i = 0; i < 3; i++) {
        const randomValue = collection.doc().id
        const queryRef = collection
            .where("__name__", '>=', randomValue)
            .orderBy("__name__")
            .limit(1);
        
        try {        
            const randomSnapshot = await queryRef.get();
            if (randomSnapshot.empty) return null
            
            if(randomSnapshot != null) {
                return randomSnapshot.docs[0]
            }    
        } catch (error) {
            console.error(error)
        }
    }
    return null
}
