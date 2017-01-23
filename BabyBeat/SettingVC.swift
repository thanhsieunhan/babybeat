//
//  SettingVC.swift
//  BabyBeat
//
//  Created by Lê Hà Thành on 12/3/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

import UIKit
import AVFoundation
import FDWaveformView
class SettingVC: BaseViewController {
    let pitch = AVAudioUnitTimePitch()
    //    var engine: AVAudioEngine!
    var playerNode: AVAudioPlayerNode!
    var audioFile:AVAudioFile!
    
    //    var audioPlayer : AVAudioPlayer!
    
    var engine = AVAudioEngine()
    
    @IBOutlet weak var waveform: FDWaveformView!
    
    var reverbNode: AVAudioUnitReverb!
    var delayNode: AVAudioUnitDelay!
    var distortionNode: AVAudioUnitDistortion!
    var mixer: AVAudioMixerNode!
    
    var timeFormat = ""
    var timeDate = ""
    var time = 0.0
    
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    @IBOutlet weak var slider3: UISlider!
    @IBOutlet weak var slider4: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAudioEngine()
        loadAudioFile()
        addBackButton()
        addSaveButton()
        let imageHeartBeat = UIImage(named: "fiineTuneHeartBeat.png")
        let imageView = UIImageView(image: imageHeartBeat)
        
        self.navigationItem.titleView = imageView
        
        
    }
    
    func addBackButton(){
        
        let button: UIButton = UIButton.init(type: .custom)
        
        button.setImage(UIImage(named: "backBtn.png"), for: .normal)
        
        button.addTarget(self, action: #selector(HistoryVC.pushMainVC), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func addSaveButton(){
        
        let button: UIButton = UIButton.init(type: .custom)
        
        button.setImage(UIImage(named: "saveAndShareBtn.png"), for: .normal)
        
        button.addTarget(self, action: #selector(pushSaveShareVC), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 93, height: 50)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func pushMainVC(){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func resetButton(_ sender: Any) {
        slider1.value = 0
        slider2.value = 0
        slider3.value = 0
        slider4.value = 1
        
        reverbNode.wetDryMix = 0
        distortionNode.wetDryMix = 0
        delayNode.wetDryMix = 0
        delayNode.delayTime = 1
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var check = true
        self.waveform.progressSamples = 0
        if check {
            UIView.animate(withDuration: time, delay: 0, options: .repeat, animations: {
                self.waveform.progressSamples = self.waveform.totalSamples
            }, completion: nil)
            check = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerNode.pause()
    }
    
    
    
    
    func loadAudioFile() {
        
        let fileURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        self.waveform.audioURL = fileURL
        
        
        self.waveform.progressColor = UIColor(red:0.99, green:0.00, blue:0.51, alpha:1.0)
        do {
            audioFile = try AVAudioFile(forReading: fileURL)
            let avplayer = try! AVAudioPlayer(contentsOf: fileURL)
            time = Double(avplayer.duration)
        } catch {
            print("error \(error.localizedDescription)")
        }
        
        if !playerNode.isPlaying{
            playMusic()
            playerNode.play()
            
        }
        
        
    }
    // repeat
    func playMusic(){
        playerNode.scheduleFile(audioFile, at: nil) {
            self.playMusic()
        }
    }
    
    
    func initAudioEngine () {
        
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        engine.attach(playerNode)
        
        mixer = engine.mainMixerNode
        
        mixer.outputVolume = 1.0
        mixer.pan = 0.0 // -1 to +1
        
        
        do {
            try engine.start()
        } catch {
            print("error \(error.localizedDescription)")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingVC.configChange(_:)), name: NSNotification.Name.AVAudioEngineConfigurationChange, object: engine)
        reverb()
        distortion()
        delay()
        
        let format = mixer.outputFormat(forBus: 0)
        
        engine.connect(playerNode, to: reverbNode, format: format)
        engine.connect(reverbNode, to: distortionNode, format: format)
        engine.connect(distortionNode, to: delayNode, format: format)
        engine.connect(delayNode, to: mixer, format: format)
    }
    
    func reverb(){
        reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        engine.attach(reverbNode)
        reverbNode.wetDryMix = 0.0
    }
    
    func distortion(){
        distortionNode = AVAudioUnitDistortion()
        distortionNode.loadFactoryPreset(.speechAlienChatter)
        // The blend is specified as a percentage. The default value is 50%. The range is 0% (all dry) through 100% (all wet).
        distortionNode.wetDryMix = 0
        //The default value is -6 db. The valid range of values is -80 db to 20 db
        distortionNode.preGain = 0
        engine.attach(distortionNode)
    }
    
    func delay() {
        delayNode = AVAudioUnitDelay()
        //The delay is specified in seconds. The default value is 1. The valid range of values is 0 to 2 seconds.
        delayNode.delayTime = 1
        
        //The feedback is specified as a percentage. The default value is 50%. The valid range of values is -100% to 100%.
        delayNode.feedback = 50
        
        // The default value is 15000 Hz. The valid range of values is 10 Hz through (sampleRate/2).
        delayNode.lowPassCutoff = 5000
        
        
        //The blend is specified as a percentage. The default value is 100%. The valid range of values is 0% (all dry) through 100% (all wet).
        delayNode.wetDryMix = 0
        
        engine.attach(delayNode)
        
    }
    
    
    func configChange(_ notification:Notification) {
        print("config change")
    }
    
    
    func pushSaveShareVC(){
        
        let saveShareVC = SaveShareVC(nibName: "SaveShareVC", bundle: nil)
        saveShareVC.reverbValue = reverbNode.wetDryMix
        saveShareVC.distortionValue = distortionNode.wetDryMix
        saveShareVC.delayValue = delayNode.wetDryMix
        saveShareVC.delayTime = delayNode.delayTime
        engine.stop()
//        playerNode.stop(
        
        createInfoAudio()
        saveShareVC.timeFile = timeFormat
        self.navigationController?.pushViewController(saveShareVC, animated: true)
    }
    
    
    @IBAction func sliderPitch(_ sender: UISlider) {
        reverbNode.wetDryMix = sender.value
    }
    @IBAction func sliderRate(_ sender: UISlider) {
        distortionNode.wetDryMix = sender.value
    }
    
    @IBAction func silderAmplify(_ sender: UISlider) {
        delayNode.wetDryMix = sender.value
    }
    
    @IBAction func silderDepth(_ sender: UISlider) {
        let t = TimeInterval(sender.value)
        delayNode.delayTime = t
        
    }
    
    func createInfoAudio(){
        
        let format = DateFormatter()
        format.dateFormat = "MM-dd-yyyy-HH-mm-ss"
        
        timeFormat = format.string(from: Date())
        
        let infoAudio : NSDictionary = ["name": timeFormat, "length" : timeDate]
        FileControll.saveToPlist(plistFileName: "History", tempDict: infoAudio, success: {
            print("Add info to Plist")
        }) { (error) in
            print(error)
        }
    }
    
}

