

Type FFT
		' F F T - F A S T   F O U R I E R   T R A N S F O R M A T I O N
		'
		' Author Midimaster www.midimaster.de
		'
		' Copyright: Public Domain
		' Version-Info  0.99
		'
		' The FFT needs an array REAL[] with the audio-samples
		' The array needs a defined LENGTH
		' LENGTH need to be 2^n (128, 256, 512, ... ,32768)
		' A bigger LENGTH brings more results,
		' but a long audio often contains already more than one tone
		' so a good compromize is LENGTH=2^12, this means FFT-window is 85msec	

		Global ListOfTones:TList, ListOfFrequencies:TList	
		Global Real:Double[] , Imag:Double[], Out:Double[]
		Global WindowLength:Int
		Global HERTZ:Int
		Global AlreadyDone:Int =False
		Global CallBack()
		
' **************************************************************************		
' PUBLIC FUNCTIONS
' **************************************************************************		

		Function  AnalyseTAudioSample(Audio:TAudioSample, Start:Int, Length:Int, CallBackName: Byte Ptr)
		' PUBLIC
		' this is the universal MAIN function when you have a trad. TAudioSample in SF_MONO16LE
		' expects a TAudioSample and the desired window size
		' at the end the function reports "ready" to a callback function.
				' example:
				'           Audio:TAudioSample =LoadAudioSample("....
				'            
				'           FFT.AnalyseTAudioSample Audio, 0, 2048 , MyDoneFunction
				'           ....
				'           Function MyDoneFunction()
				'                 local Out:Double[] = FFT.GetResultArray()
				'                 ' do whatever you want to do 
				'           End Function 
				'
				WindowLength = CalculateWindowSize(Length)
				HERTZ=Audio.Hertz
				Local locAudio:Double[]=ConvertToDouble(Audio, Start, WindowLength)
				Analyse locAudio, WindowLength, CallBackName
		End Function


		Function Analyse(Audio:Double[], Length:Int, CallBackName: Byte Ptr)
		' PUBLIC
		' this is a deeper MAIN function for valid Audio in a 64bit-"Double" array 
		' give FFT a audio adress and a window size
		' at the end the function reports "ready" with a callback function.
				' example:
				'           Global Audio:Double[2048] = ....
				'           FFT.Analyse Audio, 2048 , MyDoneFunction
				'           ....
				'           Function MyDoneFunction()
				'                 local Out:Double[] = FFT.GetResultArray()
				'                 ' do whatever you want to do 
				'           End Function 
				'
				CallBack=CallBackName
				WindowLength = CalculateWindowSize(Length)
				PrepareWindow Audio, WindowLength
				Process
				CallBack()
		End Function

		
		Function GetResultArray:Double[](mode:Int=1)
		' PUBLIC
		' returns the raw result array of the FFT
		' MODE=1 return Power of REAL and IMAG
		' MODE=2 return simply REAL
		Print mode
			If Mode=1
				Return CalculatePower()
			ElseIf Mode=3
				Return Imag
			Else
				Return OnlyReal()
			EndIf 
		End Function 


		Function GetListOfFrequencies:TList( sorted:Int=1, NewSampleRate:Int=0)
		' PUBLIC
		' returns a list of peak frequencies found by FFT
		' SampleRate= Samplerate of the TaudioSample, if not already known
		' SORTED=1 Sorted by Frequency
		' SORTED=2 Sorted by Signalstrength (loudest first)
			If  NewSampleRate<>0 HERTZ = NewSampleRate
			
			Out = CalculatePower()
			Local List:TList =New TList
			RuntimeError   "function GetListOfFrequencies not ready"
			Return List
		End Function 
		
		
		Function GetListOfTones:TList(sorted:Int=1, NewSampleRate:Int=0)
		' PUBLIC
		' returns a list of Tones (as MIDI NOTE NUMBERS) found by FFT
		' SampleRate= Samplerate of the TaudioSample, if not already known
		
		' SORTED=1 Sorted by Frequency
		' SORTED=2 Sorted by Signalstrength (loudest first)
			Out = CalculatePower()
			Local PeakList:TList= GetListOfFrequencies( sorted, NewSampleRate)
			Local List:TList =New TList
			RuntimeError   "function GetListOfTones not ready"
			Return List
		End Function 


		Function MainFrequency:Int()
			Local da:Int, Maxi:Double
			For Local i%=0 Until OUT.Length
				If OUT[i]>Maxi
					Maxi=OUT[i]
					da=i
				EndIf 
			Next 
			Return GetFrequency(Da)
		End Function 

		
		Function Resolution:Int()
			Return HERTZ/WindowLength
		End Function 


		Function WindowTime:Int()
			Return 1000*WindowLength/HERTZ
		End Function 

		
