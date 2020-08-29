//
//  LoginStrategy.swift
//  hotspot_login
//
//  Created by mayxe on 05.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation

protocol LoginStrategy {
    init()
    func login() -> Bool
}
