import Foundation

private let emptyBoardArray: [[Int?]] = Array(repeating: Array(repeating: nil, count: 9), count: 9)
private let emptyNotesArray: [[[Int]]] =  Array(repeating: Array(repeating: [], count: 9), count: 9)

struct SudokuBoardModel {
    private static let boardSize = 9
    static let empty = SudokuBoardModel(given: emptyBoardArray, board: emptyBoardArray)
    
    private var board: [[Int?]]
    private var notes: [[[Int]]]
    private let given: [[Int?]]
    
    var percentageComplete: Double {
        let givenNil = given.flatMap { $0 }.filter { $0 == nil }.count
        let total = 81 - (81 - givenNil)
        
        let boardNil = board.flatMap { $0 }.filter { $0 == nil }.count
        let boardPercentComplete = (Double(total - boardNil)) / Double(total)
        
        return boardPercentComplete
    }
    
    var boardString: String {
        var boardString = ""
        for y in 0..<9 {
            for x in 0..<9 {
                if let number = given[y][x] {
                    boardString.append(String(number))
                } else if let number = board[y][x] {
                    boardString.append(String(number))
                } else {
                    boardString.append("0")
                }
            }
        }
        return boardString
    }

    init(given: [[Int?]], board: [[Int?]], notes: [[[Int]]] = emptyNotesArray) {
        self.given = given
        self.board = board
        self.notes = notes
    }
    init?(given: String, board: String) {
        if given.count != 81 || board.count != 81 { return nil }
        var givenGrid: [[Int?]] = []
        for i in 0..<9 {
            var row: [Int?] = []
            for j in 0..<9 {
                let index = given.index(given.startIndex, offsetBy: i * 9 + j)
                if let number = given[index].wholeNumberValue {
                    row.append(number == 0 ? nil : number)
                }
            }
            givenGrid.append(row)
        }
        var boardGrid: [[Int?]] = []
        for i in 0..<9 {
            var row: [Int?] = []
            for j in 0..<9 {
                let index = board.index(board.startIndex, offsetBy: i * 9 + j)
                if let number = board[index].wholeNumberValue {
                    row.append(number == 0 ? nil : number)
                }
            }
            boardGrid.append(row)
        }
        self.init(given: givenGrid, board: boardGrid)
    }
    
    mutating func clearNotes(x: Int, y: Int) {
        notes[y][x] = []
    }
    mutating func toggleNote(x: Int, y: Int, key: Int) {
        if let index = notes[y][x].firstIndex(of: key) {
            notes[y][x].remove(at: index)
        } else {
            notes[y][x].append(key)
        }
    }
    func notes(x: Int, y: Int) -> [Int] {
        return notes[y][x]
    }
    func given(x: Int, y: Int) -> Int? {
        if x >= Self.boardSize || y >= Self.boardSize { return nil }
        return given[y][x]
    }
    
    subscript(position: (x: Int, y: Int)) -> Int? {
        get {
            if position.x >= Self.boardSize || position.y >= Self.boardSize { return nil }
            return board[position.y][position.x]
        }
        set {
            guard given[position.y][position.x] == nil else { return }
            board[position.y][position.x] = newValue
        }
    }
}
