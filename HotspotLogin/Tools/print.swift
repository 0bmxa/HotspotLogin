//
//  print.swift
//  HotspotLogin
//
//  Created by 0bmxa on 05.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation

internal enum LogLevel: String {
    case debug
    case info
    case warn
    case error
}

internal func log(_ level: LogLevel, _ items: Any..., separator: String = " ", terminator: String = "\n") {
    let prefix = "[\(level.rawValue.uppercased())]"
    let message = items.reduce(prefix) { $0 + separator + String(describing: $1) }
    Swift.print(message, terminator: terminator)
}

@available(*, unavailable)
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