' **************************************************************************		
' PRIVATE FUNCTIONS
' **************************************************************************	
	
		Function CalculateWindowSize:Int(AnySize:Int)
		' PRIVATE
	    ' calculates allowed power-of-2 array length for FFT
				Local ValidSize:Int=1
				Repeat
					anysize   = anysize/2
					ValidSize = ValidSize*2
				Until AnySize<2
				Return ValidSize
		End Function
		

		Function GetFrequency:Int(At:Int)
			If HERTZ=0 RuntimeError "Need given Sample-Rate first" 
			If WindowLength=0 RuntimeError "Need FFT-Analyse first" 
			Return Int(At*HERTZ/WindowLength)
		End Function 


		Function GetPeak:Double(At:Int)
			If AlreadyDone=False RuntimeError "first calculate results!"
			Return Out[At]
		End Function 


		Function CalculatePower:Double[]()
		' PRIVATE
		' combines the Real and the Imaginary Array to a result 
				Out = New Double[WindowLength/2]
				For Local i:Int=1 Until WindowLength/2
						out[i] = Sqr((Imag[i] * Imag[i]) + (Real[i] * Real[i]))
				Next 
				AlreadyDone=True
				Return out
		End Function 


		Function OnlyReal:Double[]()
		' PRIVATE
		' returns the Real Array as a result 
				Out = New Double[WindowLength/2]
				For Local i:Int=1 Until WindowLength/2
						out[i] = Real[i]
				Next 
				AlreadyDone=True
				Return out
		End Function 

		 
		Function Process()
		' PRIVATE
		' STEP: BIT REVERSING:
				Local Length:Int = WindowLength
				Local Middle:Int = Length/2
				Local j:Int = Middle

				For Local I:Int = 1 To Length - 2 
					If I < j Then
						Local loc:Double = Real[j]
						Real[j] = Real[I]
						Real[i] = loc
						' absolet, wenn Imag[]=0
						loc     = Imag[j]
						Imag[j] = Imag[I]
						Imag[i] = loc
					End If
					Local K:Int  = Middle
					While K <= j
						j = j - K
						K = K / 2
					Wend
					j = j + K
				Next 
		' STEP: FFT CALCULATION
				Local Potenz:Int=1
				For Local L:Int  = 1 Until Int(Log(Length) / Log(2))   
					Potenz:Int = Potenz Shl 1	

					Local Ur:Double = 1.0
					Local Ui:Double = 0
					Local arc:Double=  Double(180.0)/ Double(Potenz)
					Local Sr:Double =  Cos(arc)
					Local Si:Double = -Sin(arc)
					
					For Local j:Int = 0 To Potenz-1 
						Local i:Int = j
						While I < Length
							Local Ip:Int    = I + Potenz					
							Local TR:Double = Real[ip] * Ur - Imag[ip] * Ui 
							Local TI:Double = Real[ip] * Ui + Imag[ip] * Ur
							Real[ip] = Real[i] - TR
							Imag[ip] = Imag[i] - TI
							Real[i]  = Real[i] + TR
							Imag[i]  = Imag[i] + TI
							I        = I + 2*Potenz 
						Wend
						Local loc:Double = Ur
						Ur = loc * Sr - Ui * Si
						Ui = loc * Si + Ui * Sr
					Next 
				Next 	
				
				For Local i%=0 Until length/2
				'		Print i + "-->REAL=" + Int(real[i]) + "  --->IMAG="  + Int(imag[i])
				Next 
		End Function
		
		
		
		Function PrepareWindow(Audio:Double[], size:Int)
		'PRIVATE
		' fills the two FFT-arrays: one with the audio-window, the other is  reseted only
				AlreadyDone=False
				Real = New Double[size]
				Imag = New Double[size]
				For Local I%=0 Until  size
					Real[i] = Audio[i]
					Imag[i] = 0
				Next 
		End Function 	
		
		
		Function ConvertToDouble:Double[](Audio: TAudioSample, StartAt:Int, size:Int)
		'PRIVATE
		' brings trad. BlitzMax TAudioSample into Double-FlotingPoint-Format
				Local locAudio:Double[size]
				For Local I%=0 Until  size
					Local s:Double=ShortToInt(Audio.Samples[StartAt + i])
					locAudio[i] = S/32000.0
				Next 
				Return locAudio
		End Function 	

		Function ShortToInt:Int( s:Int )
				Return (s Shl 16) Sar 16
		End Function
		
		
		Function MidiFrom:Int(Frequency:Double)
			Local NoteC:Double    = 16.3515625
			Local NoteStep:Double =  1.0594630961707261
			Local HalfStep:Double =  1.0293022375234235

			Local Oktave%=1
			Local tone%=0
			Repeat
				oktave:+1
				NoteC:*2.0
			Until NoteC*2>Frequency
			Repeat
				tone:+1
				NoteC:*NoteStep
			Until NoteC*HalfStep>Frequency
			Return (oktave*12+tone)
		End Function 	
		
		
		Function InverseFFT:Double[]()
			Local Teiler:Double = 1.0/ Double(WindowLength)

			For Local i%=0 Until WindowLength
				'FFT_Imag[i]: *-1
				Imag[i]:*-1
				'Imag[i]=0
			Next

			'FFTAnalyse_II WindowLength, FFT_Real, FFT_IMag, Imag, Real
			'Analyse Real,  WindowLength, CallBackDone
			process
			For Local i:Int=0 Until WindowLength
				Real[i]:*Teiler
			'	Imag[i]:= *-1
			'	Real[i]= Real[i]
			Next 
			Return Real
		End Function 
		
		
		Function FreqToBand:Int(Hz:Int)
			For Local i%=0 Until WindowLength
				If GetFrequency(i)>Hz
					Return i
				EndIf 
			Next 
			Return WindowLength-1
		End Function 

		
		Function RemoveBand(FromHz:Int, ToHz: Int)
			Local Start:Int= FreqToBand(FromHz)
			Local Stop:Int= FreqToBand(ToHz)
			 
			For Local i%=start To  Stop
				Real[i]=0
				Imag[i]=0
			Next 
		End Function 
		
		
		Function MoveBands(f:Double)
			If f>1 Return 
			For Local da%=WindowLength To 0 Step -1
				Real[da]=Real[da*f]
				Imag[da]=Imag[da*f]
			Next 
		End Function 
		
End Type


