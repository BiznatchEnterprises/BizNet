'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@@@                  ----------------------------------                  @@@@@@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@@@               [[[ Biznet Protocol Version 1.0 Beta ]]]               @@@@@@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@@@                  ----------------------------------                  @@@@@@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@@@     Bi Directional Packet Transfer (Pic-2-Pic) 6 Protocol Wires      @@@@@@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@@@        Transfer data to/from HOST TO CLIENT via IP ADDRESSING        @@@@@@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@@@     Max Bytes(chars) Per Packet: 40   Max Bytes Per Second: N/A      @@@@@@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@@@              COPYRIGHT AUG 18 2004 BIZNATCH ENTERPRISES              @@@@@@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@@@                        Programmed by: Justin                         @@@@@@@@@@@@@@@@@@@@
'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

'--------- HOST WIRE CONFIG START ---------
'PIC 16F877
'pwr + 5v                         MCLR+ VDD
'grnd                                   VSS
'START/ENDPACKET1       	        RB5
'START/ENDPACKET2                       RB4
'DATALINE1 (data to clients)            RB3
'DATALINE2 (data to host)               RB2
'SYNC4CHAR1                             RB1
'SYNC4CHAR2                             RB0
'---------- HOST WIRE CONFIG END ----------
'-------- CLIENT WIRE CONFIG START --------
'PIC 16F877
'pwr + 5 V                       MCLR + VDD
'grnd                                   VSS
'START/ENDPACKET1       	        RB5
'START/ENDPACKET2                       RB4
'DATALINE1 (data to clients)            RB3
'DATALINE2 (data to host)               RB2
'SYNC4CHAR1                             RB1
'SYNC4CHAR2                             RB0
'--------- CLIENT WIRE CONFIG END ---------

'10101101 01010000 00100100 11010101 010010 011010 101101 
'IPO1       IPO2     IPO3     IPO4    DB1     DB2    DB3

DB = DATABYTE(6bits)
IPO = IP OCTECT(8bits)


'############################################
'           PROTOCOL VARIABLES START
'############################################
'=== DIM  VARIABLES FOR HOST START ===
Dim send2clientsbuffer(40) As Byte  'SEND BUFFER FOR DATA BYTES (1-40)
Dim send2clientsbuffersused As Byte  'NUMEBER OF BUFFERS FILLED WITH DATA FOR CLIENTS PACKET
Dim readfrmclientsbuffer(40) As Byte  'SEND BUFFER FOR DATA BYTES (1-40)
Dim readfrmclientsbuffersused As Byte  'NUMEBER OF BUFFERS FILLED WITH DATA FOR CLIENTS PACKET
'=== DIM  VARIABLES FOR HOST END ===

'=== DIM  VARIABLES FOR CLIENTS START ===
Dim send2hostbuffer(40) As Byte  'SEND BUFFER TO HOST (1-40 BYTES)
Dim send2hostbuffersused As Byte  'NUMEBER OF BUFFERS FILLED WITH DATA TO SEND TO HOST
Dim readfrmhostbuffer(40) As Byte  'READ BUFFER FROM HOST (1-40 BYTES)
Dim readfrmhostbuffersused As Byte  'NUMEBER OF BUFFERS FILLED WITH DATA FROM HOST
'=== DIM  VARIABLES FOR CLIENTS END ===

'=== DIM VARIABLES FOR PROTOCOL START ===
Dim toipoct1 As Byte  'SEND PACKET TO CLIENT IP ADDRESS OCTET 1 (0-255)
Dim toipoct2 As Byte  'SEND PACKET TO CLIENT IP ADDRESS OCTET 2 (0-255)
Dim toipoct3 As Byte  'SEND PACKET TO CLIENT IP ADDRESS OCTET 3 (0-255)
Dim toipoct4 As Byte  'SEND PACKET TO CLIENT IP ADDRESS OCTET 4 (0-255)
Dim frmipoct1 As Byte  'READ PACKET FRM CLIENT IP ADDRESS OCTET 1 (1-255)
Dim frmipoct2 As Byte  'READ PACKET FRM CLIENT IP ADDRESS OCTET 2 (1-255)
Dim frmipoct3 As Byte  'READ PACKET FRM CLIENT IP ADDRESS OCTET 3 (1-255)
Dim frmipoct4 As Byte  'READ PACKET FRM CLIENT IP ADDRESS OCTET 4 (1-255)
dim tmpbytes(10) as byte 'TEMPORARY BYTES FOR MISC USAGE
Dim sendtoclientsbittemp As Bit  'USED AS A TEMP BIT VARIABLE FOR SENDING TO CLIENTS
Dim sendtohostbittemp As Bit  'USED AS A TEMP BIT VARIABLE FOR SENDING TO HOST
Dim readfrmclientsbittemp As Bit  'USED AS A TEMP BIT VARIABLE FOR READING FRM CLIENTS
Dim readfrmhostbittemp As Bit  'USED AS A TEMP BIT VARIABLE FOR READING FRM HOST
Dim lastclientpacketstate As Bit  'LAST STATE OF CLIENT PACKET START/PACKET END EJUMPER
Dim lasthostpacketstate As Bit  'LAST STATE OF CLIENT PACKET START/PACKET END EJUMPER
Dim lastclients4bstate As Bit  'LAST STATE OF CLIENT SYNC FOR NEXT PACKET BIT EJUMPER
Dim lasthosts4cbtate As Bit  'LAST STATE OF HOST SYNC FOR NEXT PACKET BIT EJUMPER
Dim sendpacketdirection As Bit  '1 TO SEND PACKET TO HOST, 0 TO SEND PACKET TO CLIENTS
'=== DIM VARIABLES FOR PROTOCOL END ===
'############################################
'            PROTOCOL VARIABLES END
'############################################

