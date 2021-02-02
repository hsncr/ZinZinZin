//
//  Combine+Lock.swift
//  CombineTakeUntil
//
//  Created by hsncr on 20.01.2021.
//

import Foundation

extension NSRecursiveLock {
    
    // MARK: block is executed inside lock to provide syncronous execution
    func synchronize<T>(_ block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
    
    // MARK: side effect is executed outside of lock to prevent deadlock
    func synchronized(_ sideEffect: () throws -> (() -> Void)?) rethrows {
        try synchronize(sideEffect)?()
    }
}

