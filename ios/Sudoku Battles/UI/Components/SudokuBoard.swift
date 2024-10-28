import SwiftUI

struct SudokuBoard: View {
    @Binding var model: SudokuBoardModel
    @State private var states: [SudokuBoardModel]
    @State var selectedCell: (x: Int, y: Int)?
    @State var key: Int?
    @State private var notes = false
    
    init(model: Binding<SudokuBoardModel>) {
        self._model = model
        self.states = [model.wrappedValue]
    }
    
    func clearNotes(x: Int, y: Int) {
        var newBoard = model
        newBoard.clearNotes(x: x, y: y)
        states.append(newBoard)
        model = newBoard
    }
    func toggleNote(x: Int, y: Int, value: Int) {
        var newBoard = model
        newBoard[(x, y)] = nil
        newBoard.toggleNote(x: x, y: y, key: value)
        states.append(newBoard)
        model = newBoard
    }
    func setCell(x: Int, y: Int, value: Int?) {
        var newBoard = model
        newBoard[(x, y)] = value
        newBoard.clearNotes(x: x, y: y)
        states.append(newBoard)
        model = newBoard
    }

    var body: some View {
        VStack(spacing: 30) {
            GeometryReader { geometry in
                let shape = RoundedRectangle(cornerRadius: 20)
                VStack(spacing: 0) {
                    ForEach(0..<9, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<9, id: \.self) { column in
                                let givenValue = model.given(x: column, y: row)
                                let value = givenValue ?? model[(column, row)]
                                let notes = model.notes(x: column, y: row)
                                let isSelected = ((selectedCell?.x ?? -1) == column && (selectedCell?.y ?? -1) == row)
                                let isKey = (value != nil && value == key) || notes.contains(key ?? -1)
                                let highlighted = isKey || isSelected
                                
                                SudokuCell(value: value, notes: notes, permenant: givenValue != nil, highlighted: highlighted)
                                    .onTapGesture {
                                        if isSelected {
                                            selectedCell = nil
                                        } else if let key, self.notes {
                                            if value != nil { return }
                                            if key == 0 { clearNotes(x: column, y: row) }
                                            else { toggleNote(x: column, y: row, value: key) }
                                        } else if let key, givenValue == nil {
                                            setCell(x: column, y: row, value: key == 0 ? nil : isKey ? nil : key)
                                        } else if givenValue == nil {
                                            selectedCell = (x: column, y: row)
                                        }
                                    }
                                if column != 8 {
                                    Color.purple100
                                        .frame(width: (column + 1) % 3 == 0 ? 2 : 0.75)
                                }
                            }
                        }
                        if row != 8 {
                            Color.purple100
                                .frame(height: (row + 1) % 3 == 0 ? 2 : 0.75)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .clipShape(shape)
                .shadow(color: .purple400.opacity(0.1), radius: 15, x: -6, y: -6)
                .shadow(color: .purple400.opacity(0.1), radius: 15, x: 6, y: 6)
                .overlay {
                    shape
                        .stroke(lineWidth: 2)
                        .foregroundStyle(Color.purple100)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    ForEach(1...5, id: \.self) { number in
                        let toggled = key == number
                        let background = toggled ? Color.purple50 : Color.clear
                        Text("\(number)")
                            .font(.sora(24, .semibold))
                            .foregroundStyle(toggled ? Color.purple400 : Color.black)
                            .frame(width: 60, height: 60)
                            .circleButton(outline: toggled ? Color.purple400 : Color.gray100, background: background) {
                                if let selectedCell {
                                    if notes {toggleNote(x: selectedCell.x, y: selectedCell.y, value: number)}
                                    else {setCell(x: selectedCell.x, y: selectedCell.y, value: number)}
                                } else if toggled {
                                    key = nil
                                } else {
                                    key = number
                                }
                            }
                    }
                }
                HStack(spacing: 15) {
                    ForEach([6,7,8,9], id: \.self) { number in
                        let toggled = key == number
                        let background = toggled ? Color.purple50 : Color.clear
                        Text("\(number)")
                            .font(.sora(24, .semibold))
                            .foregroundStyle(toggled ? Color.purple400 : Color.black)
                            .frame(width: 60, height: 60)
                            .circleButton(outline: toggled ? Color.purple400 : Color.gray100, background: background) {
                                if let selectedCell {
                                    if notes {toggleNote(x: selectedCell.x, y: selectedCell.y, value: number)}
                                    else {setCell(x: selectedCell.x, y: selectedCell.y, value: number)}
                                } else if toggled {
                                    key = nil
                                } else {
                                    key = number
                                }
                            }
                    }
                    
                    let toggled = key == 0
                    let background = toggled ? Color.red400 : Color.red50
                    ZStack {
                        Image("CloseIcon")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17.5, height: 17.5)
                            .foregroundStyle(toggled ? Color.white : Color.black)
                    }
                    .frame(width: 60, height: 60)
                    .circleButton(outline: Color.clear, background: background) {
                        if let selectedCell {
                            if notes {clearNotes(x: selectedCell.x, y: selectedCell.y)}
                            else {setCell(x: selectedCell.x, y: selectedCell.y, value: nil)}
                        } else if toggled {
                            key = nil
                        } else {
                            key = 0
                        }
                    }
                }
            }
            HStack(spacing: 15) {
                HStack(spacing: 7) {
                    Image("EditIcon")
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    Text("Note")
                        .font(.sora(16, .semibold))
                    Spacer()
                    CustomToggle(isOn: $notes)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    notes.toggle()
                }
                Color.gray50
                    .frame(width: 1, height: 50)
                RoundedButton(icon: Image("CircleArrowIcon"), label: "Undo", outlined: true) {
                    if states.count > 1 {states.popLast()}
                    if !states.isEmpty { model = states.last! }
                }
            }
        }
    }
}

