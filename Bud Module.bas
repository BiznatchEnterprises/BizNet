Dim sepbyte As Byte
Dim ipao1 As Byte
Dim ipao2 As Byte
Dim ipao3 As Byte
Dim ipao4 As Byte
Dim ipbo1 As Byte
Dim ipbo2 As Byte
Dim ipbo3 As Byte
Dim ipbo4 As Byte
Dim ipco1 As Byte
Dim ipco2 As Byte
Dim ipco3 As Byte
Dim ipco4 As Byte
Dim packsa As Byte
Dim packsb As Byte
Dim packsc As Byte
Dim databuffa(80) As Byte
Dim databuffb(80) As Byte
Dim databuffc(80) As Byte
Dim tempbyte(25) As Byte
Dim tempbit1 As Bit
Dim tempbit2 As Bit
Dim tempbit3 As Bit
Dim tempbit4 As Bit
Dim tempbit5 As Bit
Dim tempbit6 As Bit
Dim tempbit7 As Bit
Dim tempbit8 As Bit
Dim otnd As Bit
Dim ifnd As Bit
otnd = PORTD.2
ifnd = PORTD.3


'RD3 = out to network
'RD2 = in frm network

tempbit1 = 1
tempbit2 = 0

TRISB.0 = 0  'set all port b pins to output
TRISB.1 = 0
TRISD.3 = 0  'set Out To Network Pin to output
TRISD.2 = 0  'set In Frm Network Pin to Input

'================================
startprogram:

'--write data--
If TRISD.3 = 1 Then  'verify if pin set to input
High PORTB.0  'DISPLAY DATA SENT STATUS on PortB 3 Pin
Low PORTB.1
TRISD.3 = 0  'set pin to output
PORTD.3 = 1  'set pin to high
Else
Low PORTB.0  'Display Out To Network (Ready To Send) Status Failed
High PORTB.1
Endif
'--------------
WaitMs 1000
'--READ DATA---
If TRISD.2 = 0 Then
If PORTD.2 = 1 Then
High PORTB.2
Low PORTB.3
TRISD.2 = 1
Else
Low PORTB.2
High PORTB.3
Endif
High PORTB.4
Low PORTB.5

TRISD.2 = 1
Else
Low PORTB.4
High PORTB.5
Endif
'--------------

WaitMs 1000
'TRISD.3 = 1
'TRISD.2 = 1
Goto startprogram
End
'================================
