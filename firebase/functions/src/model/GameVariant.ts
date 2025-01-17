export enum GameVariant {
    Duel = "duel",
    Challenge = "challenge"
}
export function decodeGameVariant(input: any): GameVariant | null {
    if (Object.values(GameVariant).includes(input)) { return input as GameVariant; }
    return null;
}