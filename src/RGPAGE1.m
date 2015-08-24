RGPAGE1 ; CAIRO/DKM - Interactive front end for paging engine;13-Aug-2015 12:15;DKM
 ;;1.2;PAGEMAN;;05-Aug-1998
 ;=================================================================
 N RGUSR,MSG,RGTYPE,RGPGR,RGLEN,RGDT,RGZ
 D HOME^%ZIS
 U IO
 S U="^"
USR D TITLE^RGUT("PageMan Automated Paging System","1.1")
 K RGZ
 S RGZ(1)="$O(^RGPAGE(999.11,%S,1,0))"
 S MSG=U,RGUSR=$$ENTRY^RGUTLKP(200,"U1^","Person to page  : ","B:P^BS^BS5^C^D^SSN","","RGZ","",0,5)
 I RGUSR<1 W @IOF,! Q
 K RGZ
 S RGZ(1)="$$SCN^RGPAGE1(%S)"
 S RGPGR=$$ENTRY^RGUTLKP("^RGPAGE(999.11,RGUSR,1)","U1","Available pagers: ","","*","RGZ","",0,6,"$$TYPE^RGPAGE1(%S)")
 G:RGPGR<1 USR
 S RGZ=+$P(^RGPAGE(999.11,RGUSR,1,RGPGR,0),U,2),RGTYPE=+$P(^RGPAGE(999.1,RGZ,0),U,3),RGLEN=+$P(^(0),U,5)
 W !!
 D @("I"_+RGTYPE)
 G:U[MSG USR
 K RGZ
 S RGZ(" ")="NOW"
 S RGDT=$$ENTRY^RGUTDAT("Time to send    : ","FT",,0,7,"RGZ","HELP^RGPAGE1")
 G:RGDT<0 USR
 S RGZ=$$PAGE^RGPAGE(RGUSR,MSG,RGPGR,RGDT)
 I RGZ>0 W !!,"Your request has been queued ("_RGZ_")."
 E  W !!,$P(RGZ,U,2)
 R !!,"Press RETURN or ENTER to continue...",RGZ
 G USR
I0 Q
I1 W "Enter number to be sent: "
 S MSG=$$ENTRY^RGUTEDT("",RGLEN,$X,$Y,"0123456789,-^")
 S:MSG[U MSG=U
 Q
I2 N RGZ
 W "Enter the message to be sent (up to "_RGLEN_" characters).",!,"Type control-Z to send, control-A to abort.",!!
 S RGZ=RGLEN\5+10,MSG=$$ENTRY^RGUTEDT("",RGLEN,10,$Y,"","RC","",$C(26),$C(1),$S(RGZ>70:70,RGZ<50:50,1:RGZ))
 Q
 ; Pager screen
SCN(X) N RGZ,RGZ1,RGZ2
 S RGZ=$G(^RGPAGE(999.11,RGUSR,1,X,0))
 Q:$P(RGZ,U,4) 0
 Q:$P($G(^RGPAGE(999.1,+$P(RGZ,U,2),0),"^^^^^^1"),U,7) 0
 Q:RGUSR=DUZ 1
 S RGZ=0,RGZ1=1
 F  S RGZ=$O(^RGPAGE(999.11,RGUSR,1,X,1,RGZ)) Q:'RGZ  D  Q:RGZ1
 .S RGZ1=$P(^(RGZ,0),U),RGZ2=$P(RGZ1,";",2),RGZ1=+RGZ1
 .I RGZ2["VA" Q:RGZ1=DUZ
 .E  I RGZ2["XMB" Q:$D(^XMB(3.8,RGZ1,1,"B",+DUZ))
 .S RGZ1=0
 Q RGZ1
 ; Display pager type
TYPE(X) N RGZ,RGZ1
 S RGZ=$P(^RGPAGE(999.11,RGUSR,1,X,0),U,2),RGZ=^RGPAGE(999.1,RGZ,0),RGZ1=$P(RGZ,U,3)
 Q $P(RGZ,U)_" ("_$S('RGZ1:"tone only",RGZ1=1:"numeric",RGZ1=2:"alphanumeric",1:"unknown")_")"
 ; Supplemental help
HELP W "  Enter the date and time the page is to be delivered.",!
 W "  The default is immediate delivery.  Enter ^ to abort.",!
 Q
 ; User setup
SETUP Q:'$G(DUZ)
 N RGX
 S RGX=0
 W !!
 I '$D(^RGPAGE(999.11,DUZ)) D  Q:'RGX
 .S RGX=$$ASK^RGUT("Do you want to add yourself to the pager database")
 .I RGX,$$ENTRY^RGUTDIC(999.11,"~LF;.01///`"_DUZ)<0 S RGX=0
 S RGX=$$ENTRY^RGUTDIC(999.11,DUZ_"|<;1//")
 Q
