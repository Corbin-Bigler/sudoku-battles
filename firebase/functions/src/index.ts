import * as admin from 'firebase-admin';
admin.initializeApp();

export {verifyDuelBoard} from "./verifyDuelBoard"
export {deleteAccount} from './deleteAccount'
export {setUsername} from './setUsername'
export {matchmaking} from './matchmaking'
export {sendInvite} from './sendInvite'
export {acceptInvite} from './acceptInvite'