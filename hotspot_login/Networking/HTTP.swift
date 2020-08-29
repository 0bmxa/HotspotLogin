//
//  HTTP.swift
//  hotspot_login
//
//  Created by mxa on 13.08.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Foundation
import dnssd

enum HTTP {
    typealias Headers = [String: String]

    static var Sync = SyncHTTP.self
    
    enum Response {
        case text(headers: Headers, body: String)
        case raw(headers: Headers, body: Data?)
        case error(Error)
        case timeOut
    }
    
    static func GET(url urlString: String, followRedirects: Bool = false, timeOut: TimeInterval = 5.0, callback: @escaping (Response) -> Void) {
        guard let url = URL(string: urlString) else { fatalError() }
        self.GET(url: url, followRedirects: followRedirects, timeOut: timeOut, callback: callback)
    }

    static func GET(url: URL, followRedirects: Bool = false, timeOut: TimeInterval = 5.0, callback: @escaping (Response) -> Void) {
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
        self.call(urlRequest: request, followRedirects: followRedirects, timeOut: timeOut, callback: callback)
    }
    
//    static func POST(url: URL, followRedirects: Bool = false, timeOut: TimeInterval = 5.0, callback: @escaping (Response) -> Void) {
//        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeOut)
//        request.httpMethod = "POST"
//        self.call(urlRequest: request, followRedirects: followRedirects, timeOut: timeOut, callback: callback)
//    }
    
    static func call(urlRequest request: URLRequest, followRedirects: Bool, timeOut: TimeInterval, callback: @escaping (Response) -> Void) {
        var request = request
        request.replaceHostWithIP()
//        request.downgradeHTTPS()
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: RedirectionHandler(allowsRedirects: followRedirects), delegateQueue: nil)
        
        let completionHandler = { (data: Data?, urlResponse: URLResponse?, error: Error?) in
            if let error = error {
                callback(.error(error))
                return
            }
            
            let headers = (urlResponse as? HTTPURLResponse)?.stringHeaders ?? [:]
            
            if let _data = data, let body = String(data: _data, encoding: .utf8) {
                callback(.text(headers: headers, body: body))
                return
            }
            
            callback(.raw(headers: headers, body: data))
        }
        
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
}


extension HTTPURLResponse {
    var stringHeaders: [String: String] {
        let stringHeaders = self.allHeaderFields.map { header -> (String, String) in
            let key   = String(describing: header.key)
            let value = String(describing: header.value)
            return (key, value)
        }
        return Dictionary(uniqueKeysWithValues: stringHeaders)
    }
}
