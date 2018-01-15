---
layout: post
title: Mitigations with TLS
---

One of the main issues with relying on TLS is that there is a lot of trust on third party Certificate Authorities (CA) which you may or may not want to trust and DNS which is not secure at all. Also if you are using a third party endpoint that is secured with one-way TLS, then you want to make sure it's issued by the CA that you trust to prevent a MITM attack. For instance, say I was relying on Facebook as an endpoint and I knew they used DigiCert as their CA. Every time I connected to Facebook, I would want to ensure whenever I make a connection to Facebook not only is it a trusted certificate by any CA, but that it is from DigiCert. This would help mitigate the issue where a MITM can spoof DNS and use an untrustworthy CA or a compromised trusted CA to issue a certificate for facebook.com. Obviously if Facebook changed their CA then you would have to update everywhere so an alternative to this would be to only trust CAs on an as needed basis so if Facebook did change to a new CA, then you could then add that new CA to your environment.

If you do control the endpoint, then you can add an additional layer of security with your own certificate chain. For this, you would still rely on TLS for the initial connection but then you could perform an additional layer of authentication with your internal certificate chain. With this, an attacker would have to not only compromise a CA but also compromise your root private key which hopefully you have stored offline and managed by an Hardware Security Module (HSM) with a decent level of physical security (see [ICANN](https://www.icann.org/) as a good example of an organization that does this).

Links:
[Compromised Certificate Authorities](https://www.techrepublic.com/blog/it-security/compromised-certificate-authorities-how-to-protect-yourself)
[DNS Security](http://techgenix.com/DNS-Security-Part-1/)
