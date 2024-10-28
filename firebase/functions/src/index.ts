import * as admin from 'firebase-admin';
admin.initializeApp();

export {setUsername} from './setUsername'
export {matchmaking} from './matchmaking'
export {invite} from './invite'