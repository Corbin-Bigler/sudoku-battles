import Foundation

@frozen public struct Main {
    @preconcurrency static func async(group: DispatchGroup? = nil, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping @convention(block) () -> Void) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async(group: group, qos: qos, flags: flags) {
                work()
                continuation.resume()
            }
        }
    }
    @discardableResult @preconcurrency init(group: DispatchGroup? = nil, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping @convention(block) () -> Void) {
        DispatchQueue.main.async(group: group, qos: qos, flags: flags, execute: work)
    }
}
