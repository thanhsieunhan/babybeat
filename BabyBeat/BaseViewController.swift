//
//  BaseViewController.swift
//  BabyBeat
//
//  Created by Lê Hà Thành on 12/4/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

import UIKit

//Admob Settings
let kAdmobAppID = "ca-app-pub-6773018240487175~6584226448"
let kAdmobUnitID = "ca-app-pub-6773018240487175/2014426044"

//ChartBoost Settings
let kChartBoostAppID = "583bb01f43150f089f8804ce"
let kChartBoostAppSignature = "58afcd0e69c3701bfb2df6eeaa7d1b7d06954988"

var kChartBoostTime = Date()

class BaseViewController: UIViewController , ChartboostDelegate, GADBannerViewDelegate{

    var bannerView : GADBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addChartbootsAds()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        createAdmob()
    }
    
    func didFail(toLoadInterstitial location: String!, withError error: CBLoadError) {
        print(location, error)
    }
    
    func didFail(toLoadRewardedVideo location: String!, withError error: CBLoadError) {
        print(location, error)
    }
    
    func createAdmob() {
        var yOrigin : CGFloat = 0
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            yOrigin = 90.0
        case .phone:
            yOrigin = 50.0
        case .unspecified:
            yOrigin = 50.0
        default:
            yOrigin = 50.0
        }
        
        if bannerView == nil {
            bannerView = GADBannerView(adSize:kGADAdSizeSmartBannerPortrait,origin: CGPoint(x: 0, y: view.bounds.size.height - yOrigin))
            bannerView?.center.x = view.center.x
            bannerView?.delegate = self
            bannerView?.adUnitID = kAdmobUnitID
            bannerView?.rootViewController = self
            self.view.addSubview(bannerView!)
            bannerView?.load(GADRequest())
        }
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("did receiveAd")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
    
    func addChartbootsAds() {
        let elapsed = Date().timeIntervalSince(kChartBoostTime)
        
        if Int(elapsed) > 60 {
            print("Show ChartBoost")
            
            kChartBoostTime = Date()
            
            Chartboost.start(withAppId: kChartBoostAppID, appSignature: kChartBoostAppSignature, delegate: self)
            
            Chartboost.cacheInterstitial(CBLocationHomeScreen)
            Chartboost.cacheRewardedVideo(CBLocationHomeScreen)
            
            if Chartboost.hasInterstitial(CBLocationHomeScreen) {
                Chartboost.showInterstitial(CBLocationHomeScreen)
            }else{
                Chartboost.cacheInterstitial(CBLocationHomeScreen)
            }
            
            if Chartboost.hasRewardedVideo(CBLocationHomeScreen) {
                Chartboost.showRewardedVideo(CBLocationHomeScreen)
            }else{
                Chartboost.cacheRewardedVideo(CBLocationHomeScreen)
            }
            
            Chartboost.setShouldRequestInterstitialsInFirstSession(true)
        }else{
            print("ChartBoost not showing")
        }
    }

    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
