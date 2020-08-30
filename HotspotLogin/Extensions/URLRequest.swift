//
//  URLRequest.swift
//  HotspotLogin
//
//  Created by 0bmxa on 05.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation

extension URLRequest {
    init(url: URL, formData: [String: String], cookie: String? = nil, timeoutInterval: TimeInterval = 15.0) {
        self = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
        self.httpMethod = "POST"
        self.addValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        self.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        if let cookie = cookie {
            self.setValue(cookie, forHTTPHeaderField: "Cookie")
        }
        
        var formDataString = formData.reduce("") { (prev, cur) -> String in
            return prev + "&" + cur.key + "=" + cur.value
        }
        formDataString = String(formDataString.dropFirst())
        self.httpBody = formDataString.data(using: .utf8)
    }
}

extension URLRequest {
    mutating func replaceHostWithIP() {
        // TODO: check if already IP
        guard let url = self.url, let hostName = url.host else { fatalError() }

        if let hostHeader = self.value(forHTTPHeaderField: "Host") {
            log(.warn, "Host header already present:", hostHeader)
        }
        
        guard let hostIP = DNS.shared.resolve(host: hostName) else { assertionFailure(); return }

        // Replace hostname with the IP in URL
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.host = hostIP
        self.url = components.url
        
        // Set host as header field
        self.setValue(hostName, forHTTPHeaderField: "Host")
    }
    
    /// Downgrades HTTPS to HTTP 😭
    mutating func downgradeHTTPS() {
        guard let url = self.url else { fatalError() }
        
        guard url.scheme == "https" else { return }
        
        // Replace hostname with the IP in URL
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.scheme = "http"
        self.url = components.url!
    }
}
