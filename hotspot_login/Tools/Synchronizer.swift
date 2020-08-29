//
//  Synchronizer.swift
//  hotspot_login
//
//  Created by mxa on 12.06.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Foundation

internal class Synchronizer<T> {
    private let semaphore = DispatchSemaphore(value: 0)

    private var _value: T!
    internal var value: T {
        set {
            self._value = newValue
            self.semaphore.signal()
        }
        get {
            self.semaphore.wait()
            return self._value
        }
    }
}

internal class CancellableSynchronizer<T> {
    private let semaphore = DispatchSemaphore(value: 0)
    private let timeout: TimeInterval?

    init(timeout: TimeInterval? = nil) {
        self.timeout = timeout
    }
    
    private var _value: T?
    internal var value: T? {
        set {
            self._value = newValue
            self.semaphore.signal()
        }
        get {
            if let timeout = self.timeout {
                _ = self.semaphore.wait(timeout: DispatchTime.now() + timeout)
                return self._value
            }
            
            self.semaphore.wait()
            return self._value
        }
    }
    
    internal func cancel() {
        self.semaphore.signal()
    }
}
