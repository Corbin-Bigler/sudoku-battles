import { initializeApp, getApps, type FirebaseApp } from 'firebase/app';
import { getAnalytics } from "firebase/analytics";

const firebaseConfig = {
    apiKey: "AIzaSyD1Ve9YkWJGcoSSWm4-HkTAwW1z9i3lCv0",
    authDomain: "sudoku-battles.firebaseapp.com",
    projectId: "sudoku-battles",
    storageBucket: "sudoku-battles.appspot.com",
    messagingSenderId: "333239131522",
    appId: "1:333239131522:web:61f1de2d7653da5ecec39b",
    measurementId: "G-V25KZSFTG1",
};

export default function firebaseApp(): FirebaseApp {
    if (!getApps().length) {
        const app = initializeApp(firebaseConfig)
        getAnalytics(app);
        return app;
    }
    return getApps()[0];
}

