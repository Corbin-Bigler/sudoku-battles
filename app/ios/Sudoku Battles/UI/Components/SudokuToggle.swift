import SwiftUI

struct SudokuToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(isOn ? Color.blue400 : Color.blue400.opacity(0.2))
                .animation(.easeInOut(duration: 0.1), value: isOn)
                .frame(width: 60, height: 30)

            HStack {
                if isOn { Spacer() }
                Circle()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isOn ? Color.white : Color.blue400)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.1), value: isOn)
                if !isOn { Spacer() }
            }
            .padding(3)
        }
        .frame(width: 60, height: 30)
    }
}

#Preview {
    SudokuToggle(isOn: .constant(true))
    SudokuToggle(isOn: .constant(false))
}
