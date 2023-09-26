# BlitzMax-FFT-Class V0.99 
This class contains various functions of Fast Fourier Transformation in the language Basic (BitzMax)

At Syntaxbomb ou will find a tutorial with Discussion and additional informations: 
https://www.syntaxbomb.com/tutorials/fft-fast-fourier-transformation-in-blitzmax-ng/


# Reference:

## FFT.AnalyseTAudioSample()
` Function  AnalyseTAudioSample(Audio:TAudioSample, Start:Int, Length:Int, CallBackName: Byte Ptr)`

This is the universal MAIN function when you have a trad. TAudioSample in SF_MONO16LE. It expects a TAudioSample and the desired window size. At the end the function reports "ready" to a callback function.
Example:
 ```FFT:FFT_Class = New FFT_Class
Audio:TAudioSample = LoadAudioSample("...."
FFT.AnalyseTAudioSample Audio, 0, 2048 , MyDoneFunction
....
Function MyDoneFunction()
	local Out:Double[] = FFT.GetResultArray()
	' do whatever you want to do
End Function
``` 

## FFT.MainFrequency()
` Function  MainFrequency:Int()` 

returns the loudest frequency found in audio
Example:
 ``` FFT.Analyse Audio, 2048 , MyDoneFunction
...
local Loudest:Int = FFT.MainFrequency()
``` 

## FFT.GetListOfFrequencies()
` Function  GetListOfFrequencies:TList( sorted:Int=1, NewSampleRate:Int=0)` 

returns a list of peak frequencies found by FFT
Example:


## FFT.GetListOfTones()
` GetListOfTones:TList(sorted:Int=1, NewSampleRate:Int=0)` 

Returns a list of Tones (as MIDI NOTE NUMBERS) found by FFT

Example:


## FFT.MidiFrom()
` Function MidiFrom:Int(Frequency:Double)` 

Calculates the MIDI number related to a frequency

Example:
 ``` local Midinote:Int= FFT.MidiFrom(442) 
 ``` 

## FFT.GetResultArray()
` Function  GetResultArray:Double[](mode:Int=1)` 

returns the raw result array of the FFT
Example:


## FFT.Analyse()
` Function  AnalyseTAudioSample(Audio:TAudioSample, Start:Int, Length:Int, CallBackName: Byte Ptr)` 

This is a deeper MAIN function for valid Audio in a 64bit-"Double" array give FFT a audio adress and a window size at the end the function reports "ready" with a callback function.

Example:
 ``` Global Audio:Double[2048] = ....
FFT.Analyse Audio, 2048 , MyDoneFunction
....
Function MyDoneFunction()
	local Out:Double[] = FFT.GetResultArray()
	' do whatever you want to do
End Function
``` 

## FFT.Resolution()
` Function Resolution:Int()` 

Returns the width of one band of the analysis in Hz

Example:


## FFT.WindowTime()
` Function WindowTime:Int()`

Returns the length of the examined audio in msec

Example:


## FFT.RemoveBand()
` Function  RemoveBand(FromHz:Int, ToHz: Int)` 
You can manipulate the result of the FFT. Afterward you can recreate the audio from this.
Here: removed frequencies in an audio material (still in development).

Example:
 ``` FFT.Analyse Audio, 2048 , MyDoneFunction
...
FFT.Remove(2000,3000)
NewAudio:Double=FFT.InverseFFT()
``` 

## FFT.InverseFFT()
` Function  InverseFFT:Double[]()` 
You can manipulate the result of the FFT. Afterward you can recreate the audio from this.
Here: Calculates back the audio signal from a given frequencies array (still in development).

Example:
 ``` FFT.Analyse Audio, 2048 , MyDoneFunction
...
FFT.Remove(2000,3000)
NewAudio:Double=FFT.InverseFFT()
``` 




