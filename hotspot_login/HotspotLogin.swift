//
//  HotspotLogin.swift
//  hotspot_login
//
//  Created by mxa on 13.08.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

struct HotspotLogin {
    func attemptLogin() {
        let SSID = WiFi.SSID
        if SSID == nil {
            log(.warn, "SSID unknown.")
        }
        
        let strategyClass = self.strategyForSSID(SSID: SSID)
        log(.info, "SSID: \(SSID ?? "–"); Using: \(strategyClass)")
        
        let strategy = strategyClass.init()
        
        let success = strategy.login()
        log(.info, success ? "Logged in." : "Login was not successful.")
    }

    private func strategyForSSID(SSID: String?) -> LoginStrategy.Type {
        switch SSID {
        case "WIFIonICE":        return WIFIonICEStrategy.self
        case "books and bagels": return MeinHotspotStrategy.self
        default:                 return DefaultLoginStrategy.self
        }
    }
}
