export enum Difficulty {
    Easy = "easy",
    Medium = "medium",
    Hard = "hard",
    Extreme = "extreme",
    Inhuman = "inhuman"
}
export function decodeDifficulty(input: any): Difficulty | null {
    if (Object.values(Difficulty).includes(input)) { return input as Difficulty; }
    return null;
}