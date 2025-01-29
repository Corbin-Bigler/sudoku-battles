import { derived, get, writable, type Writable } from "svelte/store";
import { ColorScheme } from "../model/ColorScheme";
import LocalStorageDs from "../../data/LocalStorageDs";
import {
    AuthCredential,
    getAuth,
    signInWithCredential,
    type Auth,
} from "firebase/auth";
import AppUser from "../model/AppUser";
import type UserData from "../../data/Model/UserData";
import firebaseApp from "../../utility/FirebaseApp";
import { AppError } from "../../data/Model/AppError";
import FirestoreDs from "../../data/FirestoreDs";

export default class AuthenticationState {
    private static auth: Auth;

    private static _user: Writable<AppUser | null> = writable(null);
    static get user(): AppUser | null {
        return get(this._user);
    }
    static set user(user: AppUser | null) {
        this._user.set(user);
    }

    private static _userData: Writable<UserData | null> = writable(null);
    static get userData(): UserData | null {
        return get(this._userData);
    }
    static set userData(userData: UserData | null) {
        this._userData.set(userData);
    }

    private static _validating = writable(true);
    static get validating(): boolean {
        return get(this._validating);
    }
    static set validating(validating: boolean) {
        this._validating.set(validating);
    }

    private static _gettingUserData = writable(false);
    static get gettingUserData(): boolean {
        return get(this._gettingUserData);
    }
    static set gettingUserData(gettingUserData: boolean) {
        this._gettingUserData.set(gettingUserData);
    }

    private static _unableToContactFirebase = writable(false);
    static get unableToContactFirebase(): boolean {
        return get(this._unableToContactFirebase);
    }
    static set unableToContactFirebase(unableToContactFirebase: boolean) {
        this._unableToContactFirebase.set(unableToContactFirebase);
    }

    static initialize() {
        this.auth = getAuth(firebaseApp());
        this.auth.onAuthStateChanged((user)=> {
            console.log("AUTH STATE CHANGED: ", user)
        })

        this.validating = true;
        this.gettingUserData = false;
        this.unableToContactFirebase = false;

        (async () => {
            const user = this.auth.currentUser;
            if (user != null) {
                try {
                    await user.getIdTokenResult(true);
                    await this.logInAppUser(new AppUser(user));
                } catch (error: any) {
                    console.error(error);
                    if (error.code === "auth/network-request-failed") {
                        this.unableToContactFirebase = true;
                    } else {
                        this.logOut();
                    }
                }
            }

            this.validating = false;
        })();
    }

    static async logInCredential(credential: AuthCredential) {
        try {
            const authData = await signInWithCredential(this.auth, credential);
            await this.logInAppUser(new AppUser(authData.user));
        } catch (error) {
            console.error(error);
            throw AppError.NetworkError;
        }
    }

    static async logInAppUser(user: AppUser) {
        this.user = user;
        await this.updateUserData();
    }

    static async updateUserData() {
        const user = this.user;
        if (user == null) return;

        this.gettingUserData = true;

        let userData: UserData | null;
        try {
            userData = await FirestoreDs.queryUserData(user.uid);
        } catch (error) {
            console.error(error);
            userData = null;
        }

        this.userData = userData;
    }

    static logOut() {
        this.auth.signOut();
        LocalStorageDs.deleteDarkMode();
        this.user = null;
        this.userData = null;
    }

    private static state = derived(
        [
            this._user,
            this._userData,
            this._validating,
            this._gettingUserData,
            this._unableToContactFirebase,
        ],
        (
            [
                user,
                userData,
                validating,
                gettingUserData,
                unableToContactFirebase,
            ],
            set
        ) => {
            set({
                user,
                userData,
                validating,
                gettingUserData,
                unableToContactFirebase,
            });
        },
        {
            user: null as AppUser | null,
            userData: null as UserData | null,
            validating: true,
            gettingUserData: false,
            unableToContactFirebase: false,
        }
    );
    static subscribe = this.state.subscribe;
}
