"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const child_process_1 = require("child_process");
const fs_1 = __importDefault(require("fs"));
function runExecutable(command, args, input // Optional input to pass to the command's stdin
) {
    return new Promise((resolve, reject) => {
        const child = (0, child_process_1.spawn)(command, args);
        let output = '';
        let errorOutput = '';
        // Listen for standard output
        child.stdout.on('data', (data) => {
            output += data.toString();
            // console.log(data.toString());
        });
        // Listen for error output
        child.stderr.on('data', (data) => {
            errorOutput += data.toString();
            // console.error(data.toString());
        });
        // If input is provided, write it to stdin
        if (input) {
            child.stdin.write(input);
            child.stdin.end(); // Close the input stream after writing
        }
        // Handle process close event
        child.on('close', (code) => {
            if (code === 0) {
                resolve(output);
            }
            else {
                reject(new Error(`Process exited with code ${code}: ${errorOutput}`));
            }
        });
        // Handle any errors
        child.on('error', (err) => {
            reject(err);
        });
    });
}
async function generate() {
    try {
        const output = await runExecutable('./sugen', ['generate']);
        const solveInput = output
            .split("\n")
            .slice(0, 9)
            .join("\n") + "\n";
        const solveOutput = await runExecutable("./sugen", ["solve"], solveInput);
        if (!solveOutput.includes("Unique solution.")) {
            return null;
        }
        const difficultyRegex = output.match(/Difficulty:\s*(\d+)/);
        if (difficultyRegex == null)
            return null;
        const difficulty = parseInt(difficultyRegex[1], 10);
        const puzzle = output
            .split("\n")
            .slice(0, 9)
            .map((row) => row.split(" "))
            .flat()
            .map((char) => char === '_' ? 0 : parseInt(char, 10));
        const solution = solveOutput
            .split("\n")
            .slice(0, 9)
            .map((row) => row.split(" "))
            .flat()
            .map((char) => char === '_' ? 0 : parseInt(char, 10));
        return { puzzle, solution, difficulty };
    }
    catch (error) {
        console.error('Error generating Sudoku:', error);
        return null;
    }
}
async function generateCount(count) {
    const generations = [];
    const promises = [];
    for (let i = 0; i < count; i++) {
        promises.push(generate());
    }
    const results = await Promise.all(promises);
    results.forEach((generated) => {
        if (generated !== null) {
            generations.push(generated);
        }
    });
    return generations;
}
function splitArrayIntoFour(array) {
    const length = array.length;
    const quarterSize = Math.ceil(length / 4);

    return [
        array.slice(0, quarterSize),
        array.slice(quarterSize, quarterSize * 2),
        array.slice(quarterSize * 2, quarterSize * 3),
        array.slice(quarterSize * 3)
    ];
}
(async () => {
    // // await generate()
    // for(let asdf = 0; asdf < 1000; asdf++) {
    const generations = await generateCount(10000);
    var easy = [];
    var medium = [];
    var hard = [];
    var extreme = [];
    var inhuman = [];
    for (let generation of generations) {
        const difficulty = generation.difficulty;
        const object = {
            puzzle: generation.puzzle.join(""),
            solution: generation.solution.join(""),
            difficulty: generation.difficulty
        };
        if (difficulty >= 100 && difficulty < 250)
            easy.push(object);
        else if (difficulty >= 251 && difficulty < 350)
            medium.push(object);
        else if (difficulty >= 351 && difficulty < 500)
            hard.push(object);
        else if (difficulty >= 501 && difficulty <= 650)
            extreme.push(object);
        else if (difficulty > 900)
            inhuman.push(object);
    }
    // fs_1.default.writeFileSync("./generations/easy.json", JSON.stringify(easy));
    // fs_1.default.writeFileSync("./generations/medium.json", JSON.stringify(medium));
    // fs_1.default.writeFileSync("./generations/hard.json", JSON.stringify(hard));
    // fs_1.default.writeFileSync("./generations/extreme.json", JSON.stringify(extreme));
    // fs_1.default.writeFileSync("./generations/inhuman.json", JSON.stringify(inhuman));
    //     function areArraysEqual(arr1: number[], arr2: number[]): boolean {
    //         if (arr1.length !== arr2.length) return false;
    //         for (let i = 0; i < arr1.length; i++) {
    //             if (arr1[i] !== arr2[i]) return false;
    //         }
    //         return true;
    //     }
    //     // Function to check if there are any duplicate puzzles
    //     function hasDuplicatePuzzles(generations: { puzzle: number[]; solution: number[]; difficulty: number }[]): boolean {
    //         for (let i = 0; i < generations.length; i++) {
    //             for (let j = i + 1; j < generations.length; j++) {
    //                 if (areArraysEqual(generations[i].puzzle, generations[j].puzzle)) {
    //                     console.log(`Duplicate found between index ${i} and ${j}`);
    //                     return true;
    //                 }
    //             }
    //         }
    //         return false;
    //     }
    //     if (hasDuplicatePuzzles(generations)) {
    //         console.log('There are duplicate puzzles.');
    //     } else {
    //         console.log('All puzzles are unique.');
    //     }    
    // }
    const split = splitArrayIntoFour(generations.sort((a, b) => a.difficulty - b.difficulty))
    for(let quarter of split) {
        let difficulties = quarter.map((g)=>g.difficulty)
        console.log(`min: ${Math.min(...difficulties)}`)
        console.log(`max: ${Math.max(...difficulties)}`)
    }
    // const difficulties = generations.map(g => g.difficulty);
    // const mean = difficulties.reduce((acc, val) => acc + val, 0) / difficulties.length;
    // const variance = difficulties.reduce((acc, val) => acc + Math.pow(val - mean, 2), 0) / difficulties.length;
    // const standardDeviation = Math.sqrt(variance);
    // console.log(generations.length)
    // console.log('Standard Deviation of Difficulty:', standardDeviation);
})();
//# sourceMappingURL=index.js.map