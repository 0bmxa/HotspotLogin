//
//  WiFi.swift
//  HotspotLogin
//
//  Created by 0bmxa on 29.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation
import CoreWLAN

struct WiFi {
    internal static var shared = WiFi()
    
    private let client: CWWiFiClient
    private let interface: CWInterface
    
    private init?() {
        self.client = CWWiFiClient()
        guard let interface = client.interface() else {
            log(.error, "No WiFi interface")
            return nil
        }
        self.interface = interface
    }
    
    var isConnected: Bool {
        return self.interface.interfaceMode() != .none
    }
    
    var macAddress: String? {
        return self.interface.hardwareAddress()
    }
    
    var SSID: String? {
        return self.interface.ssid()
    }
}
