//
//  HistoryVC.swift
//  BabyBeat
//
//  Created by Lê Hà Thành on 12/4/16.
//  Copyright © 2016 Lê Hà Thành. All rights reserved.
//

import UIKit

class HistoryVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var myTable: UITableView!
    var listRecoder : NSArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackButton()
        // Do any additional setup after loading the view.
        FileControll.getFromPlist(plistFileName: "History", success: { (list) in
            listRecoder = list
            myTable.reloadData()
        }) { (error) in
            print(error)
        }
        self.title = "History Record"
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24)]
        
        myTable.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "RecoderCell")
        myTable.delegate = self
        myTable.estimatedRowHeight = 100
        myTable.rowHeight = UITableViewAutomaticDimension
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
    
    func pushMainVC(){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "HistoryVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listRecoder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "RecoderCell", for: indexPath) as! CustomCell
        let nameFile = listRecoder[indexPath.row] as! NSDictionary

        cell.indexLabel.text = "\(indexPath.row+1)"
        cell.nameLabel.text = "\(nameFile["name"]!).aac"
        cell.lengthLabel.text = "\(nameFile["length"]!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nameFile = listRecoder[indexPath.row] as! NSDictionary
        let saveShareVC = SaveShareVC(nibName: "SaveShareVC", bundle: nil)
        saveShareVC.playMusic = true
        saveShareVC.timeFile = "\(nameFile["name"]!)"
        navigationController?.pushViewController(saveShareVC, animated: true)
    }
    

}
