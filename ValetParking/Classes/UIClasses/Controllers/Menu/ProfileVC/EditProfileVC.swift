//
//  EditProfileVC.swift
//  ValetParking
//
//  Created by admin on 18/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import SDWebImage

class EditProfileVC: UIViewController{
    
    @IBOutlet weak var profileImagView: UIImageView!
    @IBOutlet weak var usernameLbl : UILabel!
    @IBOutlet weak var dobLbl : UILabel!
    @IBOutlet weak var mobileNoLbl : UILabel!
    @IBOutlet weak var emailLbl : UILabel!
    @IBOutlet weak var editBtn : UIButton!
    @IBOutlet weak var backImg: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImagView.layer.cornerRadius = self.profileImagView.bounds.height/2
        self.editBtn.layer.borderWidth = 1
        self.editBtn.layer.borderColor = UIColor.red.cgColor
        self.editBtn.layer.cornerRadius = self.editBtn.bounds.height/2
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backAction))
        backImg.isUserInteractionEnabled = true
        backImg.addGestureRecognizer(backTap)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userImage = UserDefaults.standard.string(forKey: "userImage") ?? ""
        let userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        let dob = UserDefaults.standard.string(forKey: "dob") ?? ""
        let mobileno = UserDefaults.standard.string(forKey: "mobileNo") ?? ""
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        if userImage != ""{
            self.profileImagView.sd_setImage(with: URL(string: APIEndPoints.BASE_IMAGE_URL + userImage), placeholderImage: #imageLiteral(resourceName: "UserImage"), options: [], context: nil)
        } else{
            self.profileImagView.image = #imageLiteral(resourceName: "UserImage")
        }
        self.usernameLbl.text = userName
        self.dobLbl.text = dob
        self.mobileNoLbl.text = mobileno
        self.emailLbl.text = email
    }
    @IBAction func editBtnClicked(){
        if #available(iOS 13.0, *) {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            // Fallback on earlier versions
        }
    }
    @objc func backAction(){
        UserDefaults.standard.synchronize()
        self.navigationController?.popViewController(animated: false)
    }
}
