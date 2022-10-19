//
//  LeftViewController.swift
//  LGSideMenuControllerDemo
//


class LeftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {

    
    @IBOutlet weak var mLeftTableView: UITableView!
    //Exit View
    
    @IBOutlet var mExitView: UIView!
    @IBOutlet weak var mUserImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var mEditBtn: UIButton!
    private let titlesArray1 = [ "Profile",
                                 "Home",
                                 "Tickets",
                                 "My Cars",
                                 "Settings",
                                 "Contact Us",
                                 "About Us",
                                 "Terms & Conditions",
                                 "Privacy Policy",
                                 "Login"]
    
    private let titlesArray = [ "Profile",
                                "Home",
                                "Tickets",
                                "My Cars",
                                "Settings",
                                "Contact Us",
                                "About Us",
                                "Terms & Conditions",
                                "Privacy Policy",
                                "Logout"]
    
    private let titlesArrayIcon =  [ "Profile",
                                     "home_menu",
                                     "tickets",
                                     "my cars",
                                     "Settings",
                                     "contact us",
                                     "About Us",
                                     "term",
                                      "privacy",
                                      
                                     "logout"]
    //
    
    var username:String? = nil
    
    
    //UserProfile Property
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuController?.isLeftViewDisabled = true
        mLeftTableView.contentInset = UIEdgeInsets(top: 44.0, left: 0.0, bottom: 44.0, right: 0.0)
        mLeftTableView.register(UINib(nibName: "LeftMainCell", bundle: nil), forCellReuseIdentifier: "LeftMainCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "load"), object: nil)
        
    }
    
    
    @objc func reloadData(){
        
        self.mLeftTableView.reloadData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
   
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeftMainCell", for: indexPath) as! LeftMainCell
           // cell.mBtn.tag = indexPath.row
           // cell.mBtn.addTarget(self, action:#selector(goToProfile(_:)), for: UIControlEvents.touchUpInside)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            let isLoggedin =  UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
            if(isLoggedin == true)
            { 
                
                var currentDefaults = UserDefaults.standard
                var savedArray = currentDefaults.object(forKey: "userDetails") as? Data
                if savedArray != nil {
                    var oldArray: [Any]? = nil
                    DispatchQueue.main.async {
                        if let anArray = savedArray {
                            oldArray = NSKeyedUnarchiver.unarchiveObject(with: anArray) as? [Any]
                            let dict = oldArray?.first as? NSDictionary
                            
                            cell.mCellLabel.text = dict?["firstname"] as? String ?? ""
//                            if let actionString = dict?["image"] as? NSString {
//                                // action is not nil, is a String type, and is now stored in actionString
//                                let url = String(format: "%@%@",Constants.IMGBASEURL ,actionString)
//                                // self.imagePath = String(format: "%@",(dict!["image"] as? String)!)
//                                let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//
//                                cell.mCellImage.sd_setImage(with: URL(string: urlString!), placeholderImage: UIImage(named: "userImage"))
//
//                                cell.selectionStyle = UITableViewCell.SelectionStyle.none
//                            } else {
//                                // action was either nil, or not a String type
//                            }
                            cell.mCellImage.layer.cornerRadius = cell.mCellImage.frame.size.height/2
                            cell.mCellImage.layer.masksToBounds = true
                            
                        }
                    }
                    
                }
            }
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeftViewCell", for: indexPath) as! LeftViewCell
            let isLoggedin =  UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
            if(isLoggedin == true)
            {
                cell.mLabel.text = titlesArray[indexPath.row]
                cell.mImageView.image = UIImage(named: titlesArrayIcon[indexPath.row] as? String ?? "")
            }
            else{
                cell.mLabel.text = titlesArray1[indexPath.row]
                cell.mImageView.image = UIImage(named: titlesArrayIcon[indexPath.row] as? String ?? "")
            }
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        
    }
    
//    @objc func goToProfile(_ sender: UIButton)
//    {
//
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        if indexPath.row == 0{
            return 206
        }else{
            return 44
        }
        //Choose your custom row height
        
        
    }
    
    // MARK: - UITableViewDelegate
    
    //    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return (indexPath.row == 1 || indexPath.row == 3) ? 22.0 : 44.0
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        
        //let mainViewController = sideMenuController!
        
        Constants.kMainViewController?.hideLeftView()
        if indexPath.row == 0
        {
            UserDefaults.standard.setValue("profile", forKey: "SelectedTab")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if #available(iOS 13.0, *) {
                let myVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
                if let aVC = myVC {
                    Constants.kNavigationController?.pushViewController(aVC, animated: true)
                }
            } else {
                // Fallback on earlier versions
            }
            
        }
            
        else if indexPath.row == 1 {
            
//            UserDefaults.standard.setValue("home", forKey: "SelectedTab")
//            if !(Constants.appDelegate?.navigationController.visibleViewController is HomeVC) {
//                Constants.appDelegate?.homeButtonClicked()
//            }
            UserDefaults.standard.setValue("home", forKey: "SelectedTab")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
            if let aVC = myVC {
                Constants.kNavigationController?.pushViewController(aVC, animated: true)
        }
        }
        else if indexPath.row == 2 {
            
//            UserDefaults.standard.setValue("tickets", forKey: "SelectedTab")
//            Constants.appDelegate?.ticketsButtonClicked()
                UserDefaults.standard.setValue("tickets", forKey: "SelectedTab")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "TicketsVC") as? TicketsVC
                if let aVC = myVC {
                    Constants.kNavigationController?.pushViewController(aVC, animated: true)
            }
        }
        else if indexPath.row == 3 {
            
//            UserDefaults.standard.setValue("myCars", forKey: "SelectedTab")
//            Constants.appDelegate?.myCarsButtonClicked()
                    UserDefaults.standard.setValue("myCars", forKey: "SelectedTab")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let myVC = storyboard.instantiateViewController(withIdentifier: "MyCarsVC") as? MyCarsVC
                    if let aVC = myVC {
                        Constants.kNavigationController?.pushViewController(aVC, animated: true)
            }
        }
        else if indexPath.row == 4 {
            
//            UserDefaults.standard.setValue("settings", forKey: "SelectedTab")
//            Constants.appDelegate?.settingsButtonClicked()
                        UserDefaults.standard.setValue("settings", forKey: "SelectedTab")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let myVC = storyboard.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC
                        if let aVC = myVC {
                            Constants.kNavigationController?.pushViewController(aVC, animated: true)
            }
        }
        else if indexPath.row == 5 {
            
            //            UserDefaults.standard.setValue("ContactUs", forKey: "SelectedTab")
            //            Constants.appDelegate?.ContactUsButtonClicked()
            UserDefaults.standard.setValue("ContactUs", forKey: "SelectedTab")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "HelpLineVC") as? HelpLineVC
            if let aVC = myVC {
                aVC.isFromMenu = true
                Constants.kNavigationController?.pushViewController(aVC, animated: true)
            }
        }
        else if indexPath.row == 6 {
          
//            UserDefaults.standard.setValue("AboutUs", forKey: "SelectedTab")
//            Constants.appDelegate?.AboutUsButtonClicked()
                                UserDefaults.standard.setValue("AboutUs", forKey: "SelectedTab")
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let myVC = storyboard.instantiateViewController(withIdentifier: "AboutUsVC") as? AboutUsVC
                                if let aVC = myVC {
                                    Constants.kNavigationController?.pushViewController(aVC, animated: true)
                                
                                }
        }
        else if indexPath.row == 7 {
            
           
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "TermsVC") as? TermsVC
            if let aVC = myVC {
                Constants.kNavigationController?.pushViewController(aVC, animated: true)
                
            }
            
        }  else if indexPath.row == 8 {
            
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "PrivacyVC") as? PrivacyVC
            if let aVC = myVC {
                Constants.kNavigationController?.pushViewController(aVC, animated: true)
                
            }
        }
         
        else {
            let isLoggedin =  UserDefaults.standard.value(forKey: "isLoggedin") as? Bool ?? false
            if(isLoggedin == true)
            {
                var alert = UIAlertView(title: "Mechuni", message: "Are you sure to want to logout?", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
                alert.tag = 100
                alert.show()
            } else {
                UserDefaults.standard.setValue(false, forKey: "isLoggedin")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    if let aVC = myVC {
                        Constants.kNavigationController?.pushViewController(aVC, animated: true)
                    }
               // Constants.appDelegate?.moveToLogin()
            }
        }
       //self.mLeftTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        
        if alertView.tag == 100 {
            if buttonIndex == 1 {
                UserDefaults.standard.setValue(false, forKey: "isLoggedin")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                if let aVC = myVC {
                    Constants.kNavigationController?.pushViewController(aVC, animated: true)
                }
            }
        }else if alertView.tag == 101 {
            
            if buttonIndex == 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                if let aVC = myVC {
                    Constants.kNavigationController?.pushViewController(aVC, animated: true)
                }
            }
            
        }
    }
    
}






