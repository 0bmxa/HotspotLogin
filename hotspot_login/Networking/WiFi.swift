//
//  WiFi.swift
//  hotspot_login
//
//  Created by mayxe on 29.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation
import CoreWLAN

struct WiFi {
    private static let wifiClient = CWWiFiClient()
    
    static var macAddress: String? {
        let interface = self.wifiClient.interface()
        return interface?.hardwareAddress()
    }
    
    static var SSID: String? {
        let interface = self.wifiClient.interface()
        return interface?.ssid()
    }
}
