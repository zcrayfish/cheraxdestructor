# cheraxdestructor
inetd or stunnel shell script to serve a gemini frontend to an existing gopher server.

**Prerequisites**:
* busybox ash (or other suitable shell)
* curl (or an inetd-style gopher server)
* [gophermap2gemini](https://github.com/jamestomasino/dotfiles-minimal/blob/master/bin/gophermap2gemini.awk)
* stunnel or relayd (latter also requires inetd and isn't tested)
* tls certificate (for stunnel or relayd)

**Installing**:
* copy the cheraxdestructor.sh and gophermap2gemini.awk scripts to a directory of your choice (/usr/local/bin will be used in the rest of the documentation)
* change file permissions to allow execution: 
  * chmod a+x /usr/local/bin/cheraxdestructor.sh
* edit variables in the configuration section at the top of the cheraxdestructor.sh script:
  * _fqdn_ The hostname of the gopher server that will be translated into gemini on the fly. Used for url rewriting and as a destination address for curl
  * _port_ The TCP port of the same server
  * _gophermap2gemini_ The full path to the gophermap2gemini awk script.
  * _usecurl_ enter true or false here, if true curl will be used to connect to the gopher server, otherwise the server will be executed
  * _gopherd_ full path to an inetd-style gopher daemon. Used only when _usecurl_ is set to false.
  * _gopherd_options_ If command line options need to be passed to the gopher daemon, set them here. Used only when _usecurl_ is set to false.  
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
