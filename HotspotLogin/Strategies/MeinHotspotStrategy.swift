//
//  MeinHotspotStrategy.swift
//  HotspotLogin
//
//  Created by 0bmxa on 25.08.20.
//  Copyright © 2020 0bmxa. All rights reserved.
//

import Foundation

struct MeinHotspotStrategy: LoginStrategy {
    let host = "login.meinhotspot.com"
    let loginPath = "/login"
    
    private let successMessage = "Sie wurden soeben auf dem Hotspot eingeloggt"
    private let errorMessages = [
        "Your maximum daily usage time has been reached",
        "RADIUS server is not responding",
    ]
    
    func login() -> Bool {
        guard let macAddress = WiFi.shared?.macAddress else {
            log(.debug, "MAC address unavailable.")
            return false
        }
        
        let payload = [
            "username": macAddress,
            "password": macAddress,
            "mac": macAddress
        ]
        
        log(.debug, "Sending login data...", payload)
        let url = URL(string: "https://" + self.host + self.loginPath)!
        let reqest = URLRequest(url: url, formData: payload)
        let response = SyncHTTP.call(urlRequest: reqest, followRedirects: true, timeOut: 15)
        
        if case .error(let error) = response {
            log(.error, error.localizedDescription)
            return false
        }
        
        guard case .text(let resHeaders, let resBody) = response else { fatalError() }

        if resBody.contains(self.successMessage) {
            return true
        }
        
        for errorMessage in self.errorMessages {
            if resBody.contains(errorMessage) {
                log(.debug, errorMessage)
                return false
            }
        }

        log(.error, "Unkown error")
        return false
    }
}
