//
//  ViewController.swift
//  SpeechToTextDemo
//
//  Created by Subhra Roy on 26/02/19.
//  Copyright © 2019 ARC. All rights reserved.
//

/*Note :
    1.  Apple limits recognition per device. The limit is not known, but you can contact Apple for more information.
    2. Apple limits recognition per app.
    3. If you routinely hit limits, make sure to contact Apple, they can probably resolve it.
    4. Speech recognition uses a lot of power and data.
    5. Speech recognition only lasts about a minute at a time.
 */

import UIKit
import Speech
import  NaturalLanguage

class ViewController : UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var speechTextView: UITextView!
    @IBOutlet weak var recordingBtn: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.recordingBtn.isEnabled = false
        self.speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
                case .authorized:
                    isButtonEnabled = true
                
                case .denied:
                    isButtonEnabled = false
                    print("User denied access to speech recognition")
                
                case .restricted:
                    isButtonEnabled = false
                    print("Speech recognition restricted on this device")
                
                case .notDetermined:
                    isButtonEnabled = false
                    print("Speech recognition not yet authorized")
                }
            
                OperationQueue.main.addOperation() { [weak self] in
                    self?.recordingBtn.isEnabled = isButtonEnabled
                }
        }
    }

    @IBAction func didStartOrStopRecording(_ sender: Any) {
        
        if self.audioEngine.isRunning {
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.recordingBtn.isEnabled = false
            self.recordingBtn.setTitle("Start Recording", for: .normal)
        } else {
            self.startRecording()
            self.recordingBtn.setTitle("Stop Recording", for: .normal)
        }
    }
    
    func startRecording() {
        
        if self.recognitionTask != nil {  //1
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            if #available(iOS 12.0, *){

                 try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.voicePrompt, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
                 try audioSession.setMode(AVAudioSession.Mode.voicePrompt)
            }else{
                try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
                try audioSession.setMode(AVAudioSession.Mode.measurement)
            }
           
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
           
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
                
        if  self.audioEngine.inputNode.volume > 0{
            
            let inputNode : AVAudioInputNode = self.audioEngine.inputNode
            
            guard let recognitionRequest = self.recognitionRequest else {
                fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            } //5
            
            self.recognitionRequest?.shouldReportPartialResults = true  //6
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
                
                var isFinal = false  //8
                
                if result != nil {
                    
                    self.speechTextView.text = result?.bestTranscription.formattedString  //9
                    isFinal = (result?.isFinal)!
                    
                    if isFinal{
                        
                         self.tokenisedTextWith(speechText: self.speechTextView.text)
                    }
                    
                    
                }
                
                if error != nil || isFinal {  //10
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    self.recordingBtn.isEnabled = true
                }
            })
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                self.recognitionRequest?.append(buffer)
            }
            
            self.audioEngine.prepare()  //12
            
            do {
                try self.audioEngine.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
            }
            
            self.speechTextView.text = "Say something, I'm listening!"
            
        }else{
            
            fatalError("Audio engine has no input node")
        }
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.recordingBtn.isEnabled = true
        } else {
            self.recordingBtn.isEnabled = false
        }
    }
    
}

extension ViewController : UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        print("\(String(describing: textView.text))")
        
    }
    
    
   /* private func tokenisedTextWith(speechText : String) -> Void{
        
        if #available(iOS 12.0, *) {
            
            let text = speechText
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = text

            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                
                if  text[tokenRange].count > 0 {
                    
                    let text = text[tokenRange]
                    print("\(text)")
                    let attributes  = NLTokenizer.Attributes(rawValue: UInt(text) ?? 100)
                    switch attributes {
                    case  NLTokenizer.Attributes.numeric :
                        print("\(text[tokenRange])")
                        
                        let alert : UIAlertController = UIAlertController(title: "Alert", message: "\(text)", preferredStyle: .alert)
                        self.present(alert, animated: true, completion: {
                            
                        })
                        
                    default :
                        print("Token is String Type")
                    }
                    
                }
                
                return true
            }
            
        }else{
            
        }
        
    }*/
    
    private func tokenisedTextWith(speechText : String) -> Void{
        
         if #available(iOS 12.0, *) {
            
            let text = speechText
            let tagger = NLTagger(tagSchemes: [.lexicalClass])
            tagger.string = text
            
            // select the options
            
            let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther, .joinNames]
            
            // and the tag to extract
            let tags: [NLTag] = [ .number]
            
            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
                                
                if let tagType : NLTag = tag, tags.contains(tagType) {
                        print(" \(text[tokenRange])")
                        
                        return true
                   }
                    return false
            }
            
        }else{
            
        }
        
    }
    
    
}
