//
//  TableViewController.swift
//  BabyBeat
//
//  Created by Lê Hà Thành on 12/18/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBOutlet var myTable: UITableView!
    let infomation = ["It is possible to hear your baby's heartbeat from as early as 19-20 weeks in pregnancy, but it's higher chance to hear it in the last trimester as the baby gets bigger and the hearbeat stronger.\n\nTo record place you iPhone as shown in the picture, gently press on belly and tap button to start reording. When you want to finish recording tap again to stop recording.", "If you don't hear your baby heartbeat try other positions", "If you still can't hear your baby heartbeat don't worry it doesn't mean anything is wrong with your baby. Wait for someday and try again to record.\n\nYou can also try to record your heartbeat"
    ]
    var delegate : TestDelegate! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTable.register(UINib(nibName: "TutorialTable", bundle: nil), forCellReuseIdentifier: "Cell")
        myTable.delegate = self
        myTable.backgroundColor = UIColor.clear
        myTable.rowHeight = UITableViewAutomaticDimension
        myTable.estimatedRowHeight = 10
        myTable.scrollRectToVisible(CGRect(), animated: false)
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator  = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)as! TutorialTable
        cell.textView.text = infomation[indexPath.row]
        cell.imageTutorial.image = UIImage(named: "tutorial\(indexPath.row+1)")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view1 = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view1.backgroundColor = UIColor(red:0.93, green:0.41, blue:0.71, alpha:1.0)
        let tutorialLabel = UILabel(frame: view1.frame)
        print(view1.frame)
        tutorialLabel.text = "TUTORIAL"
        tutorialLabel.textColor = UIColor.white
        tutorialLabel.textAlignment = .center
        tutorialLabel.font = UIFont.boldSystemFont(ofSize: 40)
        
        let closeButton = UIButton(frame: CGRect(x: tableView.frame.width - 40, y: 0, width: 40, height: 40))
        closeButton.setImage(UIImage(named: "closeBtn"), for: .normal)
        closeButton.addTarget(self, action: #selector(disMiss), for: .touchUpInside)
        view1.addSubview(closeButton)
        view1.addSubview(tutorialLabel)
        
        return view1
    }
    func disMiss(){
        print("close")
        delegate.animateDismiss(self)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

}
