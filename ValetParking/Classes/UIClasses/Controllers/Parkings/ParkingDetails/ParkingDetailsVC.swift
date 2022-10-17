//
//  ParkingDetailsVC.swift
//  ValetParking
//
//  Created by Khushal on 08/11/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit

class ParkingDetailsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mParkinngTV: UITableView!
    
    @IBOutlet weak var mEmailReceiptBtn: UIButton!
    @IBOutlet weak var mRaiseComplintBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
self.mParkinngTV.register(UINib(nibName: "ParkingDetailsCell", bundle: nil), forCellReuseIdentifier: "ParkingDetailsCell")
        self.mRaiseComplintBtn.layer.borderWidth = 1
         self.mEmailReceiptBtn.layer.borderWidth = 1
        self.mRaiseComplintBtn.layer.borderColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0).cgColor
        self.mEmailReceiptBtn.layer.borderColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0).cgColor
        
    }
// Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingDetailsCell", for: indexPath) as! ParkingDetailsCell
        return cell
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//Button Actions
    
    @IBAction func mCloseActn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
