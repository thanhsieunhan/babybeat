//
//  CustomSlider.swift
//  BabyBeat
//
//  Created by Lê Hà Thành on 12/17/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    required init?(coder: NSCoder) {
        super.init(coder:coder)
        setThumbImage(UIImage(named : "sliderHeart.png"), for: .normal)
        let sliderEmpty = UIImage(named:"sliderEmpty.png")
        setMinimumTrackImage(sliderEmpty, for:.normal)
        setMaximumTrackImage(sliderEmpty, for:.normal)

    }
}
