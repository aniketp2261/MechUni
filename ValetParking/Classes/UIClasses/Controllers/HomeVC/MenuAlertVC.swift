//
//  MenuAlertVC.swift
//  ValetParking
//
//  Created by admin on 03/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import UIKit
import SDWebImage
import SafariServices
import Alamofire
import SKActivityIndicatorView

struct MenuData{
    let title:String
    let img:UIImage?
}
class MenuAlertVC: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var hamburgerMenu:UIView!
    @IBOutlet weak var menuView:UIView!
    @IBOutlet weak var UserNameLbl: UILabel!
    
    var delegate: DefaultDelegate? = nil
    var logout = false
    var isLoggedin =  UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
    
    let menuDataSource1 = [
        MenuData(title: "My Profile", img: #imageLiteral(resourceName: "ic_red_home")),
        MenuData(title: "Tickets", img: #imageLiteral(resourceName: "ic_red_tickets")),
        MenuData(title: "My Vehicles", img: #imageLiteral(resourceName: "carButtonImage")),
        MenuData(title: "My Orders", img: #imageLiteral(resourceName: "ServiceOrder")),
        MenuData(title: "Mechbrain Orders", img: #imageLiteral(resourceName: "ServiceOrder")),
        MenuData(title: "Notifications", img: #imageLiteral(resourceName: "ic_red_notification")),
        MenuData(title: "Change Password", img: #imageLiteral(resourceName: "ic_red_settings")),
        MenuData(title: "Contact Us", img: #imageLiteral(resourceName: "ic_red_contact")),
        MenuData(title: "About Us", img: #imageLiteral(resourceName: "ic_red_about")),
        MenuData(title: "Privacy policy", img: #imageLiteral(resourceName: "ic_privacy_policy")),
        MenuData(title: "Delete Account", img: #imageLiteral(resourceName: "DeleteAcc")),
        MenuData(title: "Logout", img: #imageLiteral(resourceName: "ic_red_logout")),
    ]
    let menuDataSource2 = [
        MenuData(title: "My Profile", img: #imageLiteral(resourceName: "ic_red_home")),
        MenuData(title: "Tickets", img: #imageLiteral(resourceName: "ic_red_tickets")),
        MenuData(title: "My Vehicles", img: #imageLiteral(resourceName: "carButtonImage")),
        MenuData(title: "My Orders", img: #imageLiteral(resourceName: "ServiceOrder")),
        MenuData(title: "Mechbrain Orders", img: #imageLiteral(resourceName: "ServiceOrder")),
        MenuData(title: "Notifications", img: #imageLiteral(resourceName: "ic_red_notification")),
        MenuData(title: "Change Password", img: #imageLiteral(resourceName: "ic_red_settings")),
        MenuData(title: "Contact Us", img: #imageLiteral(resourceName: "ic_red_contact")),
        MenuData(title: "About Us", img: #imageLiteral(resourceName: "ic_red_about")),
        MenuData(title: "Privacy policy", img: #imageLiteral(resourceName: "ic_privacy_policy")),
        MenuData(title: "Delete Account", img: #imageLiteral(resourceName: "DeleteAcc")),
        MenuData(title: "Login", img: #imageLiteral(resourceName: "ic_red_logout")),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.backgroundColor = .lightGray
        profileImage.layer.cornerRadius = profileImage.bounds.height/2
        menuView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileImage.superview!.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshAction), name: NSNotification.Name(rawValue: "RefreshUI"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MenuScreenAppear"), object: nil)
        if(isLoggedin == true)
        {
            print("Image --- \(UserDefaults.standard.string(forKey: "userImage") ?? "")")
            DispatchQueue.main.async {
                self.UserNameLbl.text = UserDefaults.standard.string(forKey: "userName")
                let image = UserDefaults.standard.string(forKey: "userImage")
                if image != ""{
                    self.profileImage.sd_setImage(with: URL(string: APIEndPoints.BASE_IMAGE_URL + (image ?? "")), placeholderImage: #imageLiteral(resourceName: "UserImage"), options: [], context: nil)
                } else{
                    self.profileImage.image = #imageLiteral(resourceName: "UserImage")
                }
                print("ProfileImage --- \(APIEndPoints.BaseURL)\(image ?? "")")
            }
        } else{
            self.UserNameLbl.text = ""
            self.profileImage.image = #imageLiteral(resourceName: "UserImage")
        }
    }
    @objc func dismissVC(){
        dismiss(animated: true) {
            self.delegate?.shouldNavBack()
        }
    }
    @objc func RefreshAction(){
        DispatchQueue.main.async {
            self.UserNameLbl.text = UserDefaults.standard.string(forKey: "userName")
            let image = UserDefaults.standard.string(forKey: "userImage")
            if image != ""{
                self.profileImage.sd_setImage(with: URL(string: APIEndPoints.BASE_IMAGE_URL + (image ?? "")), placeholderImage: #imageLiteral(resourceName: "UserImage"), options: [], context: nil)
            } else{
                self.profileImage.image = #imageLiteral(resourceName: "UserImage")
            }
            print("ProfileImage --- \(APIEndPoints.BaseURL)\(image ?? "")")
        }
    }
    
    @IBAction func menuAction(){
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: {
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.didProfileDisappeared.rawValue), object: true)
            }
        })
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 100 {
            if buttonIndex == 1 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LogoutEvent"), object: nil)
                UserDefaults.standard.setValue(false, forKey: "isLoggedin")
                UserDefaults.standard.setValue("0", forKey: "userID")
                UserDefaults.standard.removeObject(forKey: "dob")
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: NSArray()),    forKey: "userDetails")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    if let aVC = myVC {
                        presentingViewController?.navigationController?.pushViewController(aVC, animated: false)
                    }
                Constants.appDelegate?.moveToLogin()
            }
        }else if alertView.tag == 101 {
            if buttonIndex == 0 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LogoutEvent"), object: nil)
                UserDefaults.standard.setValue(false, forKey: "isLoggedin")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                if let aVC = myVC {
                    presentingViewController?.navigationController?.pushViewController(aVC, animated: false)
                }
            }
            
        } else if alertView.tag == 50{
            print("EditProfileAlertButtonIndex---\(buttonIndex)")
            if buttonIndex == 1{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LogoutEvent"), object: nil)
                UserDefaults.standard.setValue(false, forKey: "isLoggedin")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                if let aVC = myVC {
                    presentingViewController?.navigationController?.pushViewController(aVC, animated: false)
                }
            } else{
                alertView.dismiss(withClickedButtonIndex: 0, animated: true)
            }
        } else if alertView.tag == 51{
            if buttonIndex == 1{
                print("Delete Account")
                self.DeleteUser()
            } else{
                alertView.dismiss(withClickedButtonIndex: 0, animated: true)
            }
        }
    }
}
extension MenuAlertVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuDataSource1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTVC") as? MenuTVC
        cell?.selectionStyle = .none
        if menuDataSource1[indexPath.row].title == "My Profile"{
            cell?.lineView.isHidden = true
        } else{
            cell?.lineView.isHidden = false
        }
        if(isLoggedin == true)
        {
            cell?.menuTitleLbl.text = menuDataSource1[indexPath.row].title
            cell?.menuImage.image = menuDataSource1[indexPath.row].img
        } else{
            cell?.menuTitleLbl.text = menuDataSource2[indexPath.row].title
            cell?.menuImage.image = menuDataSource2[indexPath.row].img
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt0000 ----- ")
        if indexPath.row == 0{
            if(isLoggedin == true)
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                presentingViewController?.navigationController?.pushViewController(myVC, animated: false)
            } else {
                let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
                alert.tag = 50
                alert.show()
            }
        } else if indexPath.row == 1{
            print("Tickets----")
            if(isLoggedin == true)
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "MenuTicketsVC") as! MenuTicketsVC
                presentingViewController?.navigationController?.pushViewController(myVC, animated: false)
            } else {
                let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
                alert.tag = 50
                alert.show()
            }
        } else if indexPath.row == 2{
            if(isLoggedin == true)
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "MyCarsVC") as! MyCarsVC
                presentingViewController?.navigationController?.pushViewController(myVC, animated: false)
            } else {
                let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
                alert.tag = 50
                alert.show()
            }
        } else if indexPath.row == 3{
            if(isLoggedin == true)
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "MyOrdersVC") as! MyOrdersVC
                presentingViewController?.navigationController?.pushViewController(myVC, animated: false)
            } else {
                let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
                alert.tag = 50
                alert.show()
            }
        } else if indexPath.row == 4{
            if(isLoggedin == true)
            {
                let storyboard = UIStoryboard(name: "Mechbrain", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "MechbrainMyOrdersVC") as! MechbrainMyOrdersVC
                presentingViewController?.navigationController?.pushViewController(myVC, animated: false)
            } else {
                let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
                alert.tag = 50
                alert.show()
            }
        } else if indexPath.row == 5{
            if(isLoggedin == true)
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                presentingViewController?.navigationController?.pushViewController(myVC, animated: false)
            } else {
                let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
                alert.tag = 50
                alert.show()
            }
        } else if indexPath.row == 6{
            if(isLoggedin == true)
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
                presentingViewController?.navigationController?.pushViewController(myVC, animated: false)
            } else {
                let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
                alert.tag = 50
                alert.show()
            }
        } else if indexPath.row == 7{
            if(isLoggedin == true)
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
                presentingViewController?.navigationController?.pushViewController(myVC, animated: false)
            } else {
                let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
                alert.tag = 50
                alert.show()
            }
        } else if indexPath.row == 8{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            presentingViewController?.navigationController?.pushViewController(myVC, animated: false)
        } else if indexPath.row == 9{
            if(isLoggedin == true)
            {
                let appleURL = "https://www.mechuni.com/PRIVACY%20POLICY%20MECHUNI.pdf"
                let sfVc = SFSafariViewController(url: URL(string: appleURL)!)
                sfVc.delegate = self
                presentingViewController?.navigationController?.pushViewController(sfVc, animated: false)
            } else {
                let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
                alert.tag = 50
                alert.show()
            }
        } else if indexPath.row == 10{
            if(isLoggedin == true)
            {
                let alert = UIAlertView(title: "Are you sure you want to delete account?", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "CONFIRM")
                alert.tag = 51
                alert.show()
            } else {
                let alert = UIAlertView(title: "Login is required to access this feature", message: "", delegate: self, cancelButtonTitle: "CANCEL",  otherButtonTitles: "GO TO LOGIN")
                alert.tag = 50
                alert.show()
            }
        } else if indexPath.row == 11{
            print("Logout----")
            if(isLoggedin == true)
            {
                let alert = UIAlertView(title: "Are you sure! you want to Logout?", message: "", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
                alert.tag = 100
                alert.show()
            } else {
//              let domain = Bundle.main.bundleIdentifier!
//              UserDefaults.standard.removePersistentDomain(forName: domain)
//              UserDefaults.standard.synchronize()
//              print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LogoutEvent"), object: nil)
                UserDefaults.standard.setValue(false, forKey: "isLoggedin")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                if let aVC = myVC {
                Constants.kNavigationController?.pushViewController(aVC, animated: true)
                }
                Constants.appDelegate?.moveToLogin()
            }
        }
    }
}
extension MenuAlertVC: SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariViewControllerDidFinish")
        presentingViewController?.navigationController?.popViewController(animated: true)
    }
}
extension MenuAlertVC{
    func DeleteUser(){
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        let params:[String:Any] = ["customer_id":Int(userId) ?? 0,"isDisabled":true]
        print("DeleteUserParams: \(params)")
        if Connectivity.isConnectedToInternet
        {
            SKActivityIndicator.show("Loading...")
            Alamofire.request(APIEndPoints.deleteAccount,method: .post,parameters: params,encoding: JSONEncoding.default,headers: nil).responseJSON { apiResponse in
                print("DeleteAPIResponse --- \(apiResponse)")
                switch apiResponse.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = apiResponse.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let message = apiDict["message"] as? String ?? ""
                        if status == "success" {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LogoutEvent"), object: nil)
                            UserDefaults.standard.setValue(false, forKey: "isLoggedin")
                            UserDefaults.standard.setValue("0", forKey: "userID")
                            UserDefaults.standard.removeObject(forKey: "dob")
                            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: NSArray()),    forKey: "userDetails")
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                            if let aVC = myVC {
                                self.presentingViewController?.navigationController?.pushViewController(aVC, animated: false)
                            }
                            Constants.appDelegate?.moveToLogin()
                            self.view.makeToast(message)
                        } else{
                            self.view.makeToast(message)
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    print("failure")
                }
            }
        }
    }
}
