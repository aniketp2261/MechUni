//
//  CCResultViewController.swift
//  CCIntegrationKit_Swift
//
//  Created by Ram Mhapasekar on 7/7/17.
//  Copyright © 2017 Ram Mhapasekar. All rights reserved.
//

import UIKit

class CCResultViewController: UIViewController {

    var transStatus = String()
    
    let resultLable: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var homeBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.orange
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.orange.cgColor
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("  Go Back To Home Page  ", for: .normal)
        button.addTarget(self, action: #selector(goToHomeClick), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print(transStatus)
        self.view.addSubview(resultLable)
        self.view.addSubview(homeBtn)
        resultLable.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        resultLable.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        homeBtn.topAnchor.constraint(equalTo: self.resultLable.bottomAnchor, constant: 20).isActive = true
        homeBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        homeBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.resultLable.text = transStatus
        self.resultLable.reloadInputViews()
    }
    
    
    
    @objc fileprivate func goToHomeClick(sender:UIButton){
       UserDefaults.standard.setValue("home", forKey: "SelectedTab")
       Constants.appDelegate!.moveToHome()
    }
}
