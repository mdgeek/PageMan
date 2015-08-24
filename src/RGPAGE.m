RGPAGE ; CAIRO/DKM - Paging engine;13-Aug-2015 13:55;DKM
 ;;1.2;PAGEMAN;;05-Aug-1998
 ;=================================================================
 ; RGUSR = DUZ of the intended recipient
 ; MSG   = message to be sent
 ; RGPGR = optional IEN of the PAGER multiple in file 999.11
 ; RGDT  = optional FM date/time of when to submit page
 ; Returns TaskMan task # if successful, "-n^error text" if not
 ;=================================================================
PAGE(RGUSR,MSG,RGPGR,RGDT) 
 N RGZ,RGZ1,RGZ2,RGRC,RGTYPE,PHN,RGDEV,RGTRY,RGMAX,RGINF,PIN,RGWWW
 S RGTYPE=$S(MSG="":0,MSG?1.N:1,1:2),RGTRY=0,RGPGR=+$G(RGPGR),RGRC="",RGUSR=+RGUSR
 F RGZ=0:0 S RGZ=$S(RGPGR:RGPGR,1:$O(^RGPAGE(999.11,RGUSR,1,RGZ))) Q:'RGZ  D  Q:$D(PIN)!RGPGR
 .S RGZ1=$G(^RGPAGE(999.11,RGUSR,1,RGZ,0))
 .Q:$P(RGZ1,U,4)
 .S RGZ2=$G(^RGPAGE(999.1,+$P(RGZ1,U,2),0)),RGRC=$G(^(1)),RGINF=$P($G(^(2)),U,1,2),RGWWW(1)=$G(^(3)),RGWWW(2)=$G(^(4)),RGWWW(3)=$G(^(5))
 .I '$P(RGZ2,U,7),$P(RGZ2,U,3)'<RGTYPE S RGTYPE=$P(RGZ2,U,3),RGDEV=$P($G(^%ZIS(1,+$P(RGZ2,U,2),0)),U),PHN=$P(RGZ2,U,4),PIN=$P(RGZ1,U,3),RGMAX=+$P(RGZ2,U,6)
 S:RGRC'="" MSG=$TR(MSG,RGRC,$$REPEAT^XLFSTR(" ",$L(RGRC)))
 Q $S($G(PIN)="":"-1^Pager not available for message type",1:$$SUBMIT)
SUBMIT() N RGZ
 S RGTRY=RGTRY+1,RGZ=$$QUEUE^RGUTTSK("TASK^RGPAGE","Page Attempt #"_RGTRY,.RGDT,"RGPGR^RGUSR^PIN^MSG^RGTYPE^PHN^RGDEV^RGTRY^RGMAX^RGINF^RGWWW(",RGDEV)
 Q $S(RGZ>0:RGZ,1:"-2^Error submitting task")
 ; TaskMan entry point
TASK N RGST
 S RGST=$$TASK1
 D LOG("C",$S(RGST<0:$P(RGST,U,2),1:"Page successfully delivered"))
 I RGST<0,RGTRY<RGMAX S RGST=$$SUBMIT
 D:RGST<0 ALERT^RGUTALR("Page failure: "_$P(RGST,U,2)_"; Recipient="_$P($G(^VA(200,RGUSR,0)),U),DUZ),LOG("C","Unable to deliver page")
 D:RGST>0 LOG("C","Attempt #"_RGTRY_" submitted as task #"_RGST)
 Q
TASK1() N RGCR,RGEOT,MSG2,$ET
 S @$$TRAP^RGUTOS("ERR^RGPAGE"),RGCR=$C(13),U="^"
 G @$S(U'[RGINF:RGINF,$L(RGWWW(1)):"WWW",1:"P"_RGTYPE)
 ; Tone only service
P0 S MSG=""
 ; Numeric service
P1 S RGEOT="",MSG2="ATM0DT"_$$MSG^RGUT(PHN,"|")_",,;H"_RGCR
 I $$TALK("ATZ"_RGCR,"OK",10),$$TALK(MSG2,"OK",60) Q 0
 Q "-3^Modem does not respond"
 ; Alphanumeric service
P2 N RGACK,RGNAK,RGSTX,RGETX,RGRS,RGETB,RGESC,RGZ
 S RGACK=$C(6),RGNAK=$C(21),RGSTX=$C(2),RGETX=$C(3),RGEOT=$C(4),RGETB=$C(23),RGRS=$C(30),RGESC=$C(27)
 S MSG2="",MSG=$TR(MSG,"~",RGCR)
 F RGZ=1:1:$L(MSG,RGCR) S MSG2=MSG2_$S(RGZ>1:" ",1:"")_$$TRIM^RGUT($P(MSG,RGCR,RGZ))
 S MSG2=RGSTX_PIN_RGCR_$E(MSG2,1,250)_RGCR_RGETX,MSG2=MSG2_$$CS(MSG2)_RGCR
 Q:'$$TALK("ATZ"_RGCR,"OK",5) "-3^Modem does not respond"
 Q:'$$TALK("ATM0E0DT"_PHN_",,"_RGCR,"CONNECT",60) "-4^Cannot connect"
 H 2
 F RGZ=1:1:10 I $$TALK(RGCR,"ID=",2) Q
 E  Q "-5^Service does not respond"
 Q:'$$TALK(RGESC_"PG1"_RGCR,RGESC_"[p",10) "-6^Login rejected"
 Q:'$$TALK(MSG2,RGACK,20) "-7^Message not acknowledged"
 D EOT
 Q 0
WWW Q $$PAGE^RGPAGE2(RGWWW(1),RGWWW(2),RGWWW(3))
 ; Conclude modem dialog
EOT I $$TALK(RGEOT_RGCR,RGEOT,5)
 I $$TALK("+++","OK",10)
 I $$TALK("ATH"_RGCR,"OK",5)
 D ^%ZISC
 Q
 ; Compute checksum
CS(MSG) N RGZ,RGCS
 S RGCS=0
 F RGZ=1:1:$L(MSG) S RGCS=RGCS+$A(MSG,RGZ)
 Q $C(RGCS\256#16+48,RGCS\16#16+48,RGCS#16+48)
 ; Error trap
ERR N RGERR
 D ERR^RGUTOS("","",.RGERR),EOT:$D(RGEOT)
 Q "-8^"_RGERR
 ; Log dialog
LOG(RGT,RGX) 
 S ^(1+$O(^%ZTSK(ZTSK,999,$C(1)),-1),RGT)=RGX
 Q
 ; This initiates a simple dialog with the paging modem
 ;  RGT = Data to transmit
 ;  RGR = Response string to look for
 ;  RGW = Time in seconds to wait for response string
 ;  Returns 1 if dialog succeeds, 0 if not
TALK(RGT,RGR,RGW) 
 N RGZ,RGZ1,RGZ2
 S RGZ1="",RGR=$G(RGR),@$$TRAP^RGUTOS("TKERR^RGPAGE")
 D LOG("S",RGT)
 W $G(RGT)
 S:+$G(RGW)<1 RGW=1
 F RGZ=1:1:RGW D  I RGZ2=-1!$L(RGR),RGZ1[RGR Q
 .F  R *RGZ2:1 Q:RGZ2<0  S:RGZ2>0 RGZ1=RGZ1_$C(RGZ2)
 D:$L(RGZ1) LOG("R",RGZ1)
 Q $T
TKERR Q RGZ1[RGR
