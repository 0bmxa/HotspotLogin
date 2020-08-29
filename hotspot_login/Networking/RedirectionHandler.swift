//
//  RedirectionHandler.swift
//  hotspot_login
//
//  Created by mxa on 14.07.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Foundation

class RedirectionHandler: NSObject, URLSessionTaskDelegate {
    let allowsRedirects: Bool
    
    init(allowsRedirects: Bool) {
        self.allowsRedirects = allowsRedirects
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        var newRequest = newRequest
        if self.allowsRedirects {
            log(.debug, "Redirecting", task.currentRequest?.url ?? "?", "->", newRequest.url ?? "?")
            newRequest.replaceHostWithIP()
        }
        completionHandler(self.allowsRedirects ? newRequest : nil)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Always exit with calling the completion handler.
        // Either with credential, or with default handling.
        var credential: URLCredential?
        defer {
            let disposition: URLSession.AuthChallengeDisposition = (credential != nil) ? .useCredential : .performDefaultHandling
            completionHandler(disposition, credential)
        }
        
        // Only handle server trust evaluation here
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust
        else { return }
        
        // Evaluate the server's trust
        let trust = Security.Trust(trust: serverTrust)
        let (trusted, error) = trust.evaluate()
        
        // Return, if already trusted, or not just hostname mismatch, or no Host header set
        guard !trusted, case .hostNameMismatch = error,
            let hostHeader = task.currentRequest?.allHTTPHeaderFields?["Host"]
        else { return }
        
        // Create & set a policy for the trust, that allows the new host
        let policy = Security.Policy(server: true, hostName: hostHeader)
        trust.policies = [policy._policy]
        
        // Re-evaluate the server's trust.
        let (trustedWithNewHost, _) = trust.evaluate()

        // If now trusted, create a credential for the modified trust (used with completionHandler in `defer`)
        if trustedWithNewHost {
            credential = URLCredential(trust: trust._trust)
        }
    }
}

enum Security {
    class Policy {
        let _policy: SecPolicy
        
        /// Creates a policy object for evaluating SSL certificate chains.
        /// - Parameters:
        ///   - server: Specify true on the client side to return a policy for SSL server certificates.
        ///   - hostName: If you specify a value for this parameter, the policy will require the specified value to match the host name in the leaf certificate.
        init(server: Bool, hostName: String?) {
            self._policy = SecPolicyCreateSSL(server, hostName as CFString?)
        }
    }
    
    class Trust {
        let _trust: SecTrust
        
        init(trust: SecTrust) {
            self._trust = trust
        }
        
        /// Evaluates trust for the specified certificate and policies.
        /// - Returns: A tuple of (trusted, error), where
        ///   - trusted: Whether the certificate is trusted.
        ///   - error: An error indicating why trust evaluation failed.
        func evaluate() -> (Bool, TrustError?) {
            var cfError: CFError?
            let trusted = SecTrustEvaluateWithError(self._trust, &cfError)
            let error = TrustError(cfError)
            return (trusted, error)
        }
        
        /// Policies to use in an evaluation.
        var policies: [SecPolicy]? {
            get {
                var policies: CFArray?
                let status = SecTrustCopyPolicies(self._trust, &policies)
                assert(status == noErr)
                return policies as? [SecPolicy]
            }
            
            set {
                guard let policies = newValue else { return }
                let status = SecTrustSetPolicies(self._trust, policies as CFArray)
                assert(status == noErr)
            }
        }
    }
}

extension Security {
    enum TrustError: Error {
        case hostNameMismatch // errSecHostNameMismatch
        case other(CFError)
        
        init?(_ cfError: CFError?) {
            guard let cfError = cfError else { return nil }
            
            let code = CFErrorGetCode(cfError)
            self = (code == errSecHostNameMismatch) ? .hostNameMismatch : .other(cfError)
        }
    }
}

