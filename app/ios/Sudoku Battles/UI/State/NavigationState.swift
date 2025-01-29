import SwiftUI

class NavigationState: ObservableObject {
    static let shared = NavigationState()
    
    @Published var path: [Page] = []
        
    @MainActor
    func navigate(tag: String? = nil, @ViewBuilder content: ()->any View) {
        path.append(Page(tag: tag, view: AnyView(content())))
    }

    @MainActor
    func navigate(back tag: String) {
        guard let lastIndex = path.lastIndex(where: { $0.tag == tag })
        else { return }
        
        navigate(back: path.count - (lastIndex + 1))
    }
    
    @MainActor
    func navigate(back pages: Int = 1) {
        guard pages > 0, pages <= path.count else { return }
        path.removeLast(pages)
    }
    
    @MainActor
    func clear() {
        path = []
    }
    
    struct Page: Hashable {
        let tag: String?
        let view: AnyView
        
        private let id = UUID()
        static func == (lhs: Page, rhs: Page) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }
}
