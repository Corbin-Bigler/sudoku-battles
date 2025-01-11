//
//  Task.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/9/25.
//
import Foundation

struct TimedOutError: Error, Equatable {}

func TimeoutTask<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
    return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
        let resumer = Resumer() // Actor for thread-safe resumption

        let work = Task {
            do {
                let result = try await operation()
                if await resumer.checkAndResume() {
                    continuation.resume(returning: result)
                }
            } catch {
                if await resumer.checkAndResume() {
                    continuation.resume(throwing: error)
                }
            }
        }

        Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
                work.cancel()
                if await resumer.checkAndResume() {
                    continuation.resume(throwing: TimedOutError())
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

actor Resumer {
    private var resumed = false

    func checkAndResume() -> Bool {
        if resumed { return false }
        resumed = true
        return true
    }
}
