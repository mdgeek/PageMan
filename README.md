# PageMan 
API for sending pages to numeric and alphanumeric pagers or via text messaging.  Resurrected at the request of a colleague from some very old code I wrote many years ago.  To setup for testing purposes, you can create the following entries via FileMan:

## DEVICE file:
```
NAME: TEXTBELT PAGING SERVICE         $I: |TCP|80
ASK DEVICE: NO                        ASK PARAMETERS: NO
SIGN-ON/SYSTEM DEVICE: NO             LOCATION OF TERMINAL: TCP
ASK HOST FILE: NO                     ASK HFS I/O OPERATION: NO
SUPPRESS FORM FEED AT CLOSE: YES      OPEN COUNT: 60
MARGIN WIDTH: 256                     PAGE LENGTH: 65534
OPEN PARAMETERS: ("textbelt.com":80):60
SUBTYPE: C-OTHER                      TYPE: NETWORK CHANNEL
```
## PAGEMAN PAGING SERVICE file:
```
NAME: TEXTBELT                        PAGING DEVICE: TEXTBELT PAGING SERVICE
TYPE: ALPHANUMERIC                    MAXIMUM MESSAGE LENGTH: 160
MAXIMUM ATTEMPTS: 1                   WEB URL: http://textbelt.com/text
WEB REQUEST: number=|PIN|&message=|MSG|
WEB RESPONSE: "success": true
```
## PAGEMAN PAGER file:
```
USER: <user in file 200>
PAGER: iPhone                           
   SERVICE: TEXTBELT
   PIN NUMBER: <user's mobile phone #>
   USER OR GROUP: <same user in file 200>
```
** Note: Textbelt is a free paging service that supports multiple paging providers. **
