# openssl-make-certs

No time to make it more dynamic script to change domain, subdomain and host, just replace [ALL] ric to your domain, [ALL] io to your subdomain (or postfix or extension) and [ALL] gitlab to your host.

Would appreciate if someone do that.

Compatibility: centos8-9

My apologies this is not working!  Below is fine but without intermediate CA,

```
openssl ecparam -name prime256v1 -genkey -noout -out ca.key
ll
openssl req -new -x509 -sha256 -key ca.key -out ca.crt
ll
openssl ecparam -name prime256v1 -genkey -noout -out server.key
ll
openssl req -new -sha256 -key server.key -out server.csr
ll
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 1000 -sha256
ll
openssl verify -CAfile ca.crt server.crt
```
