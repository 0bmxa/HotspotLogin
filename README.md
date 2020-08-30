# HotspotLogin

HotspotLogin is a CLI tool which tries to log you into WiFi hotspots with a
captive portal.

It's based on my Python version
[`hotspot_login`](https://github.com/0bmxa/hotspot_login), but better.


## Features & how it works

### For known WiFis

1. Based on the SSID (WiFi name), it picks a "strategy" (see [`Strategies`](/0bmxa/HotspotLogin/tree/master/HotspotLogin/Strategies)).
1. The strategy sends the necessary requests directly.


### For unknown WiFis

1. Finds the Captive Portal by loading a known URL.  
   If a redirect occurs, the destination is considered a Captive Portal.
1. Loads the Captive Portal's HTML document
1. Finds `<form>` elements on it and extracts
    - Target URL (form action)
    - Form data (all input elements)
1. Tries to send the form with that data

This is where it currently ends. If the form data has to be modified before
sending (like checking an "I accept" box), this already fails. (See ToDo below.)


### DNS & TLS

Captive Portal URLs are usually only accessible on the local network, and
therefore their domain names also often only resolveable on the local DNS
server.

To make this work, this tool
1. Finds the local DNS server
    - from either the last DHCP annoucement; or (if unavailable)
    - just uses the default gateway
1. Resolves all domain/host names with this DNS server
1. Replaces host names in all request with the resolved IPs, and sets the HTTP
`Host` header
1. (For HTTPS connections:)  
   If a "hostname mismatch" certificate error occured, validates received
certificates for whether the original host name (before resolution) matches

If this causes any security issues I don't know about, I'm happy to hear about it!


## ToDo

- [ ] Allow the user to modify the form data (see above)
- [ ] IPv6 support
- [ ] "Complex" DNS support (like `CNAME` results)
- [ ] Find out if the certificate handling has issues (see above)
- [ ] Support [router advertised captive portals](https://tools.ietf.org/html/rfc7710)
(if the OS doesn't yet)