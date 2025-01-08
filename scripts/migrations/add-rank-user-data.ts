import admin from "firebase-admin";
import { dirname, resolve } from "path";
import { fileURLToPath } from "url";
import fs from "fs"

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const serviceAccountPath = resolve(__dirname, "../../secret/sudoku-battles-firebase-adminsdk-ixggv-9b3dbdc0ad.json");

admin.initializeApp({ credential: admin.credential.cert(JSON.parse(fs.readFileSync(serviceAccountPath, 'utf-8'))) });

const db = admin.firestore();

async function addDefaultRating() {
    const batchSize = 500;
    const collectionName = "users";

    const userCollectionRef = db.collection(collectionName);
    const snapshot = await userCollectionRef.get();

    if (snapshot.empty) {
        return;
    }

    console.log(`Found ${snapshot.size} documents. Updating...`);

    let batch = db.batch();
    let operationsCount = 0;

    snapshot.docs.forEach((doc, index) => {
        const docRef = userCollectionRef.doc(doc.id);

        batch.update(docRef, { rating: 100 });
        operationsCount++;

        if (operationsCount === batchSize || index === snapshot.docs.length - 1) {
            batch.commit()
                .then(() => console.log(`Committed batch of ${operationsCount} operations.`))
                .catch((error) => console.error("Error committing batch:", error));
            batch = db.batch();
            operationsCount = 0;
        }
    });

    console.log("Migration completed.");
}

addDefaultRating()
    .then(() => console.log("Script executed successfully."))
    .catch((error) => console.error("Error executing script:", error));
