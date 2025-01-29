import {
    getFirestore,
    collection,
    doc,
    getDoc,
    updateDoc,
    deleteDoc,
    query,
    where,
    limit,
    getDocs,
    Firestore,
    CollectionReference,
    DocumentReference,
    QuerySnapshot,
    onSnapshot,
} from "firebase/firestore";
import firebaseApp from "../utility/FirebaseApp";
import { AppError } from "./Model/AppError";
import type UserData from "./Model/UserData";

export default class FirestoreDs {
    private static firestore: Firestore = getFirestore(firebaseApp());

    private static usersCollection: CollectionReference = collection(
        FirestoreDs.firestore,
        "users"
    );
    private static matchmakingCollection: CollectionReference = collection(
        FirestoreDs.firestore,
        "matchmaking"
    );

    private static getDocumentReference(path: string): DocumentReference {
        return doc(FirestoreDs.firestore, path);
    }

    static async updateDocument(
        reference: DocumentReference,
        fields: Record<string, any>
    ): Promise<void> {
        try {
            await updateDoc(reference, fields);
        } catch (error) {
            console.error(error);
            throw AppError.NetworkError;
        }
    }

    static async deleteDocument(reference: DocumentReference): Promise<void> {
        try {
            await deleteDoc(reference);
        } catch (error) {
            console.error(error);
            throw AppError.NetworkError;
        }
    }

    static async getDocument<T>(
        reference: DocumentReference
    ): Promise<T | null> {
        try {
            const document = await getDoc(reference);
            if (document.exists()) {
                return document.data() as T;
            }
            return null;
        } catch (error) {
            console.error(error);
            throw AppError.InvalidResponse;
        }
    }

    static async subscribeToDocument<T>(
        reference: DocumentReference,
        callback: (data: T) => void
    ): Promise<void> {
        try {
            onSnapshot(reference, (snapshot) => {
                if (snapshot.exists()) {
                    callback(snapshot.data() as T);
                }
            });
        } catch (error) {
            console.error(error);
            throw AppError.NetworkError;
        }
    }

    static async queryUserData(uid: string): Promise<UserData | null> {
        const userRef = doc(FirestoreDs.usersCollection, uid);
        return this.getDocument(userRef);
    }

    static async queryUserDatas(
        usernamePartial: string
    ): Promise<Record<string, UserData>> {
        try {
            const q = query(
                FirestoreDs.usersCollection,
                where("usernameLowercase", ">=", usernamePartial.toLowerCase()),
                where(
                    "usernameLowercase",
                    "<=",
                    usernamePartial.toLowerCase() + "\uf8ff"
                ),
                limit(5)
            );
            const querySnapshot: QuerySnapshot = await getDocs(q);

            const results: Record<string, UserData> = {};
            querySnapshot.forEach((doc) => {
                results[doc.id] = doc.data() as UserData;
            });

            return results;
        } catch (error) {
            console.error(error);
            throw AppError.NetworkError;
        }
    }

    static async queryUserDatasByUids(
        uids: string[]
    ): Promise<Record<string, UserData>> {
        try {
            const q = query(
                FirestoreDs.usersCollection,
                where("__name__", "in", uids),
                limit(5)
            );
            const querySnapshot: QuerySnapshot = await getDocs(q);

            const results: Record<string, UserData> = {};
            querySnapshot.forEach((doc) => {
                results[doc.id] = doc.data() as UserData;
            });

            return results;
        } catch (error) {
            console.error(error);
            throw AppError.NetworkError;
        }
    }

    static async updateFcmToken(
        uid: string,
        fcmToken: string,
        deviceId: string
    ): Promise<void> {
        try {
            const userRef = doc(FirestoreDs.usersCollection, uid);
            const fields = {
                [`fcmTokens.${deviceId.toLowerCase()}`]: fcmToken,
            };
            await this.updateDocument(userRef, fields);
        } catch (error) {
            console.error(error);
            throw AppError.NetworkError;
        }
    }

    static async deleteMatchmaking(uid: string): Promise<void> {
        try {
            const matchmakingRef = doc(FirestoreDs.matchmakingCollection, uid);
            await this.deleteDocument(matchmakingRef);
        } catch (error) {
            console.error(error);
            throw AppError.NetworkError;
        }
    }
}
