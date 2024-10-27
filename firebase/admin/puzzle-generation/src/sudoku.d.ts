declare module 'sudoku' {
  export const sudoku: {
    DIGITS: string;
    BLANK_CHAR: string;
    BLANK_BOARD: string;
    generate(difficulty?: string | number, unique?: boolean): string;
    solve(board: string, reverse?: boolean): string | false;
    get_candidates(board: string): string[][] | false;
    board_string_to_grid(board: string): string[][];
    board_grid_to_string(board: string[][]): string;
    print_board(board: string): void;
    validate_board(board: string): true | string;
  };
}
