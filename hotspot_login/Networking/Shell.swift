//
//  Shell.swift
//  hotspot_login
//
//  Created by mayxe on 05.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation

struct Shell {
    /// `ipconfig getpacket en0`
    static func dnsServerFromDHCPLease() -> String? {
        let commandResult = Command.runSync("ipconfig getpacket en0")
        let lines = commandResult.stdoutLines() { $0.contains("domain_name_server") }
        
        let dnsServerList: String? = lines?.first?.components(separatedBy: .init(charactersIn: "{}"))[1]
        let dnsServers = dnsServerList?.components(separatedBy: ", ")
        return dnsServers?.first
    }
    
    /// `route -n get default`
    static func defaultGateway() -> String? {
        let commandResult = Command.runSync("route -n get default")
        let lines = commandResult.stdoutLines() { $0.contains("gateway:") }
        
        let gatewayIP = lines?.first?.components(separatedBy: .whitespaces).last
        return gatewayIP
    }
    
    /// `dig @dnsServer 'domainName'`
    static func dig(hostName: String, dnsServer: String) -> [String]? {
//        let commandResult = Command.runSync("dig +nostats +nocomments +nocmd \(hostName) @\(dnsServer)")
        let commandResult = Command.runSync("dig +noall +answer -t A \(hostName) @\(dnsServer)")
        let lines = commandResult.stdoutLines() { !$0.starts(with: ";") }
        
        guard lines != nil else {
            let allLines = commandResult.stdoutLines()
            allLines?.forEach {
                log(.info, "dig:", $0)
            }
            return nil
        }
        
        let resolvedIPs = lines?.compactMap { $0.components(separatedBy: .whitespaces).last }
        return resolvedIPs
    }
    
    /// `airport -I`
    static func getSSID() -> String? {
        let commandString = "/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I"
        let commandResult = Command.runSync(commandString)
        let lines = commandResult.stdoutLines() { $0.contains("SSID:") }
        
        let ssid = lines?.first?.components(separatedBy: .whitespaces).last
        return ssid
    }
}
