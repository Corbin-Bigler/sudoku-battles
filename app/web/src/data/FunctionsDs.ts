import { getFunctions, httpsCallable } from "firebase/functions"
import firebaseApp from "../utility/FirebaseApp";
import { AppError } from "./Model/AppError";
import type { SetUsernameStatus } from "./Model/SetUsernameStatus";

interface FunctionsResponse<S, D> {
    status: S;
    data: D;
}

export default class FunctionsDs {
    private static functions = getFunctions(firebaseApp())

    private static async callFunction<T>(name: string, params?: Record<string, any>): Promise<T> {
        try {
            
            const callable = httpsCallable(this.functions, name);
            const result = await callable(params);

            if (typeof result.data === 'string') {
                const data = JSON.parse(result.data);
                return data as T;
            }
            throw new Error('Invalid response format');
        } catch (error) {
            console.error(error);
            throw AppError.InvalidResponse
        }
    }

    // static async acceptInvite(invitePath: string): Promise<FunctionsResponse<InviteStatus, 'AcceptInviteData'>> {
    //     return this.callFunction('acceptInvite', { invitePath });
    // }

    // static async sendInvite(uid: string, difficulty: string): Promise<FunctionsResponse<InviteStatus, 'SendInviteData'>> {
    //     return this.callFunction('sendInvite', { invitee: uid, difficulty });
    // }

    static async setUsername(username: string): Promise<FunctionsResponse<SetUsernameStatus, never>> {
        return this.callFunction('setUsername', { username });
    }

    // static async verifyDuelBoard(duelPath: string): Promise<FunctionsResponse<VerifyDuelBoardStatus, never>> {
    //     return this.callFunction('verifyDuelBoard', { duelPath });
    // }

    // static async requestMatchmaking(): Promise<FunctionsResponse<MatchmakingStatus, 'MatchmakingData'>> {
    //     return this.callFunction('matchmaking');
    // }

    // static async deleteAccount(): Promise<FunctionsResponse<DeleteAccountStatus, 'MatchmakingData'>> {
    //     return this.callFunction('deleteAccount');
    // }
}