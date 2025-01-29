import {
    getAuth,
    type Auth,
    AuthCredential,
    GoogleAuthProvider,
    signInWithRedirect,
    getRedirectResult,
} from "firebase/auth";
import firebaseApp from "../utility/FirebaseApp";

const GOOGLE_CLIENT_ID = "333239131522-eaj7f72dr7prvkhb0a7ajjq1j5mjemc1.apps.googleusercontent.com";

export default class GoogleAuthDs {
    private static auth: Auth = getAuth(firebaseApp());
    private static provider = new GoogleAuthProvider()

    static async requestRedirect() {
        try {
            await signInWithRedirect(this.auth, this.provider)
        } catch (error) {
            console.error(error);
        }
    }
    static async handleRedirect(): Promise<AuthCredential | null> {
        try {
            const result = await getRedirectResult(this.auth);
            if(result == null) return null
            const credential = GoogleAuthProvider.credentialFromResult(result);
            return credential;
        } catch (error) {
            console.error(error);
            return null;
        }
    }
}

getRedirectResult(getAuth(firebaseApp()))
  .then((result) => {
    if (result) {
      console.log("User Info:", result.user);
      console.log("Credential:", result);
    } else {
      console.log("No redirect result available.");
    }
  })
  .catch((error) => {
    console.error("Error fetching redirect result:", error);
  });
// GoogleAuthDs.handleRedirect().then((credential) => {
//     console.log(credential)
//     if(credential) {
//         // AuthenticationState.logInCredential(credential)
//     }
// });
