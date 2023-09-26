' F F T - F A S T   F O U R I E R   T R A N S F O R M A T I O N 
'
' Author Midimaster www.midimaster.de
'
' Copyright: Public Domain
' Version 	0.99 
'
'
'
' This demo shows:
' how to discover all frequencies in a complex audio sample   
' The FFT take a look (window) into the TAudioSample 
' Size is the lenghth of the window (in samples) and need to be 2^n (128, 256, 512, ... ,32768) 
' As bigger size is as more precise is the result, but a big size already contains often more than one tone
' so a good compromize is size=2^12, this means window is 85msec


SuperStrict 
Include "NewFFT_Class.bmx"
Graphics 800,600

Const SAMPLE_RATE:Int = 48000
Global  Size:Int=2^12
Print "size= "+ size

Global Music:Double[size] ' 1 second of audio material in 48Khz
Global OUT:Double[]
FFT.HERTZ=SAMPLE_RATE


'  move the MouseY up and down to change tone frequency 
'  build your own audio in function CreateMusic()
'  
'
Global PeakAt:Double, Hertz:Int
Local LastMouse:Int=-1
MoveMouse 100,100
Flip

Global RetReal:Double[size]
Repeat
	Cls
	If MouseY()<>LastMouse
	'For Local i:Int=0 To 9999
		LastMouse=MouseY()
		Hertz=LastMouse^1.35
		CreateMusic Hertz
		Local z%=MilliSecs()
		FFT.Analyse Music, size, CallBackDone
		Print "T:" + (MilliSecs()-z)
		'FFT.removeBand 3000,9999
		FFT.moveBands 0.5
		'CallBackDone()
		RetReal= FFT.InverseFFT() 
	'Next
	EndIf 
	Paint
	Flip 1
Until AppTerminate()


Function CallBackDone()
		Out = FFT.GetResultArray(1)
		PeakAt=FFT.MainFrequency()
End Function 



Function CreateMusic(Hertz:Int)
		' fills an array with sample-values (64 bit floating point, values from -1 to +1)
		Local f:Double = Hertz*360.0/SAMPLE_RATE
		
		' first tone
		For Local I:Int = 0 Until Music.length
			Music[i]=Sin(f*i)
		Next
		
		'second tone: double frequency but half volume
		For Local I:Int = 0 Until Music.length
			Music[i]  =Music[i]+ Sin(2*f*i)/2
		Next
		
		'third tone: 4x frequency but 1/4 volume
		For Local I:Int = 0 Until Music.length
			Music[i] = Music[i]+ Sin(4*f*i)/4
		Next
End Function 




'  only graphics things for the demo app:

Function Paint()
	SetColor 88,88,88
	DrawRect 5,5,790,140
	SetColor 0,255,0
	For Local i%=1 Until Min(800,Out.length)
			DrawLine  i-1, 80+Int(-Music[i-1]*30),i, 80+Int(-Music[i]*30)
	Next
	SetColor 0,255,0
	For Local i%=2 Until Min(800,Out.length) Step 2
			DrawLine  i-1, 280+Int(-retReal[i-2]*150),i, 280+Int(-retReal[i]*150)
	Next
	SetColor 255,255,0
	For Local i%=1 Until OUT.length
			DrawRect  i, 500,1, Int(-out[i])
	Next
	SetColor 111,111,255
	Local last%
	DrawRect 0,500,800,1
	For Local i%=1 Until OUT.length 
		If i*SAMPLE_RATE/size > last+480
			last=last+500
			Local t$= last/1000 +"kHz"
			DrawText  "|", i, 500
			If last Mod 1000=0 			DrawText  t, i-TextWidth(t)/2, 520
		EndIf
	Next
	SetColor 255,255,255
	DrawText "20msec Audio:     3 Tones:   " + Hertz + "Hz   +"+ (2*Hertz) + "Hz    + "+ (4*Hertz) + "Hz", 10,10
	DrawText "Length of FFT-Window = " + FFT.windowtime() + "msec", 50,560	
	DrawText "FFT Main-Frequency = " + Int(PeakAt) + "Hz", 550,560
	DrawText "         MIDI-Note = " + FFT.MidiFrom(PeakAt) + "", 550,580
	DrawText "        Resolution = " + (FFT.Resolution()) + "Hz", 50,580
End Function 
