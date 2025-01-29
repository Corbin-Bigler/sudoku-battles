export default class LocalStorageDs {
    private static savedGameKey = "solo_game_key"
    private static darkModeKey = "dark_mode_key"
    private static recentInvitesKey = "recent_invites_key"

    static saveDarkMode(darkMode: boolean) {
        localStorage.setItem(this.darkModeKey, darkMode.toString())
    }
    static getDarkMode(): boolean | null {
        const value = localStorage.getItem(this.darkModeKey)
        return value == null ? null : value == "true"
    }
    static deleteDarkMode() {
        localStorage.removeItem(this.darkModeKey);
    }

    // static set(key: string, value: string) {
    //     localStorage.setItem(key, value);
    // }

    // static delete(key: string) {
    //     localStorage.removeItem(key);
    // }

    // static get(key: string): string | null {
    //     return localStorage.getItem(key);
    // }
}