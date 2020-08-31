//
//  Log.swift
//  HotspotLogin
//
//  Created by 0bmxa on 05.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation
import Colorizer

internal enum LogLevel: String {
    case debug
    case info
    case warn
    case error
}

internal func log(_ level: LogLevel, _ items: Any..., separator: String = " ", terminator: String = "\n", colorize: Bool = true) {
    let prefix = "[\(level.rawValue.uppercased())]"
    var message = items.reduce(prefix) { $0 + separator + String(describing: $1) }

    if colorize {
        switch level {
        case .debug: message = message.foreground.Blue
        case .info:  break
        case .warn:  message = message.foreground.Yellow
        case .error: message = message.foreground.Red
        }
    }
    
    Swift.print(message, terminator: terminator)
}

@available(*, unavailable)
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
