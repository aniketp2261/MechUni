//
//  FooterView.swift
//  ValetParking
//
//  Created by Khushal on 19/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit

class FooterView: UIView {

    
    @IBOutlet var contentView: UIView!
    //labels
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var ticketsLabel: UILabel!
    @IBOutlet weak var myCarsLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    //images
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var ticketsImage: UIImageView!
    @IBOutlet weak var myCarsImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit()
    {
        Bundle.main.loadNibNamed("FooterView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        homeImage.image = homeImage.image!.withRenderingMode(.alwaysTemplate)
        ticketsImage.image = ticketsImage.image!.withRenderingMode(.alwaysTemplate)
        myCarsImage.image = myCarsImage.image!.withRenderingMode(.alwaysTemplate)
        profileImage.image = profileImage.image!.withRenderingMode(.alwaysTemplate)
       
        let selectedTab =  UserDefaults.standard.string(forKey: "SelectedTab")
        
        if(selectedTab == "home")
        {
            homeImage.tintColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0)
            homeLabel.textColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0)
            ticketsImage.tintColor = UIColor.black
            ticketsLabel.textColor = UIColor.black
            myCarsImage.tintColor = UIColor.black
            myCarsLabel.textColor = UIColor.black
            profileImage.tintColor = UIColor.black
            profileLabel.textColor = UIColor.black
            
        }
        else if(selectedTab == "tickets")
        {
            homeImage.tintColor = UIColor.black
            homeLabel.textColor = UIColor.black
            ticketsImage.tintColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0)
            ticketsLabel.textColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0)
            myCarsImage.tintColor = UIColor.black
            myCarsLabel.textColor = UIColor.black
            profileImage.tintColor = UIColor.black
            profileLabel.textColor = UIColor.black
        }
        else if(selectedTab == "myCars")
        {
            homeImage.tintColor = UIColor.black
            homeLabel.textColor = UIColor.black
            ticketsImage.tintColor = UIColor.black
            ticketsLabel.textColor = UIColor.black
            myCarsImage.tintColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0)
            myCarsLabel.textColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0)
            profileImage.tintColor = UIColor.black
            profileLabel.textColor = UIColor.black
        }
        else if(selectedTab == "profile")
        {
            homeImage.tintColor = UIColor.black
            homeLabel.textColor = UIColor.black
            ticketsImage.tintColor = UIColor.black
            ticketsLabel.textColor = UIColor.black
            myCarsImage.tintColor = UIColor.black
            myCarsLabel.textColor = UIColor.black
            profileImage.tintColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0)
            profileLabel.textColor = UIColor(red:0.40, green:0.18, blue:0.56, alpha:1.0)
        }
    }

    @IBAction func buttonActn(_ sender: Any) {
        let b = sender as? UIButton
        customButtonPressed(Int(b?.tag ?? 0))
    }
    
    
    func customButtonPressed(_ buttonTag: Int)
    {
        _ =  UserDefaults.standard.string(forKey: "SelectedTab")
        for i in 1..<6 {
            let b = viewWithTag(i) as? UIButton
            if b?.tag == buttonTag {
                if b?.tag == 1
                {
                    UserDefaults.standard.setValue("home", forKey: "SelectedTab")
                    if !(Constants.appDelegate?.nVc.visibleViewController is HomeVC) {
                        Constants.appDelegate?.homeButtonClicked()
                    }
                }
                else if b?.tag == 2
                {
                    UserDefaults.standard.setValue("tickets", forKey: "SelectedTab")
                    Constants.appDelegate?.ticketsButtonClicked()
                }
                else if b?.tag == 3
                {
                    UserDefaults.standard.setValue("myCars", forKey: "SelectedTab")
                    Constants.appDelegate?.myCarsButtonClicked()
                }
                else if b?.tag == 4
                {
                    UserDefaults.standard.setValue("profile", forKey: "SelectedTab")
                    Constants.appDelegate?.profileButtonClicked()
                }
                
            }
        }
    }
        
    
    
    
    
    
    
    
    
   
}
