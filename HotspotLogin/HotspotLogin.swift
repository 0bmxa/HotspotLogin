//
//  HotspotLogin.swift
//  HotspotLogin
//
//  Created by 0bmxa on 13.08.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

struct HotspotLogin {
    func attemptLogin() {
        guard let wifi = WiFi.shared, wifi.isConnected == true else {
            log(.error, "Not connected to WiFi.")
            return
        }
        
        let SSID = wifi.SSID
        log(.debug, "SSID:", SSID ?? "–")

        let strategyClass = self.strategyForSSID(SSID: SSID)
        log(.debug, "Using:", strategyClass)
        
        let strategy = strategyClass.init()
        
        let success = strategy.login()
        log(success ? .info : .error, success ? "Logged in." : "Login was not successful.")
    }

    private func strategyForSSID(SSID: String?) -> LoginStrategy.Type {
        switch SSID {
        case "WIFIonICE":        return WIFIonICEStrategy.self
        case "books and bagels": return MeinHotspotStrategy.self
        default:                 return DefaultLoginStrategy.self
        }
    }
}
