//
//  MainVC.swift
//  BabyBeat
//
//  Created by Lê Hà Thành on 12/4/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

import UIKit
import AVFoundation

protocol TestDelegate {
    func animateDismiss(_ popVC : UIViewController)
}

class MainVC: BaseViewController, AVAudioRecorderDelegate, TestDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var timer : Timer!
    
    var timeDevice : Date?
    var timeString = ""
    
    @IBOutlet weak var timeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        recordingSession = AVAudioSession.sharedInstance()
    }
    
    func printCurrentTime(){
        
        
        let formatDate = DateFormatter()
        formatDate.dateFormat = "mm:ss"
        
        
        let timeDate = Date(timeIntervalSinceReferenceDate: audioRecorder.currentTime)
        timeDevice = Date(timeIntervalSinceNow: audioRecorder.deviceCurrentTime)
        timeString = formatDate.string(from: timeDate)
        let timeLabelText = "Recording...\n" + timeString
        if timeLabelText != timeLabel.text {
            timeLabel.text = timeLabelText
        }
        audioRecorder.updateMeters()
//        print(audioRecorder.peakPower(forChannel: 0))
        print(audioRecorder.averagePower(forChannel: 0))
        
        
        
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings =  [AVFormatIDKey : kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey : 1,
        AVSampleRateKey : 22050,
        ]
        
        do {
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.isMeteringEnabled = true
            
            audioRecorder.delegate = self
            audioRecorder.record()
            
            timeLabel.text = "Recording...\n00:00"

            timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(printCurrentTime), userInfo: nil, repeats: true)
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    @IBAction func recordTapped(_ sender: Any) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            let settingVC = SettingVC(nibName: "SettingVC", bundle: nil)
            settingVC.timeDate = timeString
            navigationController?.pushViewController(settingVC, animated: true)
            timer.invalidate()
        }
        
        timeLabel.text = "Tap to Record"
    }
      
    @IBAction func popUpTutorial(_ sender: Any) {
        let tutorialVC = TableViewController(nibName: "TableViewController", bundle: nil)
        tutorialVC.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        displayContentController(tutorialVC, width: view.frame.width*9/10, height: view.frame.height*4/5)
    }
    
    @IBAction func pushToHistory(_ sender: Any) {
        let historyVC = HistoryVC(nibName: "HistoryVC", bundle: nil)
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    func createBlurView() -> UIView {
        let blurView = UIView(frame: view.bounds)
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        blurView.addSubview(blurEffectView)
        return blurView
    }
    var popUpVC : UIViewController?
    var blurView : UIView?
    
    func displayContentController(_ content : UIViewController,width:CGFloat,height:CGFloat) {
        popUpVC = content
        
        blurView = createBlurView()
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismissGesture(_ :)))
        blurView?.addGestureRecognizer(dismissTapGesture)
        
        view.addSubview(blurView!)
        
        addChildViewController(content)
        
        content.view.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        content.view.alpha = 0.5
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.transitionFlipFromTop, animations: {
            
            content.view.alpha = 1.0
            content.view.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            self.view.addSubview(content.view)
            content.didMove(toParentViewController: self)
            
        }, completion: nil)
    }
    
    func animateDismiss(_ popVC : UIViewController) {
        let bound = popVC.view.bounds
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            
            popVC.view.alpha = 0.5
            popVC.view.center = CGPoint(x: self.view.bounds.width/2.0, y: -bound.height)
            self.blurView?.alpha = 0.0
            
        }){(Bool) in
            popVC.view.removeFromSuperview()
            popVC.removeFromParentViewController()
            self.blurView?.removeFromSuperview()
        }
    }
    
    func tapDismissGesture(_ tapGesture : UITapGestureRecognizer) {
        animateDismiss(popUpVC!)
        self.navigationController?.isNavigationBarHidden = false
    }

}
