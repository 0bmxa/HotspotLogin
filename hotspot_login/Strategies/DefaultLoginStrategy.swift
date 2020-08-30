//
//  DefaultLoginStrategy.swift
//  hotspot_login
//
//  Created by mxa on 13.08.2018.
//  Copyright © 2018 0bmxa. All rights reserved.
//

import Foundation
import SwiftSoup

struct DefaultLoginStrategy: LoginStrategy {
    func login() -> Bool {
        guard let portalURL = self.detectPortal() else { return false }
        
        log(.info, "Loading captive portal page...")
        let portalRequest = URLRequest(url: portalURL)
        let portalResponse = SyncHTTP.call(urlRequest: portalRequest, followRedirects: true, timeOut: 15)

        if case .error(let error) = portalResponse {
            log(.error, error.localizedDescription)
            return false
        }
        
        guard case .text(let portalHeaders, let portalBody) = portalResponse else { fatalError() }
        
        // Get cookie
        let cookie = self.cookie(in: portalHeaders)

        // Parse portal body
        guard let form = self.firstForm(in: portalBody) else {
            log(.info, "No form found.")
            return false
        }
        let formURL = URL(string: form.action) ?? portalURL

        
        // Send "filled" form
        let loginRequest = URLRequest(url: formURL, formData: form.formData)
        let loginResponse = SyncHTTP.call(urlRequest: loginRequest, followRedirects: true, timeOut: 15)

        guard case .text(let loginResponseHeaders, let loginResponseBody) = loginResponse else { fatalError() }
        log(.debug, loginResponseHeaders)
        log(.debug, loginResponseBody)
        
        return false
    }
    
    private func detectPortal() -> URL? {
        // Looking for a HTTP redirect URL
        log(.info, "Looking for captive portal...")
        
        guard let captivePortalURL = CaptivePortalTester.getURL() else {
            log(.info, "No captive portal found.")
            return nil
        }
        
        log(.info, "Found", captivePortalURL)
        return captivePortalURL
    }

    
    private func cookie(in headers: HTTP.Headers) -> String? {
        guard let cookieHeader = headers["Set-Cookie"] else { return nil }
        let cookieContent = cookieHeader.split(separator: ";")[0]
        return String(cookieContent)
    }
    
    /// Finds the first <form> and extracts
    /// 1. the `action` URL,
    /// 2. all form fields
    private func firstForm(in body: String) -> Form? {
        let document = try! SwiftSoup.parse(body)
        
        guard let forms = try? document.select("form") else {
            log(.error, "No forms found.")
            return nil
        }
        log(.debug, "Found \(forms.count) forms.")

        guard let formElement = forms[0] as? FormElement else { return nil }

        return Form(formElement)
    }
}

class Form {
    private let formElement: FormElement
    init(_ formElement: FormElement) {
        self.formElement = formElement
    }
    
    var action: String? {
        return try? self.formElement.attr("action")
    }
    
    var inputs: [FormInputElement] {
        return self.formElement.elements().compactMap {
            FormInputElement($0)
        }
    }
    
    var formData: [String: String] {
        var data = [String: String]()
        self.inputs.forEach {
            guard let name = $0.name else { return }
            data[name] = $0.value ?? ""
        }
        return data
    }
}

class FormInputElement {
    let element: SwiftSoup.Element

    init?(_ element: Element) {
        guard element.tagName() == "input" else {
            assertionFailure()
            return nil
        }
        self.element = element
    }

    var type: String? {
        (try? self.element.attr("type")) ?? "text"
    }

    var name: String? {
        if self.type == "checkbox" {
            return try? self.element.attr("id")
        }
        return try? self.element.attr("name")
    }

    var value: String? {
        if self.type == "checkbox" {
            return try? self.element.attr("checked")
        }
        return try? self.element.val()
    }
}

extension FormInputElement: CustomStringConvertible {
    var description: String {
        return self.element.description
    }
}
