import fs from "fs"
import { spawn } from "child_process";

const sugenPath = './sugen';

function solveSudoku(puzzle) {
    return new Promise((resolve, reject) => {
        const process = spawn(sugenPath, ['solve-flat']);
        let output = '';
        let errorOutput = '';

        process.stdin.write(puzzle + '\n');
        process.stdin.end();

        process.stdout.on('data', (data) => {
            output += data.toString();
        });

        process.stderr.on('data', (data) => {
            errorOutput += data.toString();
        });

        process.on('close', (code) => {
            if (code !== 0) {
                return reject(new Error(`sugen exited with code ${code}: ${errorOutput}`));
            }
            resolve(output.trim());
        });
    });
}

function generateSudoku(t) {
    return new Promise((resolve, reject) => {
        var params = ['generate']
        if(t) {
            params.push('-t')
            params.push(`${t}`)
            params.push('-i')
            params.push('1000')
        }
        const process = spawn(sugenPath, params);

        let output = '';
        let errorOutput = '';

        process.stdout.on('data', (data) => {
            output += data.toString();
        });

        process.stderr.on('data', (data) => {
            errorOutput += data.toString();
        });

        process.on('close', async (code) => {
            if (code !== 0) {
                return reject(new Error(`sugen exited with code ${code}: ${errorOutput}`));
            }

            const lines = output.trim().split('\n');
            const unsolved = lines[0].trim();
            const difficultyMatch = lines[1].match(/Difficulty:\s*(\d+)/);
            const difficulty = difficultyMatch ? parseInt(difficultyMatch[1], 10) : null;

            if (!unsolved || difficulty === null) {
                return reject(new Error('Failed to parse puzzle output.'));
            }

            try {
                const solved = await solveSudoku(unsolved);
                resolve({ unsolved, solved, difficulty });
            } catch (error) {
                reject(error);
            }
        });
    });
}

var puzzles = []
const range = [95, 145]
for(let i = 0; i < 1000; i++) {
    for(let n = range[0]; n <= range[1]; n++) {
        let result = await generateSudoku(n)
        if(result.difficulty >= range[0] && result.difficulty <= range[1]) {
            console.log(puzzles.length, i)
            puzzles.push(result)  
        }
    }
}

const filePath = `./generated.json`;
await fs.writeFile(filePath, JSON.stringify(puzzles), {}, ()=>{})
console.log(`Saved ${puzzles.length} puzzles to ${filePath}`);