import SwiftUI

struct SudokuBoard: View {
    @Binding var model: SudokuBoardModel
    @State private var states: [SudokuBoardModel]
    @State var selectedCell: (x: Int, y: Int)?
    @State var search: Int?
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
        newBoard[(x, y)] = newBoard[(x, y)] == value ? nil : value
        newBoard.clearNotes(x: x, y: y)
        if let value {
            for index in 0..<9 {
                newBoard.disableNote(x: x, y: index, key: value)
                newBoard.disableNote(x: index, y: y, key: value)
            }
        }
        
        
        search = nil
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
                                let isSearch = (value != nil && value == search)
                                let highlighted = isKey || isSelected || isSearch
                                
                                SudokuCell(value: value, notes: notes, permenant: givenValue != nil, highlighted: highlighted)
                                    .onTapGesture {
                                        if value == nil {
                                            if let key {
                                                if self.notes {
                                                    if key == 0 { clearNotes(x: column, y: row) }
                                                    else { toggleNote(x: column, y: row, value: key) }
                                                } else {
                                                    setCell(x: column, y: row, value: key == 0 ? nil : key)
                                                }
                                            } else {
                                                if isSelected { selectedCell = nil }
                                                else { selectedCell = (x: column, y: row) }
                                                search = nil
                                            }
                                        } else {
                                            if let key, givenValue == nil {
                                                if self.notes {
                                                    if key == 0 { clearNotes(x: column, y: row) }
                                                    else { toggleNote(x: column, y: row, value: key) }
                                                } else {
                                                    setCell(x: column, y: row, value: key == 0 ? nil : key)
                                                }
                                            } else {
                                                if givenValue != nil {
                                                    if value == search { search = nil }
                                                    else { search = value }
                                                    selectedCell = nil
                                                    key = nil
                                                } else {
                                                    if isSelected { selectedCell = nil }
                                                    else { selectedCell = (x: column, y: row) }
                                                    search = nil
                                                }
                                            }
                                        }

//                                        if search != nil && value == search {
//                                            search = nil
//                                        } else if isSelected {
//                                            selectedCell = nil
//                                        } else if let key, self.notes {
//                                            if key == 0 { clearNotes(x: column, y: row) }
//                                            else { toggleNote(x: column, y: row, value: key) }
//                                        } else if let key, givenValue == nil {
//                                            setCell(x: column, y: row, value: key == 0 ? nil : key)
//                                        } else if let value {
//                                            search = value
//                                            selectedCell = nil
//                                            key = nil
//                                        } else if givenValue == nil, key == nil {
//                                            selectedCell = (x: column, y: row)
//                                            search = nil
//                                        }
                                    }
                                if column != 8 {
                                    Color.blue100
                                        .frame(width: (column + 1) % 3 == 0 ? 2 : 0.75)
                                }
                            }
                        }
                        if row != 8 {
                            Color.blue100
                                .frame(height: (row + 1) % 3 == 0 ? 2 : 0.75)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .clipShape(shape)
                .shadow(color: .blue400.opacity(0.1), radius: 15, x: -6, y: -6)
                .shadow(color: .blue400.opacity(0.1), radius: 15, x: 6, y: 6)
                .overlay {
                    shape
                        .stroke(lineWidth: 2)
                        .foregroundStyle(Color.blue100)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 5)

            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    ForEach(1...5, id: \.self) { number in
                        let toggled = key == number
                        let background = toggled ? Color.blue50 : Color.clear
                        Text("\(number)")
                            .font(.sora(24, .semibold))
                            .foregroundStyle(toggled ? Color.blue400 : Color.black)
                            .frame(width: 60, height: 60)
                            .circleButton(outline: toggled ? Color.blue400 : Color.gray100, background: background) {
                                if let selectedCell {
                                    if notes {toggleNote(x: selectedCell.x, y: selectedCell.y, value: number)}
                                    else {setCell(x: selectedCell.x, y: selectedCell.y, value: number)}
                                } else if toggled {
                                    key = nil
                                } else {
                                    key = number
                                    search = nil
                                }
                            }
                    }
                }
                HStack(spacing: 15) {
                    ForEach([6,7,8,9], id: \.self) { number in
                        let toggled = key == number
                        let background = toggled ? Color.blue50 : Color.clear
                        Text("\(number)")
                            .font(.sora(24, .semibold))
                            .foregroundStyle(toggled ? Color.blue400 : Color.black)
                            .frame(width: 60, height: 60)
                            .circleButton(outline: toggled ? Color.blue400 : Color.gray100, background: background) {
                                if let selectedCell {
                                    if notes {toggleNote(x: selectedCell.x, y: selectedCell.y, value: number)}
                                    else {setCell(x: selectedCell.x, y: selectedCell.y, value: number)}
                                } else if toggled {
                                    key = nil
                                } else {
                                    key = number
                                    search = nil
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
                            search = nil
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
                    SudokuToggle(isOn: $notes)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    notes.toggle()
                }
                Color.gray50
                    .frame(width: 1, height: 50)
                
                let shape = RoundedRectangle(cornerRadius: 11)
                Button(action: {
                    if states.count > 1 {let _ = states.popLast()}
                    if !states.isEmpty { model = states.last! }
                }) {
                    HStack(spacing: 6) {
                        Text("Undo")
                            .font(.sora(16, .semibold))
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                }
                .foregroundStyle(.blue400)
                .overlay {
                    shape
                        .stroke(lineWidth: 1)
                        .foregroundStyle(.blue400)
                }
            }
            .padding(.horizontal, 24)
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
    private var backgroundColor: Color { permenant ? .blue50.opacity(0.5) : .clear }
    private var foregroundColor: Color {
        if highlighted {return .white}
        else {return permenant ? .blue900 : .black}
    }

    var body: some View {
        ZStack {
            if highlighted {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue300)
                    .padding(3)
            }
            
            Text(string)
                .font(.sora(23, .semibold))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            
            GeometryReader { geometry in
                let height = (geometry.size.height) / 3
                let width = (geometry.size.width) / 3
                
                let columns = [
                    GridItem(.fixed(width), spacing: 0),
                    GridItem(.fixed(width), spacing: 0),
                    GridItem(.fixed(width), spacing: 0)
                ]
                
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(1..<10) { index in
                        if notes.contains(index) {
                            Text("\(index)")
                                .frame(width: width, height: height)
                        }
                    }
                    .font(.sora(12))
                    .foregroundStyle(highlighted ? .white : .gray500)
                }
            }
            .padding(4)
        }
        .background(backgroundColor)
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
    }
}
#Preview {
    Preview()
}
