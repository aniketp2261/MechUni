//
//  OrderSuccessVC.swift
//  MechUni
//
//  Created by Sachin Patil on 30/05/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class OrderSuccessVC: UIViewController {

    var OrderSuccessVCDelegate: DefaultDelegate? = nil
    var OrderID = String()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func TrackOrderAction(){
        UserDefaults.standard.setValue(OrderID, forKey: "OrderID")
        let VC = UIStoryboard(name: "Services", bundle: nil).instantiateViewController(withIdentifier: "OrderDetailsVC") as! OrderDetailsVC
        self.navigationController?.pushViewController(VC, animated: false)
    }
    @IBAction func BackHomeAction(){
        print("BackHomeAction")
        let controllersCount = self.navigationController?.viewControllers.count ?? 0
        print("controllersCount--\(controllersCount)")
        let vcIndex = self.navigationController?.viewControllers.firstIndex(where: { (viewController) -> Bool in
            if let _ = viewController as? HomeVC {
                return true
            }
            return false
        })
        let composeVC = self.navigationController?.viewControllers[vcIndex!] as! HomeVC
        self.navigationController?.popToViewController(composeVC, animated: true)
        composeVC.shouldNavBack()
    }
}