'############################################
'         MAIN PROTOCOL PRORAM START
'############################################
High PORTD.1  'POWER ON STATUS

main:
'---------------------------- EXAMPLE BIZNET PROTOCOL USAGE END ----------------------------------

'************************************* AS A HOST START *******************************************

'======= READ PACKET FROM CLIENTS START ========
trisb.5 = 1
If PORTB.5 = 1 Then  'IF STARTPACKET1 IS TRIGGERED (STARTPACKET1)
	If lastsepstatus = 0 Then  'If last state of startpacket1 is Not triggered, change occured
	Goto clearreadbuffer
	Goto readhostpacket  'READ DATALINE2 AND LOAD IT INTO BUFFER
	Endif
Endif
lastsepstatus = PORTB.5
'======= READ PACKET FROM CLIENTS END ========

'======= SEND PACKET TO CLIENTS START ========
toipoct1 = 1
toipoct2 = 1
toipoct3 = 1
toipoct4 = 1
sendbuffersused = 3
Goto clearsendbuffer
sendbuffer(0) = 1
sendbuffer(1) = 1
sendbuffer(2) = 1
Goto sendpackettoclents
'======= SEND PACKET TO CLIENTS END ========
'************************************* AS A HOST END *******************************************




'************************************* AS A CLIENT START *******************************************
'======= READ PACKET FROM HOST START ========
trisb.5 = 1
If PORTB.5 = 1 Then  'IF STARTPACKET1 IS TRIGGERED (STARTPACKET1)
	If lastsepstatus = 0 Then  'If last state of startpacket1 is Not triggered, change occured
	Goto clearreadbuffer
	Goto readhostpacket  'READ DATALINE2 AND LOAD IT INTO BUFFER
	Endif
Endif
lastsepstatus = PORTB.5
'======= READ PACKET FROM HOST END ========

'======= SEND PACKET TO HOST START ========
frmipoct1 = 1
frmipoct2 = 1
frmipoct3 = 1
frmipoct4 = 1
sendbuffersused = 3
Goto clearsendbuffer
sendbuffer(0) = 1
sendbuffer(1) = 1
sendbuffer(2) = 1
Goto sendpackettohost
'======= SEND PACKET TO HOST END ========
'************************************* AS A CLIENT END *******************************************

'---------------------------- EXAMPLE BIZNET PROTOCOL USAGE END ----------------------------------

Goto main
End
'############################################
'         MAIN PROTOCOL PRORAM END
'############################################






'############################################
'          PROTOCOL FUNCTIONS START
'############################################
'************************************ HOST FUNCTIONS START ***********************************
'=========== SEND PACKET TO CLIENTS START ===========
sendpackettoclients:
sendpacketdirection = 0  '1 = HOST 0 = CLIENTS
sendpacket
return
'=========== SEND PACKET TO CLIENTS END ===========

'************************************ HOST FUNCTIONS END ************************************




'*********************************** CLIENTS FUNCTIONS START ***********************************
'=========== SEND PACKET TO HOST START ===========
sendpackettohost:
sendpacketdirection = 1  '1 = HOST 0 = CLIENTS
sendpacket
return
'=========== SEND PACKET TO HOST END ===========

'************************************ CLIENTS FUNCTIONS END ************************************




'*********************************** SHARED FUNCTIONS START ***********************************
'=========== CLEAR SEND BUFFER START ===========
'PARAMETERS: sendbuffersused
clearsendbuffer:
Dim i As Byte
For i = 0 To sendbuffersused - 1
sendbuffer(i) = 0
Next
Return
'=========== CLEAR SEND BUFFER END ===========

'=========== CLEAR READ BUFFER START ===========
'PARAMETERS: readbuffersused
clearsendbuffer:
Dim i As Byte
For i = 0 To sendbuffersused - 1
sendbuffer(i) = 0
Next
Return
'=========== CLEAR READ BUFFER END ===========

'=========== SEND PACKET START ===========
sendpacket:
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
Goto sendstartpacket
Goto sendipoct1
Goto sendipoct2
Goto sendipoct3
Goto sendipoct4
Goto sendpacketbuffer
Goto sendendpacket
Return
'=========== SEND PACKET END ===========

'====== SEND (START PACKET) START ======
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
sendstartpacket:
TRISB.5 = 0
PORTB.5 = 1
Return
'====== SEND (START PACKET) END ======

'====== SEND (END PACKET) START ======
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
sendendpacket:
TRISB.5 = 0
PORTB.5 = 0
Return
'====== SEND (END PACKET) END ======

