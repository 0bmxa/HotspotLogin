//
//  URL.swift
//  HotspotLogin
//
//  Created by 0bmxa on 05.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation

extension URL {
    init?(string: String?) {
        guard let string = string else { return nil }
        self.init(string: string)
    }
    
    var request: URLRequest {
        URLRequest(url: self)
    }
}

extension String {
    var url: URL? {
        URL(string: self)
    }
}
