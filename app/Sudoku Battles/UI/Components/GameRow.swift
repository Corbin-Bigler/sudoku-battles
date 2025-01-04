
import SwiftUI

struct GameRow: View {
    
    var name: String
    var skill: Int
    var difficulty: Difficulty
    var tappable: Bool
    var seconds: Int
    var enemy: Bool
    var timestamp: Date
        
    var body: some View {
        HStack {
            Text(difficulty.title)
                .frame(width: 60, height: 60)
                .background(difficulty.color)
                .cornerRadius(10)
                .font(.sora(12))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("Thysmesi")
                        .font(.sora(14, .semibold))
                    Text("100")
                        .font(.sora(9.5, .semibold))
                        .frame(height: 15)
                        .padding(.horizontal, 5)
                        .background(.blue400)
                        .foregroundStyle(.white)
                        .cornerRadius(11)
                }
                Text("2 days ago")
                    .font(.sora(12))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack {
                Text("54:12")
                    .font(.sora(18, .semibold))
                Text("Their Score")
                    .font(.sora(10))
            }
            Spacer()
                .frame(maxWidth: 30)
            Image("ArrowIcon")
                .padding(.trailing, 5)
            
        }
    }
}

#Preview {
    GameRow(
        name: "Thysmesi",
        skill: 1023,
        difficulty: .extreme,
        tappable: true,
        seconds: 3252,
        enemy: true,
        timestamp: Date() - 100
    )
}
