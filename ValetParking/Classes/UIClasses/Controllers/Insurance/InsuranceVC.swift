//
//  InsuranceVC.swift
//  ValetParking
//
//  Created by Apple on 09/04/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit

class InsuranceVC: UIViewController {

    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var backBtnImg:UIImageView!
    
    var InsuranceVCDelegate:DefaultDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        lbl.text = "Coming soon!!!"

        backBtnImg.isUserInteractionEnabled = true
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backAction))
        backBtnImg.addGestureRecognizer(backTap)
        // Do any additional setup after loading the view.
    }
    @objc func backAction(){
        navigationController?.popViewController(animated: false)
        InsuranceVCDelegate?.shouldNavBack()
    }
}

