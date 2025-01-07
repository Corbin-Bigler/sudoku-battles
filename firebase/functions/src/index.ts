import * as admin from 'firebase-admin';
admin.initializeApp();

export {verifyDuelBoard} from "./v1/verifyDuelBoard"
export {deleteAccount} from './v1/deleteAccount'
export {setUsername} from './v1/setUsername'
export {matchmaking} from './v1/matchmaking'
export {invite} from './v1/invite'