//
//  TutorialTable.swift
//  BabyBeat
//
//  Created by Lê Hà Thành on 12/18/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

import UIKit

class TutorialTable: UITableViewCell {

    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imageTutorial: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
