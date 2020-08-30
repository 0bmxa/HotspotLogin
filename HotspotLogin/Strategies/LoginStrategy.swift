//
//  LoginStrategy.swift
//  HotspotLogin
//
//  Created by 0bmxa on 05.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation

protocol LoginStrategy {
    init()
    func login() -> Bool
}
