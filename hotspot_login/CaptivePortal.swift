//
//  CaptivePortal.swift
//  hotspot_login
//
//  Created by mayxe on 05.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation

struct CaptivePortal {
    static func getURL() -> URL? {
        let response = SyncHTTP.call(urlRequest: PortalTester.apple, followRedirects: false, timeOut: 10)
        
        switch response {
        case .raw(let headers, _),
             .text(let headers, _):
            return URL(string: headers["Location"])
            
        case .error(let error):
            log(.error, error.localizedDescription)
            
        case .timeOut:
            log(.error, "Request timed out. Are you on slow network?")
        }
        
        return nil
    }
}


enum PortalTester {
    /// A HTTP HEAD request to captive.apple.com (IP based)
    static let apple: URLRequest = {
        let url = URL(string: "http://17.253.55.203/")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        request.httpMethod = "HEAD"
        request.setValue("captive.apple.com", forHTTPHeaderField: "Host")
        return request
    }()
    
    //    static let applle: URLRequest = {
    //        var request = URLRequest(url: "http://captive.apple.com/", usingIP: "17.253.55.203")
    //        request.httpMethod = "HEAD"
    //        return request
    //    }()
    
    /// A HTTP HEAD request to NeverSSL.com (IP based)
    static let neverssl: URLRequest = {
        let url = URL(string: "http://13.35.254.141/")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
        request.httpMethod = "HEAD"
        request.setValue("neverssl.com", forHTTPHeaderField: "Host")
        return request
    }()
}
