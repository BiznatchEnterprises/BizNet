Dim pctolcddata As Byte
Dim lcdtopcdata As Byte


Dim buffer(10) As Byte
Dim i As Byte



loop:
pctolcddata = 0

'''''PC TO LCD DATA RETREIVE''''
''''''''''''''''''''''''''''''''


If PORTD.0 = 1 Then  'check to see if LCDRTR is ready
	If pctolcddata <> 0 Then  'buffer is not full to start sending
	PORTD.5 = 1
	
	
	Endif	


Endif

Goto loop