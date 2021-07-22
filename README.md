# cheraxdestructor
inetd or stunnel shell script to serve a gemini frontend to an existing gopher server.

**Prerequisites**:
* busybox ash (or other suitable shell)
* curl
* [gophermap2gemini](https://github.com/jamestomasino/dotfiles-minimal/blob/master/bin/gophermap2gemini.awk)
* stunnel or relayd (latter also requires inetd and isn't tested)
* tls certificates (for stunnel or relayd)

**Installing**:
* copy the cheraxdestructor.sh and gophermap2gemini.awk scripts to a directory of your choice (/usr/local/bin will be used in the rest of the documentation)
* change file permissions to allow execution: 
  * chmod a+x /usr/local/bin/cheraxdestructor.sh
* edit _fqdn_, _port_, and _gophermap2gemini_ variables in the cheraxdestructor.sh script.
  * _fqdn_ The hostname of the gopher server that will be translated into gemini on the fly
  * _port_ The TCP port of the same server
  * _gophermap2gemini_ The full path to the gophermap2gemini awk script.
* add cheraxdestructor.sh to stunnel.conf:
```
    #example basic stunnel.conf configuration
    cert = /etc/stunnel/stunnel.pem
    key = /etc/stunnel/stunnel.key
    setuid = stunnel
    setgid = stunnel
    [cherax]
    exec= /usr/local/bin/cheraxdestructor.sh
    accept = 1965
````
