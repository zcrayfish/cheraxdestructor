#! /bin/ash
#####Configuration section#####
#The fqdn variable defines the hostname of the gopher server you'll be proxying to gemini.
readonly fqdn=gopher.zcrayfish.soy
#The port variable defines the TCP port of the gopher server you'll be proxying to gemini.
readonly port=70
#The full path to the gophermap2gemini.awk script
readonly gophermap2gemini=/usr/local/bin/gophermap2gemini.awk
####End of configuration section, use caution if editing below this line####

readonly baseurl="gemini://$fqdn"
#how many bytes are at the beginning of the URL?
readonly baseurllength="${#baseurl}"
#readonly baseurllength=$((${#baseurl}-1))

# Gather request
read -t 30 -r url badclient

####Request validation####
#Did we time out... If so just exit, gemini does not have a timeout code
test "$?" != "0" && exit
# Reject requests with garbage past the URL.
test ! -z "$badclient" && printf '%s\15\12' "59 BAD REQUEST; Garbage past URL in request." && exit
# See if request is for defined FQDN.
test $(echo "$url" | head -c "$baseurllength") != "$baseurl" && printf '%s\15\12' "59 BAD REQUEST; $baseurl URLs only please." && exit
####End of request validation####

# If it all looks good, find out what they want
readonly filename=$(echo "$url" | tail -c +$((${#baseurl}+1)) | sed -e 's/%2c/,/gi' -e 's/%20/ /g' -e 's/\r$//g' -e 's/%3b/;/i')
#                                                                                                    ^ ^ ^ ^ ^ ^
#                                                                 curl fails without carriage return removal!!!!

###WIP BELOW HERE####

    case "$filename" in
	/favicon.ico)
	    printf '%s\15\12' "51 NOT FOUND; favicon.ico" && exit;;
	/2*)
	    printf '%s\15\12' "50 PERMANENT FAILURE; gophertype 2 CCSO not supported" && exit;;
	/7*)
	    printf '%s\15\12' "40 TEMPORARY FAILURE; This server does not support gopher type 7, yet. Will be addressed in future update.
	    ;;
	###START OF DUMB / NON-INTELLIGENT GOPHER TYPES###
	/[04569IMPdghps]*)
	    case "$filename" in
		/0/stylesheet.css)
		    mimetype="20 text/css";;
		/0*)
		    mimetype="20 text/plain";;
		/4*)
		    mimetype="20 application/mac-binhex40";;
		/5*|/6*|/9*|/d*)
		    mimetype="20 application/octet-stream";;
		/I*.webp)
		    mimetype="20 image/webp";;
		/I*)
		    mimetype="20 image/jpeg";;
		/M*.mht|/M*.mhtml|/m*.mht|m*.mhtml)
		    mimetype="20 multipart/related";;
		/M*)
		    mimetype="20 message/rfc822";;
		/P*)
		    mimetype="20 application/pdf";;
		/g*)
		    mimetype="20 image/gif";;
		/h*|/H*)
		    mimetype="20 text/html";;
		/p*)
		    mimetype="20 image/png";;
		/s*.mp3)
		    mimetype="20 audio/mpeg";;
		/s*.m4a)
		    mimetype="20 video/mp4";;
		/s*)
		    mimetype="20 application/octet-stream";;
                /';'*.webm)
		    mimetype="20 video/webm";;
	    esac
	    #We now have enough information to pull in anything we're not converting to gemini markup
	    xyzzy="$(curl -q --disable -s --output - "gopher://$fqdn:$port$filename" | base64)"
	    isdumb="true"
	    ;;
        ###END OF DUMB / NON-INTELLIGENT GOPHER TYPES###
        *)
                #Convert gophermap to gemini markup
		mimetype="20 text/gemini; "
                xyzzy="$(curl -q --disable -s --output - "gopher://$fqdn:$port$filename" | awk -f $gophermap2gemini | \
		       sed -e 's/=> gopher:\/\/'$fqdn':'$port'/=> gemini:\/\/'$fqdn'/g' )"
                    ;;
    esac

###OUTPUT SECTION###

#We'll use the output of curl to determine if gopher content is 404d
#Non gophermap content may be binary, base64 it so the shell can deal with it
if [ "$isdumb" = "true" ] ; then
  precontent=$(echo "$xyzzy" | base64 -d)
else
  precontent="$xyzzy"
fi

#See if there's an error
is40=$(echo "$precontent" | head -n1 | grep "Error: Access denied!")
is51=$(echo "$precontent" | head -n1 | grep "Error: File or directory not found!")

#Respond to any errors
if [ -n "$is40" ] ; then
  printf '%s\15\12' '40 TEMPORARY FAILURE; Error: Access denied!' && exit
fi

if [ -n "$is51" ] ; then
  printf '%s\15\12' '51 NOT FOUND; Error: File or directory not found!' && exit
fi

#If no errors, then we go here
printf '%s\15\12' "$mimetype"
if [ "$isdumb" = "true" ] ; then
  echo "$xyzzy" | base64 -d
else
  echo "$xyzzy"
fi