private struct SudokuCell: View {
    let value: Int?
    let notes: [Int]
    let permenant: Bool
    let highlighted: Bool
    
    private var string: String {
        guard let value else { return "" }
        return "\(value)"
    }
    private var backgroundColor: Color { highlighted ? .purple100 : permenant ? .purple50.opacity(0.5) : .clear }

    var body: some View {
        GeometryReader { geometry in
            let height = (geometry.size.height - 4) / 3
            let width = (geometry.size.width - 4) / 3
            Text(string)
                .font(.sora(20, .semibold))
                .foregroundStyle(permenant ? .purple600 : .black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundColor)
                .contentShape(Rectangle())
            if value == nil && !notes.isEmpty {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Group {
                            Text("1").opacity(notes.contains(1) ? 1 : 0)
                            Text("2").opacity(notes.contains(2) ? 2 : 0)
                            Text("3").opacity(notes.contains(3) ? 3 : 0)
                        }
                        .frame(width: width)
                    }
                    .frame(height: height)
                    HStack(spacing: 0) {
                        Group {
                            Text("4").opacity(notes.contains(4) ? 1 : 0)
                            Text("5").opacity(notes.contains(5) ? 1 : 0)
                            Text("6").opacity(notes.contains(6) ? 1 : 0)
                        }
                        .frame(width: width)
                    }
                    .frame(height: height)
                    HStack(spacing: 0) {
                        Group {
                            Text("7").opacity(notes.contains(7) ? 1 : 0)
                            Text("8").opacity(notes.contains(8) ? 1 : 0)
                            Text("9").opacity(notes.contains(9) ? 1 : 0)
                        }
                        .frame(width: width)
                    }
                    .frame(height: height)
                }
                .padding(2)
                .font(.sora(12))
                .foregroundStyle(.gray500)
            }
        }
    }
}

private struct KeyButton: View {
    var text: String
    var toggled: Bool
    var body: some View {
        Text(text)
            .font(.title)
            .foregroundStyle(toggled ? Color.white : Color.blue)
            .frame(width: 60, height: 60)
            .background(toggled ? Color.blue : Color.clear)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(lineWidth: 1)
                    .foregroundStyle(Color.blue)
            }
    }
}


private struct Preview: View {
    @State private var board: SudokuBoardModel
    init() {
        var board = Mock.sudokuBoard
        board[(x: 3, y: 2)] = 2
        board.toggleNote(x: 1, y: 1, key: 1)
        self._board = State(wrappedValue: board)
    }
    var body: some View {
        SudokuBoard(model: $board)
            .padding(.horizontal, 16)
    }
}
#Preview {
    Preview()
}
