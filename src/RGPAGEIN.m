RGPAGEIN ; CAIRO/DKM - PageMan Inits ;13-Aug-2015 12:15;DKM
 ;;1.2;PAGEMAN;;07-Aug-1998 11:31
 ;=================================================================
 ; Environment check
EC D VCHK("RG UTILITIES",2)
 Q
VCHK(RGP,RGV) 
 D:$$VERSION^XPDUTL(RGP)<RGV MES("Requires at least version "_RGV_" of the "_RGP_".")
 Q
MES(X) D BMES^XPDUTL(X)
 S XPDQUIT=1
 Q
