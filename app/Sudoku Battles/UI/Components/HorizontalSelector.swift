import SwiftUI

struct HorizontalSelector<T: CaseIterable & RawRepresentable>: View where T.AllCases: RandomAccessCollection, T.RawValue == String {
    var options: [T]
    @Binding var index: Int
    
    @State private var forward: Bool = true
    @State private var localIndex: Int = 0
    @State private var offsetX: CGFloat = 0
    
    private let height: CGFloat = 35
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let transition: AnyTransition = (forward ? AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)) :
                        .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))).combined(with: .opacity)
                HStack(alignment: .center, spacing: 0) {
                    Button(action: {
                        updateIndex(increment: -1)
                    }) {
                        Image("ArrowIcon")
                            .renderingMode(.template)
                            .padding(.trailing, 5)
                            .rotationEffect(.degrees(180))
                            .frame(height: height)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                                    
                    Button(action: {
                        updateIndex(increment: 1)
                    }) {
                        Image("ArrowIcon")
                            .renderingMode(.template)
                            .padding(.trailing, 5)
                            .frame(height: height)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                }
                
                Text(options[localIndex].rawValue)
                    .font(.sora(14, .semibold))
                    .id(localIndex)
                    .frame(width: geometry.size.width / 2)
                    .transition(transition)
                    .offset(x: offsetX)
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.2), value: localIndex)
        .foregroundStyle(.white)
        .onAppear {
            localIndex = index
        }
        .onChange(of: index) { oldIndex, newIndex in
            localIndex = newIndex
        }
    }
    
    private func updateIndex(increment: Int) {
        forward = increment > 0
        
        if index + increment >= options.count {
            withAnimation(.easeOut(duration: 0.1)) {
                offsetX = 30
            }
            withAnimation(.easeIn(duration: 0.1).delay(0.1)) {
                offsetX = 0
            }
        } else if index + increment < 0 {
            withAnimation(.easeOut(duration: 0.1)) {
                offsetX = -30
            }
            withAnimation(.easeIn(duration: 0.1).delay(0.1)) {
                offsetX = 0
            }
        } else {
            let newIndex = (index + increment + options.count) % options.count
            index = newIndex
        }
    }
}
