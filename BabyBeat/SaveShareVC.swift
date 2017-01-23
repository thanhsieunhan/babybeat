//
//  SaveShareVC.swift
//  BabyBeat
//
//  Created by Lê Hà Thành on 12/4/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

import UIKit
import AVFoundation
import FDWaveformView
import AssetsLibrary
class SaveShareVC: BaseViewController {
    
    @IBOutlet weak var waveForm: FDWaveformView!
    var audioPlayer : AVAudioPlayer!
    var engine = AVAudioEngine()
    
    var reverbValue : Float = 0
    var distortionValue : Float = 0
    var delayValue : Float = 0
    var delayTime : TimeInterval = 1
    var timeFile = ""
    var playMusic = false
    var time = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNewButton()
        print(reverbValue, distortionValue, delayValue, delayTime)
        if !playMusic {
            
            addButtonShare()
            create(reverbValue, distortionValue, delayValue, delayTime)
            
            let url2 = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            self.waveForm.progressColor = UIColor(red:0.99, green:0.00, blue:0.51, alpha:1.0)
            self.waveForm.audioURL = url2
            let avplayer = try! AVAudioPlayer(contentsOf: url2)
            time = Double(avplayer.duration)
            
        } else {
            addBackButton()
            print("Play song")
            let url2 = getDocumentsDirectory().appendingPathComponent(timeFile).appendingPathExtension("aac")
            
            playSound(url2)
            
            self.waveForm.audioURL = url2
            
            self.waveForm.progressColor = UIColor(red:0.99, green:0.00, blue:0.51, alpha:1.0)
            
            let avplayer = try! AVAudioPlayer(contentsOf: url2)
            time = Double(avplayer.duration)
            
        }
        let url2 = getDocumentsDirectory().appendingPathComponent(timeFile).appendingPathExtension("aac")
        audioAsset = AVAsset(url: url2)
        let url = Bundle.main.bundleURL.appendingPathComponent("videobgbabybeat-1.mov")
        firstAsset = AVAsset(url: url)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.engine.stop()
        if let audioPlay = audioPlayer {
            if audioPlay.isPlaying {
                audioPlay.stop()
            }
        }
        
    }
    func addBackButton(){
        
        let button: UIButton = UIButton.init(type: .custom)
        
        button.setImage(UIImage(named: "backBtn.png"), for: .normal)
        
        
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
        button.addTarget(self, action: #selector(pushBack), for: .touchUpInside)
    }
    
    func addNewButton(){
        
        let button: UIButton = UIButton.init(type: .custom)
        
        button.setImage(UIImage(named: "newRecordingBtn.png"), for: .normal)
        
        button.addTarget(self, action: #selector(pushMainVC), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 93, height: 50)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func pushMainVC(){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func pushBack(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveMusic(_ sender: Any) {
        merge()
    }
    var firstAsset: AVAsset?
    var audioAsset: AVAsset?
    func merge(){
        if let firstAsset = firstAsset {
            let mixComposition = AVMutableComposition()
            
            let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, (audioAsset?.duration)!), of: firstAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: kCMTimeZero)
            } catch {
                print("error")
            }
            
            let mainInstruction = AVMutableVideoCompositionInstruction()
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, (audioAsset?.duration)!)
            
            let firstInstruction = videoCompositionInstructionForTrack(track: firstTrack, asset: firstAsset)
            firstInstruction.setOpacity(0.0, at: (audioAsset?.duration)!)
            
            mainInstruction.layerInstructions = [firstInstruction]
            let mainComposition = AVMutableVideoComposition()
            mainComposition.instructions = [mainInstruction]
            mainComposition.frameDuration = CMTimeMake(1, 30)
            mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            if let loadedAudioAsset = audioAsset {
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,  loadedAudioAsset.duration), of: loadedAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0], at: kCMTimeZero)
                } catch {
                    print("error")
                }
            }
            
            let url = getDocumentsDirectory().appendingPathComponent(timeFile).appendingPathExtension("mov")
            print(url)
            guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
                return
            }
            exporter.outputURL = url
            exporter.outputFileType = AVFileTypeQuickTimeMovie
            exporter.shouldOptimizeForNetworkUse = true
            exporter.videoComposition = mainComposition
            
            exporter.exportAsynchronously(completionHandler: {
                DispatchQueue.main.async {
                    self.exportDidFinish(session: exporter)
                }
            })
            
        }
        
        
    }
    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
        let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
        print(scaleToFitRatio)
        print(scaleFactor)
        instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                                 at: kCMTimeZero)
        return instruction
    }
    
    func exportDidFinish(session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed {
            let outputURL = session.outputURL
            let library = ALAssetsLibrary()
            if library.videoAtPathIs(compatibleWithSavedPhotosAlbum: outputURL) {
                
                library.writeVideoAtPath(toSavedPhotosAlbum: outputURL, completionBlock: { (assetURL, error) in
                    var titleName = ""
                    var message = ""
                    if error != nil {
                        titleName = "Error"
                        message = "Failed to save video"
                    } else {
                        titleName = "Success"
                        message = "Video saved"
                    }
                    let alert = UIAlertController(title: titleName, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
                
            }
        }
        
        firstAsset = nil
        audioAsset = nil
        
    }
    
    func create(_ reverbValue: Float,_ distortionValue: Float, _ delayValue: Float,_ delayTime: TimeInterval){
        
        engine.stop()
        engine = AVAudioEngine()
        let url2 = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let f2 = try! AVAudioFile(forReading: url2)
        let buffer = AVAudioPCMBuffer(pcmFormat: f2.processingFormat, frameCapacity: UInt32(f2.length))
        try! f2.read(into:buffer)
        
        let player2 = AVAudioPlayerNode()
        self.engine.attach(player2)
        
        
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = reverbValue
        self.engine.attach(reverbNode)
        
        let distortionNode = AVAudioUnitDistortion()
        distortionNode.loadFactoryPreset(.speechAlienChatter)
        distortionNode.wetDryMix = distortionValue
        distortionNode.preGain = 0
        engine.attach(distortionNode)
        
        let delayNode = AVAudioUnitDelay()
        delayNode.delayTime = delayTime
        delayNode.feedback = 50
        delayNode.lowPassCutoff = 5000
        delayNode.wetDryMix = delayValue
        
        engine.attach(delayNode)
        
        
        self.engine.connect(player2, to: reverbNode, format: f2.processingFormat)
        let mixer = self.engine.mainMixerNode
        engine.connect(reverbNode, to: distortionNode, format: f2.processingFormat)
        engine.connect(distortionNode, to: delayNode, format: f2.processingFormat)
        engine.connect(delayNode, to: mixer, format: f2.processingFormat)
        
        let outurl = getDocumentsDirectory().appendingPathComponent("\(timeFile).aac")
        
        let outfile = try! AVAudioFile(forWriting: outurl, settings: [
            AVFormatIDKey : kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey : 1,
            AVSampleRateKey : 22050,
            ])
        
        // install a tap on the reverb effect node
        var done = false // flag: don't stop until input buffer is empty!
        delayNode.installTap(onBus:0, bufferSize: 4096, format: outfile.processingFormat) {
            buffer, time in
            // stop when input is empty and sound is very quiet
            if done && outfile.length > f2.length {
                print("stopping")
                player2.stop()
                self.engine.stop()
                self.engine.reset()
                return
            }
            do {
                try outfile.write(from:buffer)
            } catch {
                print(error)
            }
        }
        
        
        player2.scheduleBuffer(buffer) {
            done = true
            self.playSound(outurl)
        }
        self.engine.prepare()
        try! self.engine.start()
        player2.play()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var check = true
        self.waveForm.progressSamples = 0
        if check {
            UIView.animate(withDuration: time, delay: 0, options: .repeat, animations: {
                self.waveForm.progressSamples = self.waveForm.totalSamples
            }, completion: nil)
            check = false
        }
    }
    
    func playSound(_ url:URL) {
        do {
            try self.audioPlayer = AVAudioPlayer(contentsOf: url)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
            audioPlayer.numberOfLoops = -1
            print("starting to play?")
        } catch { print("failed to create audio player from \(url)") }
    }
    
    func addButtonShare(){
        
        let button: UIButton = UIButton.init(type: .custom)
        
        button.setImage(UIImage(named: "systemShareBtn.png"), for: .normal)
        
        
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
        button.addTarget(self, action: #selector(share), for: .touchUpInside)
        
    }
    
    func share() {
        
        let file = getDocumentsDirectory().appendingPathComponent(timeFile).appendingPathExtension("mov")
        let activityVC = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [
            .postToFacebook, .postToTwitter, .postToFlickr,
            .postToWeibo, .message]
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
}
