//
//  AudioInfo.swift
//  BabyBeat
//
//  Created by Lê Hà Thành on 12/15/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

class AudioInfo {
    var name : String?
    var path : String?
    var time : String?
    init(name: String, path: String, time: String) {
        self.name = name
        self.path = path
        self.time = time
    }
}
