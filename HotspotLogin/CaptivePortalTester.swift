//
//  CaptivePortalTester.swift
//  HotspotLogin
//
//  Created by 0bmxa on 05.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation

struct CaptivePortalTester {
    static func getURL() -> URL? {
        let response = SyncHTTP.call(urlRequest: PortalTestRequest.apple, followRedirects: false, timeOut: 10)
        
        switch response {
        case .raw(let headers, _),
             .text(let headers, _):
            return URL(string: headers["Location"])
            
        case .error(let error):
            log(.error, error.localizedDescription)
            
        case .timeOut:
            log(.error, "Request timed out.")
        }
        
        return nil
    }
}


enum PortalTestRequest {
    /// A HTTP HEAD request to captive.apple.com
    static let apple: URLRequest = {
        let url = URL(string: "http://17.253.55.203/")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        request.httpMethod = "HEAD"
        request.setValue("captive.apple.com", forHTTPHeaderField: "Host")
        return request
    }()
    
    /// A HTTP HEAD request to NeverSSL.com
    static let neverssl: URLRequest = {
        let url = URL(string: "http://13.35.254.141/")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        request.httpMethod = "HEAD"
        request.setValue("neverssl.com", forHTTPHeaderField: "Host")
        return request
    }()
}