'=========== SEND IP OCT1 START ===========
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
sendipoct1:
sendbittemp = sendtoipoct1.0
Goto sendpacketbit
sendbittemp = sendtoipoct1.1
Goto sendpacketbit
sendbittemp = sendtoipoct1.2
Goto sendpacketbit
sendbittemp = sendtoipoct1.3
Goto sendpacketbit
sendbittemp = sendtoipoct1.4
Goto sendpacketbit
sendbittemp = sendtoipoct1.5
Goto sendpacketbit
sendbittemp = sendtoipoct1.6
Goto sendpacketbit
sendbittemp = sendtoipoct1.7
Goto sendpacketbit
Return
'=========== SEND IP OCT1 END ===========

'=========== SEND IP OCT2 START ===========
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
sendipoct2:
sendbittemp = sendtoipoct2.0
Goto sendpacketbit
sendbittemp = sendtoipoct2.1
Goto sendpacketbit
sendbittemp = sendtoipoct2.2
Goto sendpacketbit
sendbittemp = sendtoipoct2.3
Goto sendpacketbit
sendbittemp = sendtoipoct2.4
Goto sendpacketbit
sendbittemp = sendtoipoct2.5
Goto sendpacketbit
sendbittemp = sendtoipoct2.6
Goto sendpacketbit
sendbittemp = sendtoipoct2.7
Goto sendpacketbit
Return
'=========== SEND IP OCT2 END ===========

'=========== SEND IP OCT3 START ===========
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
sendipoct3:
sendbittemp = sendtoipoct3.0
Goto sendpacketbit
sendbittemp = sendtoipoct3.1
Goto sendpacketbit
sendbittemp = sendtoipoct3.2
Goto sendpacketbit
sendbittemp = sendtoipoct3.3
Goto sendpacketbit
sendbittemp = sendtoipoct3.4
Goto sendpacketbit
sendbittemp = sendtoipoct3.5
Goto sendpacketbit
sendbittemp = sendtoipoct3.6
Goto sendpacketbit
sendbittemp = sendtoipoct3.7
Goto sendpacketbit
Return
'=========== SEND IP OCT3 END ===========

'=========== SEND IP OCT4 START ===========
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
sendipoct4:
sendbittemp = sendtoipoct4.0
Goto sendpacketbit
sendbittemp = sendtoipoct4.1
Goto sendpacketbit
sendbittemp = sendtoipoct4.2
Goto sendpacketbit
sendbittemp = sendtoipoct4.3
Goto sendpacketbit
sendbittemp = sendtoipoct4.4
Goto sendpacketbit
sendbittemp = sendtoipoct4.5
Goto sendpacketbit
sendbittemp = sendtoipoct4.6
Goto sendpacketbit
sendbittemp = sendtoipoct4.7
Goto sendpacketbit
Return
'=========== SEND IP OCT4 END ===========

'=========== SEND PACKET BUFFER START ===========
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
sendpacketbuffer:
For i = 0 To sendbuffersused - 1
sendbittemp = sendbuffer(i).0
Goto sendpacketbit
sendbittemp = sendbuffer(i).1
Goto sendpacketbit
sendbittemp = sendbuffer(i).2
Goto sendpacketbit
sendbittemp = sendbuffer(i).3
Goto sendpacketbit
sendbittemp = sendbuffer(i).4
Goto sendpacketbit
sendbittemp = sendbuffer(i).5
Goto sendpacketbit
sendbittemp = sendbuffer(i).6
Goto sendpacketbit
sendbittemp = sendbuffer(i).7
Goto sendpacketbit
Next
Return
'=========== SEND PACKET BUFFER END ===========

'=========== SEND PACKET BIT START ===========
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
sendpacketbit:
Goto syncsendpacketbit
TRISB.3 = 0  'SET DATALINE1 pin to OUTPUT
PORTB.3 = sendbittmp  'SEND PACKET TO DATALINE1
TRISB.3 = 1  'SET DATALINE1 pin to INPUT
WaitMs 10  'WAIT FOR EVERYONE TO READ THE BIT (10 milliseconds)
Goto unsyncsendpacketbit
Return
'=========== SEND PACKET BIT END ===========

'=========== SYNC SEND PACKET BIT BIT START ===========
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
syncsendpacketbit:
TRISB.1 = 0  'SET SYNC4CHAR dataline1 pin to OUTPUT
PORTB.1 = 1  'TRIGGER SYNC4CHAR data1
Return
'=========== SYNC SEND PACKET BIT BIT END ===========

'=========== UN SYNC SEND PACKET BIT START ===========
'PARAMETERS: sendpacketdirection (1=HOST 0=CLIENTS)
unsyncsendpacketbit:
TRISB.1 = 0  'SET SYNC4CHAR dataline1 pin to OUTPUT
PORTB.1 = 0  'UN TRIGGER SYNC4CHAR data1
Return
'=========== UN SYNC SEND PACKET BIT END ===========

'************************************ SHARED FUNCTIONS END ************************************
'############################################
'          PROTCOL FUNCTIONS END
'############################################