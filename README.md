# openssl-make-certs

No time to make it more dynamic script to change domain, subdomain and host, just replace [ALL] ric to your domain, [ALL] io to your subdomain (or postfix or extension) and [ALL] gitlab to your host.

Would appreciate if someone do that.

Compatibility: centos8-9

My apologies this is not working!  Below is fine but without intermediate CA,

```
openssl ecparam -name prime256v1 -genkey -noout -out ca.key
ll
openssl req -new -x509 -days 365 -key ca.key -subj "/C=CA/ST=ON/L=TOR/O=Ric, Inc./CN=ric.io" -out ca.crt
ll
openssl ecparam -name prime256v1 -genkey -noout -out server.key
ll
openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CA/ST=ON/L=TOR/O=Ric, Inc./CN=gitlab.ric.io" -out server.csr
ll
openssl x509 -req -extfile <(printf "subjectAltName=DNS:ric.io,DNS:gitlab.ric.io") -days 1000 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
ll
openssl verify -CAfile ca.crt server.crt # testing is the key!!!!!!!!!!!!!!!
```
