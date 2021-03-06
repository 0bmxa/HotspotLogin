//
//  DNS.swift
//  HotspotLogin
//
//  Created by 0bmxa on 14.07.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Foundation

internal typealias HostName = String
internal typealias IP = String

class DNS {
    static let shared = DNS()
    
    let server: IP
    private var cache: [HostName: IP] = [:]
    private let fallbackServer = "9.9.9.9"
    
    private init() {
        if let server = Shell.dnsServerFromDHCPLease {
            self.server = server
            log(.debug, "Using DNS server:", self.server)
            return
        }
        
        if let defaultGateway = Shell.defaultGateway {
            self.server = defaultGateway
            log(.info, "Using default gateway as DNS server:", self.server)
            return
        }
        
        self.server = self.fallbackServer
        log(.warn, "No local DNS nor gateway found. Falling back to", self.server)
    }
    
    func resolve(host: HostName) -> IP? {
        guard !host.isIP else { return host }
        
        let allIPs = self.resolveAll(host: host)
        if let IP = allIPs?.first {
            log(.debug, host, "resolved to", IP)
            self.cache[host] = IP
        }
        return allIPs?.first
    }

    private func resolveAll(host: HostName) -> [IP]? {
        log(.debug, "Resolving host \"\(host)\"...")
        
        let resolvedIPs = Shell.dig(hostName: host, dnsServer: self.server)
        
        if (resolvedIPs?.count ?? 0) <= 0 {
            log(.error, "Could not resolve host", host)
        }
        
        return resolvedIPs
    }
}

extension HostName {
    var isIP: Bool {
        let isIPv4 = self.range(of: #"^\d+\.\d+\.\d+\.\d+$"#, options: .regularExpression) != nil
        
        // FIXME: well well well...
        let isIPv6 = self.range(of: #":.*:"#, options: .regularExpression) != nil
        
        return isIPv4 || isIPv6
    }
}
