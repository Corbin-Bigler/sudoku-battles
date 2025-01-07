const { parentPort } = require('worker_threads');
const { spawn } = require('child_process');

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

function generateSudoku() {
    return new Promise((resolve, reject) => {
        const process = spawn(sugenPath, ['generate']);

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

generateSudoku()
    .then((result) => parentPort.postMessage(result))
    .catch((error) => parentPort.postMessage({ error: error.message }));
