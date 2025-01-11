import admin from "firebase-admin";
import fs from "fs";

const serviceAccount = JSON.parse(
    fs.readFileSync("/Users/corbinbigler/Keys/sudoku-battles-firebase-adminsdk-ixggv-4622ae599e.json")
);

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

const firestore = admin.firestore();

if (process.env.FIRESTORE_EMULATOR_HOST) {
    console.log(`Using Firestore Emulator at ${process.env.FIRESTORE_EMULATOR_HOST}`);
    firestore.settings({
        host: process.env.FIRESTORE_EMULATOR_HOST,
        ssl: false,
    });
}

async function batchUploadToFirestore(collectionName, array) {
    const collectionRef = firestore.collection(collectionName);

    try {
        for (let i = 0; i < array.length; i += 500) {
            const batch = firestore.batch();
            const chunk = array.slice(i, i + 500);

            chunk.forEach((element) => {
                const docRef = collectionRef.doc(); // Auto-generate a document ID
                batch.set(docRef, element);
            });

            await batch.commit();
            console.log(`Batch ${i / 500 + 1} uploaded successfully to collection: ${collectionName}`);
        }
    } catch (error) {
        console.error(`Error uploading batch to collection ${collectionName}:`, error);
    }
}

await batchUploadToFirestore("sudoku-easy", JSON.parse(fs.readFileSync('../generator/sudoku-easy.json')));
await batchUploadToFirestore("sudoku-extreme", JSON.parse(fs.readFileSync('../generator/sudoku-extreme.json')));
await batchUploadToFirestore("sudoku-hard", JSON.parse(fs.readFileSync('../generator/sudoku-hard.json')));
await batchUploadToFirestore("sudoku-inhuman", JSON.parse(fs.readFileSync('../generator/sudoku-inhuman.json')));
await batchUploadToFirestore("sudoku-medium", JSON.parse(fs.readFileSync('../generator/sudoku-medium.json')));
