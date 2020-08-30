//
//  SyncHTTP.swift
//  HotspotLogin
//
//  Created by 0bmxa on 13.08.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Foundation

enum SyncHTTP {
    static func GET(url urlString: String, timeOut: TimeInterval) -> HTTP.Response {
        let sync = Synchronizer<HTTP.Response>()
        HTTP.GET(url: urlString, timeOut: timeOut) {
            sync.value = $0
        }
        return sync.value
    }
    
    static func GET(url: URL, timeOut: TimeInterval) -> HTTP.Response {
        let sync = Synchronizer<HTTP.Response>()
        HTTP.GET(url: url, timeOut: timeOut) {
            sync.value = $0
        }
        return sync.value
    }
    
    static func call(urlRequest request: URLRequest, followRedirects: Bool, timeOut: TimeInterval) -> HTTP.Response {
        let sync = Synchronizer<HTTP.Response>()
        HTTP.call(urlRequest: request, followRedirects: followRedirects, timeOut: 10) {
            sync.value = $0
        }
        return sync.value
    }
}

