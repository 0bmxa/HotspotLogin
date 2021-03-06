//
//  Shell.swift
//  HotspotLogin
//
//  Created by 0bmxa on 05.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation

struct Shell {
    /// `ipconfig getpacket en0`
    static var dnsServerFromDHCPLease: String? {
        let commandResult = Command.runSync("ipconfig getpacket en0")
        let lines = commandResult.stdoutLines() { $0.contains("domain_name_server") }
        
        let dnsServerList: String? = lines?.first?.components(separatedBy: .init(charactersIn: "{}"))[1]
        let dnsServers = dnsServerList?.components(separatedBy: ", ")
        return dnsServers?.first
    }
    
    /// `route -n get default`
    static var defaultGateway: String? {
        let commandResult = Command.runSync("route -n get default")
        let lines = commandResult.stdoutLines() { $0.contains("gateway:") }
        
        let gatewayIP = lines?.first?.components(separatedBy: .whitespaces).last
        return gatewayIP
    }
    
    /// `dig @dnsServer 'domainName'`
    static func dig(hostName: String, dnsServer: String) -> [String]? {
//        let commandResult = Command.runSync("dig +nostats +nocomments +nocmd \(hostName) @\(dnsServer)")
        let commandResult = Command.runSync("dig +noall +answer -t A \(hostName) @\(dnsServer)")
        let _lines = commandResult.stdoutLines() { !$0.starts(with: ";") }
        
        guard let lines = _lines, lines.count > 0 else {
            let allLines = commandResult.stdoutLines()
            allLines?.forEach {
                log(.debug, "dig:", $0)
            }
            return nil
        }
        
        let resolvedIPs = lines.compactMap { $0.components(separatedBy: .whitespaces).last }
        return resolvedIPs
    }    
}
