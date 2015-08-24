RGPAGE2 ; CAIRO/DKM - Web-based Paging Interface ;13-Aug-2015 16:56;DKM
 ;;1.2;PAGEMAN;;05-Aug-1998
 ;=================================================================
PAGE(RGURL,RGBODY,RGACK) 
 N RGX,RGL,RGZ
 S @$$TRAP^RGUTOS("ERR^RGPAGE2")
 F  Q:MSG'["  "  S MSG=$$SUBST^RGUT(MSG,"  "," ")
 S RGZ=$$HEX(MSG)
 N MSG,CRLF,HOST,PATH
 S RGX=RGURL
 S:RGX["://" RGX=$P(RGX,"://",2)
 S HOST=$P(RGX,"/"),PATH="/"_$P(RGX,"/",2,99)
 S MSG=RGZ,CRLF=$C(13,10),RGBODY=$$MSG^RGUT(RGBODY,"|"),RGL=$L(RGBODY)+2
 F RGZ=0:1 S RGX=$P($T(MSG+RGZ),";;",2,99) Q:RGX="@"  D
 .W $$MSG^RGUT(RGX,"|")_CRLF,!
 S RGL=$L($G(RGACK)),RGZ="",@$$TRAP^RGUTOS("ERR2^RGPAGE2")
 I RGL F  R RGX#100:600 Q:'$T  D  Q:'RGL
 .S RGZ=RGZ_RGX
 .S:RGZ[RGACK RGL=0
 Q $S(RGL:"-99^Host did not acknowledge",1:0)
HEX(RGX) N RGZ
 F RGZ="%","&","=","~",$C(13),$C(10) D:RGX[RGZ
 .S RGX=$$SUBST^RGUT(RGX,RGZ,"%"_$$BASE^RGUT($A(RGZ),16,2))
 Q RGX
ERR Q "-99^Cannot connect to host"
ERR2 Q "-99^Host did not acknowledge"
MSG ;;POST |PATH| HTTP/1.1
 ;;Accept: */*
 ;;User-Agent: pageman/1.2
 ;;Host: |HOST|
 ;;Content-Length: |RGL|
 ;;Content-Type: application/x-www-form-urlencoded
 ;;
 ;;|RGBODY|
 ;;@
