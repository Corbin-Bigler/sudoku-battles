import { spawn } from 'child_process';
import fs from 'fs'

function runExecutable(
    command: string,
    args: string[],
    input?: string // Optional input to pass to the command's stdin
  ): Promise<string> {
    return new Promise((resolve, reject) => {
      const child = spawn(command, args);
  
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
        } else {
          reject(new Error(`Process exited with code ${code}: ${errorOutput}`));
        }
      });
  
      // Handle any errors
      child.on('error', (err) => {
        reject(err);
      });
    });
  }
  
async function generate(): Promise<{puzzle: number[], solution: number[], difficulty: number} | null> {
    try {
        const output = await runExecutable('./sugen', ['generate']);

        const solveInput = output
            .split("\n")
            .slice(0, 9)
            .join("\n") + "\n"
        const solveOutput = await runExecutable("./sugen", ["solve"], solveInput)
        if(!solveOutput.includes("Unique solution.")) { return null }
      
        const difficultyRegex = output.match(/Difficulty:\s*(\d+)/)
        if(difficultyRegex == null) return null
        const difficulty = parseInt(difficultyRegex[1], 10)

        const puzzle = output
            .split("\n")
            .slice(0, 9)
            .map((row)=> row.split(" ") )
            .flat()
            .map((char)=> char === '_' ? 0 : parseInt(char, 10))
        const solution = solveOutput
            .split("\n")
            .slice(0, 9)
            .map((row)=> row.split(" ") )
            .flat()
            .map((char)=> char === '_' ? 0 : parseInt(char, 10))
        return {puzzle, solution, difficulty}
    } catch (error) {
        console.error('Error generating Sudoku:', error);
        return null;
    }
}

async function generateCount(count: number): Promise<{puzzle: number[], solution: number[], difficulty: number}[]> {
    const generations: {puzzle: number[], solution: number[], difficulty: number}[] = [];

    const promises: Promise<{puzzle: number[], solution: number[], difficulty: number} | null>[] = [];

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

(async () => {
    // // await generate()
    // for(let asdf = 0; asdf < 1000; asdf++) {
    const generations = await generateCount(10000)

    var easy: {puzzle: string, solution: string, difficulty: number}[] = []
    var medium: {puzzle: string, solution: string, difficulty: number}[] = []
    var hard: {puzzle: string, solution: string, difficulty: number}[] = []
    var extreme: {puzzle: string, solution: string, difficulty: number}[] = []
    var inhuman: {puzzle: string, solution: string, difficulty: number}[] = []

    for(let generation of generations) {
        const difficulty = generation.difficulty
        const object = {
            puzzle: generation.puzzle.join(""),
            solution: generation.solution.join(""),
            difficulty: generation.difficulty
        }

        if (difficulty >= 100 && difficulty < 250) easy.push(object)
        else if (difficulty >= 251 && difficulty < 350) medium.push(object)
        else if (difficulty >= 351 && difficulty < 500) hard.push(object)
        else if (difficulty >= 501 && difficulty <= 650) extreme.push(object)
        else if (difficulty > 900) inhuman.push(object)
    }

    fs.writeFileSync("./generations/easy.json", JSON.stringify(easy))
    fs.writeFileSync("./generations/medium.json", JSON.stringify(medium))
    fs.writeFileSync("./generations/hard.json", JSON.stringify(hard))
    fs.writeFileSync("./generations/extreme.json", JSON.stringify(extreme))
    fs.writeFileSync("./generations/inhuman.json", JSON.stringify(inhuman))

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

    // const split = splitArrayIntoFour(generations.sort((a, b) => a.difficulty - b.difficulty))
    // for(let quarter of split) {
    //     let difficulties = quarter.map((g)=>g.difficulty)
    //     console.log(`min: ${Math.min(...difficulties)}`)
    //     console.log(`max: ${Math.max(...difficulties)}`)
    // }

    // const difficulties = generations.map(g => g.difficulty);
    // const mean = difficulties.reduce((acc, val) => acc + val, 0) / difficulties.length;
    // const variance = difficulties.reduce((acc, val) => acc + Math.pow(val - mean, 2), 0) / difficulties.length;
    // const standardDeviation = Math.sqrt(variance);

    // console.log(generations.length)
    // console.log('Standard Deviation of Difficulty:', standardDeviation);

})()