import { Worker } from 'worker_threads';
import fs from 'fs'
import os from 'os';

const sugenPath = './sugen';
const numCPUs = os.cpus().length;

function generateSudoku() {
    return new Promise((resolve, reject) => {
        const worker = new Worker('./worker.js');

        worker.on('message', (message) => {
            if (message.error) {
                reject(new Error(message.error));
            } else {
                resolve(message);
            }
        });

        worker.on('error', reject);
        worker.on('exit', (code) => {
            if (code !== 0) {
                reject(new Error(`Worker stopped with exit code ${code}`));
            }
        });
    });
}

const ranges = {
    easy: [15, 45],
    medium: [45, 95],
    hard: [95, 145],
    extreme: [145, 205],
    inhuman: [600, 1000]
}

async function runSudokuGeneration() {
    let arrays = Array.from({ length: numCPUs }, ()=>[])
    const promises = [];

    for (let thread = 0; thread < numCPUs; thread++) {
        promises.push(
            (async function() {
                for (let i = 0; i < 1000; i++) {
                    let generated = await generateSudoku()
                    if(i % 10 == 0) {
                        console.log(thread, arrays[thread].length)
                    }
                    arrays[thread].push(generated);
                }
            })()
        );
    }

    await Promise.all(promises)
    
    const flattened = arrays.flat();
    const categorized = Object.keys(ranges).reduce((acc, range) => {
        acc[range] = [];
        return acc;
    }, {});
    
    flattened.forEach(item => {
        for (const [range, [min, max]] of Object.entries(ranges)) {
            if (item.difficulty >= min && item.difficulty < max) {
                categorized[range].push(item);
                break;
            }
        }
    });

    const savePromises = Object.entries(categorized).map(async ([range, puzzles]) => {
        const filePath = `sudoku-${range}.json`;
        await fs.writeFile(filePath, JSON.stringify(puzzles), {}, ()=>{})
        console.log(`Saved ${puzzles.length} puzzles to ${filePath}`);
    });
    await Promise.all(savePromises);
}

runSudokuGeneration();

