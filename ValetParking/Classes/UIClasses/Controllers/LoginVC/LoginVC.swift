//
//  LoginVC.swift
//  ValetParking
//
//  Created by Khushal on 15/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SKActivityIndicatorView
import SKCountryPicker
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices
import CoreLocation
import SafariServices

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mEmailView: UIView!
    @IBOutlet weak var mPasswordView: UIView!
    @IBOutlet weak var mEmailTF: UITextField!
    @IBOutlet weak var mPasswordTF: UITextField!
    @IBOutlet weak var btnEye: UIButton!
    @IBOutlet weak var countryBtn: UIButton!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var mLoginBtn: UIButton!
    @IBOutlet weak var fbLogin: UIImageView!
    @IBOutlet weak var googleLogin: UIImageView!
    @IBOutlet weak var appleLogin: UIImageView!
    @IBOutlet weak var termsCondLbl: UILabel!
    @IBOutlet weak var PrivacyPolicyLbl: UILabel!
    @IBOutlet weak var CheckBoxImg: UIImageView!
    
    var iconClick = true
    var locationManager = CLLocationManager()
    var privacyCheck = true
    var checked = 0

    let signInConfig = GIDConfiguration.init(clientID: "477382176607-9lo3m69qem9aq1mt1eaffcuaqdsn7f14.apps.googleusercontent.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isLoggedIn() {
            print("Already FacebookLogin")
            // Show the ViewController with the logged in user
        }else{
            print("Facebook Logout")
            // Show the Home ViewController
        }
        btnEye.setImage(UIImage(named: "eyeD24px"), for: .normal)
        self.mEmailView.layer.cornerRadius = 20
        self.mPasswordView.layer.cornerRadius = 20
        self.mLoginBtn.layer.cornerRadius = 20
        self.mLoginBtn.layer.borderWidth = 1
        self.mLoginBtn.layer.borderColor = #colorLiteral(red: 1, green: 0.9215686275, blue: 0.231372549, alpha: 1)
        fbLogin.layer.cornerRadius = fbLogin.frame.width / 2
        googleLogin.layer.cornerRadius = googleLogin.frame.width / 2
        
        let googleTap = UITapGestureRecognizer(target: self, action: #selector(GoogleSignIn(_:)))
        googleLogin.isUserInteractionEnabled = true
        googleLogin.addGestureRecognizer(googleTap)
        
        let fbTap = UITapGestureRecognizer(target: self, action: #selector(FacebookSignIn(_:)))
        fbLogin.isUserInteractionEnabled = true
        fbLogin.addGestureRecognizer(fbTap)
        
        let appleTap = UITapGestureRecognizer(target: self, action: #selector(AppleLoginAction(_:)))
        appleLogin.isUserInteractionEnabled = true
        appleLogin.addGestureRecognizer(appleTap)
//      let country = CountryManager.shared.currentCountry
//      countryBtn.setTitle(country?.dialingCode, for: .normal)
//      imgFlag.image = country?.flag
//      countryBtn.setImage(imgFlag.image, for: .normal)
//      imgFlag.image = nil
        
//      placeholder color
        mEmailTF.placeholder = "Enter mobile number"
        mPasswordTF.placeholder = "Enter password"
        mEmailTF.keyboardType = .numberPad
        CheckBoxImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(funcCheckbox)))
        PrivacyPolicyLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PrivacyPolicy)))
        termsCondLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TermsAndConditions)))
        APICALLS()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func APICALLS(){
        checkLocationPermission()
        startLocation()
    }
    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .denied {
                let alert = UIAlertController(title: "Location Access", message: "App Location Permission Denied.To re-enable, please go to Settings and turn on Location Service for this app.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Allow Location",style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
                            self.startLocation()
                            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                    }))
                    self.present(alert, animated: true, completion: nil)
            } else {
                print("Location Services Enabled")
            }
        }
    }
    func startLocation()  {
         locationManager = CLLocationManager()
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestWhenInUseAuthorization()
         locationManager.showsBackgroundLocationIndicator = false
         locationManager.allowsBackgroundLocationUpdates = true
         locationManager.delegate = self
         locationManager.startUpdatingLocation()
    }
    @objc func funcCheckbox() {
        if privacyCheck{
            CheckBoxImg.image = UIImage(named: "icChecked")
            checked = 1
            privacyCheck = false
        } else{
            CheckBoxImg.image = UIImage(named: "square")
            checked = 0
            privacyCheck = true
        }
   }
    @objc func TermsAndConditions(){
        let appleURL = "https://www.mechuni.com/MECHUNI%20TERMS%20AND%20CONDITIONS.pdf"
        let sfVc = SFSafariViewController(url: URL(string: appleURL)!)
        sfVc.delegate = self
        self.navigationController?.pushViewController(sfVc, animated: false)
    }
    @objc func PrivacyPolicy(){
        let appleURL = "https://mechuni.com/PRIVACY%20POLICY%20MECHUNI.pdf"
        let sfVc = SFSafariViewController(url: URL(string: appleURL)!)
        sfVc.delegate = self
        self.navigationController?.pushViewController(sfVc, animated: false)
    }
    // Button Actions
    @IBAction func mSkipActn(_ sender: Any) {
        UserDefaults.standard.setValue(false, forKey: "isLoggedin")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func hideShowPassword(_ sender: Any) {
        if(iconClick == true) {
            mPasswordTF.isSecureTextEntry = false
            btnEye.setImage(UIImage(named: "eye24px"), for: .normal)
        } else {
            btnEye.setImage(UIImage(named: "eyeD24px"), for: .normal)
            mPasswordTF.isSecureTextEntry = true
        }

       iconClick = !iconClick
    }
    @IBAction func loginActn(_ sender: Any) {
        
        if(mEmailTF.text == "")
        {
            self.view.makeToast("Please enter your mobile number!")
            return
        } else if(mEmailTF.text!.count < 10 || mEmailTF.text!.count > 10)
        {
            self.view.makeToast("Please enter proper mobile number!")
            return
        } else if(mPasswordTF.text == "")
        {
            self.view.makeToast("Please enter your password!")
            return
        } else if checked == 0{
            self.view.makeToast("Please Accept terms & conditions and privacy policy")
            return
        }

        let country = CountryManager.shared.currentCountry
       // var countryCode = country?.dialingCode ?? "91"
        let countryCode = "91"
        var user = "\(countryCode)\(mEmailTF.text!)"
        if mEmailTF.text!.isNumeric {
            user = user.replacingOccurrences(of: "+", with: "")
        }
        print("user00000 ------ \(user)")
        let parameters =
        [
            "mobile_email": String(format: "%@", user),
            "password": String(format: "%@", self.mPasswordTF.text!)
        ]
        print("login param--- \(parameters)")
        if Connectivity.isConnectedToInternet
        {
            print("Yes! internet is available.")
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)\(APIEndPoints.login)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
                .responseJSON { response in
                    debugPrint("loginResponse000---- \(response)")
                    switch response.result {
                    case .success:
                        SKActivityIndicator.dismiss()
                        print("Response: \(response)")
                        if let json = response.result.value {
                            if let JSON = json as? NSDictionary {
                                let message = JSON["message"] as? String
                                print(JSON["status"] as? String ?? "")
                                let status = JSON["status"] as? String
                                if status == "success" {
                                    SKActivityIndicator.dismiss()
                                    UserDefaults.standard.setValue(true, forKey: "isLoggedin")
                                    let contentArr = JSON["result"] as? NSArray
                                    if contentArr?.count != 0
                                    {
                                        let dict = contentArr?.firstObject as! NSDictionary
                                        UserDefaults.standard.setValue(dict["_id"] as Any, forKey: "userID")
                                        UserDefaults.standard.setValue(dict["password"] as Any, forKey: "userPassword")
                                        UserDefaults.standard.setValue(dict["image"] as? String ?? "", forKey: "userImage")
                                        let firstname = dict["firstname"] as! String
                                        UserDefaults.standard.setValue(firstname, forKey: "firstname")
                                        let lastName = dict["lastname"] as! String
                                        UserDefaults.standard.setValue(lastName, forKey: "lastname")
                                        UserDefaults.standard.setValue(dict["email"] as? String ?? "", forKey: "email")
                                        UserDefaults.standard.setValue(dict["mobilenumber"] as! String, forKey: "mobileNo")
                                        UserDefaults.standard.setValue(dict["dob"] as? String ?? "", forKey: "dob")
                                        UserDefaults.standard.setValue("\(firstname) \(lastName)", forKey: "userName")
                                        let name =  UserDefaults.standard.string(forKey: "userName")
                                        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: contentArr), forKey: "userDetails")
                                        UserDefaults.standard.synchronize()
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                        vc.isLoggedin = true
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }else{
                                    let message = JSON["message"] as? String
                                    self.view.makeToast(message);
                                }
                            } else {
                                self.view.makeToast("Json Error...!!!")
                            }
                        }
                        break
                    case .failure(let error):
                        SKActivityIndicator.dismiss()
                        print(error)
                        
                        break
                    }
            }
            
        } else{
            let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NetworkPopUpVC") as! NetworkPopUpVC
            self.addChild(popvc)
            popvc.view.frame = self.view.frame
            self.view.addSubview(popvc.view)
            popvc.didMove(toParent: self)
        }
    }
    func socialLogin(appleId: String,email:String,firstname:String,lastname:String){
        let parameters: Parameters =
        [
            "apple_user_id": appleId,
            "email": email,
            "firstname": firstname,
            "lastname": lastname
        ]
        if Connectivity.isConnectedToInternet{
            SKActivityIndicator.show("Loading...")
            Alamofire.request("\(APIEndPoints.BaseURL)\(APIEndPoints.socialLogin)",method: .post,parameters: parameters,encoding: JSONEncoding.default,headers: nil).responseJSON { response in
                debugPrint("SocialloginResponse---- \(response)")
                switch response.result{
                case .success(_):
                    SKActivityIndicator.dismiss()
                    if let apiDict = response.value as? [String:Any]{
                        let status = apiDict["status"] as? String ?? ""
                        let message = apiDict["message"] as? String ?? ""
                        if status == "success" {
                            self.view.makeToast(message)
                            let results = apiDict["result"] as? [[String:Any]] ?? []
                            print("Socialloginresults--- \(results)")
                            for result in results{
                                UserDefaults.standard.setValue(true, forKey: "isLoggedin")
                                let verified = result["verified"] as? String ?? ""
                                let id = String(result["_id"] as? Int ?? 0)
                                let email = result["email"] as? String ?? ""
                                let firstname = result["firstname"] as? String ?? ""
                                let lastname = result["lastname"] as? String ?? ""
                                let mobilenumber = result["mobilenumber"] as? String ?? ""
                                let password = result["password"] as? String ?? ""
                                let otp = result["otp"] as? String ?? ""
                                let tokenId = result["token_id"] as? String ?? ""
                                let dob = result["dob"] as? String ?? ""
                                let image = result["image"] as? String ?? ""
                                
                                UserDefaults.standard.setValue(id, forKey: "userID")
                                UserDefaults.standard.setValue(password, forKey: "userPassword")
                                UserDefaults.standard.setValue(image, forKey: "userImage")
                                UserDefaults.standard.setValue(firstname, forKey: "firstname")
                                UserDefaults.standard.setValue(lastname, forKey: "lastname")
                                UserDefaults.standard.setValue(email, forKey: "email")
                                UserDefaults.standard.setValue(mobilenumber, forKey: "mobileNo")
                                UserDefaults.standard.setValue(dob, forKey: "dob")
                                UserDefaults.standard.setValue("\(firstname) \(lastname)", forKey: "userName")
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        } else {
                            self.view.makeToast(message)
                        }
                    }
                case .failure(_):
                    SKActivityIndicator.dismiss()
                    self.view.makeToast("Social Login Error... ")
                }
            }
        }else{
            self.view.makeToast("NO INTERNET!!!")
        }
    }
    
    @IBAction func forgotPasswordActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func mRegisterActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func valetProviderActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ValetProvider") as! ValetProvider
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func mHelpLineActn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HelpLineVC") as! HelpLineVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["+", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}

extension LoginVC{
    func isLoggedIn() -> Bool {
        let accessToken = AccessToken.current
        let isLoggedIn = accessToken != nil && !(accessToken?.isExpired ?? false)
        return isLoggedIn
    }
    @objc func GoogleSignIn(_ sender: Any){
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
            // If sign in succeeded, display the app's main content View.
            let email = user.profile?.email ?? ""
            let firstName = user.profile?.givenName ?? ""
            let lastName = user.profile?.familyName ?? ""
            print("SocialLoginEmail---\(email)")
            print("SocialLoginFirstname---\(firstName)")
            print("SocialLoginLastname---\(lastName)")
            self.socialLogin(appleId: "", email: email, firstname: firstName, lastname: lastName)
          }
    }
    @objc func FacebookSignIn(_ sender: Any){
        let loginManager = LoginManager()
               loginManager.logIn(permissions: ["public_profile", "email"], from: self, handler: { result, error in
                   if error != nil {
                       print("ERROR: Trying to get login results")
                   } else if result?.isCancelled != nil {
                       print("The token is \(result?.token?.tokenString ?? "")")
                       if result?.token?.tokenString != nil {
                           print("Logged in")
                           self.getUserProfile(token: result?.token, userId: result?.token?.userID)
                       } else {
                           print("Cancelled")
                       }
                }
        })
    }
    @objc func AppleLoginAction(_ sender: Any){
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
       
    }
    func getUserProfile(token: AccessToken?, userId: String?) {
            let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, middle_name, last_name, name, picture, email"])
            graphRequest.start { _, result, error in
                if error == nil {
                    let data: [String: AnyObject] = result as! [String: AnyObject]
                    let facebookEmail = data["email"] as? String ?? ""
                    let facebookFirstName = data["first_name"] as? String ?? ""
                    let facebookLastName = data["last_name"] as? String ?? ""
                    self.socialLogin(appleId: "",email: facebookEmail, firstname: facebookFirstName, lastname: facebookLastName)
                    
                    // Facebook Id
                    if let facebookId = data["id"] as? String {
                        print("Facebook Id: \(facebookId)")
                    } else {
                        print("Facebook Id: Not exists")
                    }
                    
                    // Facebook First Name
                    if let facebookFirstName = data["first_name"] as? String {
                        print("Facebook First Name: \(facebookFirstName)")
                    } else {
                        print("Facebook First Name: Not exists")
                    }
                    
                    // Facebook Middle Name
                    if let facebookMiddleName = data["middle_name"] as? String {
                        print("Facebook Middle Name: \(facebookMiddleName)")
                    } else {
                        print("Facebook Middle Name: Not exists")
                    }
                    
                    // Facebook Last Name
                    if let facebookLastName = data["last_name"] as? String {
                        print("Facebook Last Name: \(facebookLastName)")
                    } else {
                        print("Facebook Last Name: Not exists")
                    }
                    
                    // Facebook Name
                    if let facebookName = data["name"] as? String {
                        print("Facebook Name: \(facebookName)")
                    } else {
                        print("Facebook Name: Not exists")
                    }
                    
                    // Facebook Profile Pic URL
                    let facebookProfilePicURL = "https://graph.facebook.com/\(userId ?? "")/picture?type=large"
                    print("Facebook Profile Pic URL: \(facebookProfilePicURL)")
                    
                    // Facebook Email
                    if let facebookEmail = data["email"] as? String {
                        print("Facebook Email: \(facebookEmail)")
                    } else {
                        print("Facebook Email: Not exists")
                    }
                    
                    print("Facebook Access Token: \(token?.tokenString ?? "")")
                } else {
                    print("Error: Trying to get user's info")
                }
            }
        }
}
extension LoginVC : ASAuthorizationControllerDelegate{
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                UserDefaults.standard.setValue(appleIDCredential.user, forKey: "AppleUserId")
                // Create an account in your system.
                let userIdentifier = appleIDCredential.user
                let firstname = appleIDCredential.fullName?.givenName ?? ""
                let lastname = appleIDCredential.fullName?.familyName ?? ""
                let email = appleIDCredential.email ?? ""
                print("AppleLogin UserID--- \(userIdentifier)")
                print("AppleLogin FullName--- \(firstname) \(lastname)")
                print("AppleLogin Email--- \(email)")
                self.socialLogin(appleId: userIdentifier, email: email, firstname: firstname, lastname: lastname)
                AlertFunctions.showAlert(message: "", title: "\(userIdentifier)\n\(firstname) \(lastname)\n\(email)")
            
            case let passwordCredential as ASPasswordCredential:
            
                // Sign in using an existing iCloud Keychain credential.
                let username = passwordCredential.user
                let password = passwordCredential.password
                
                // For the purpose of this demo app, show the password credential as an alert.
                DispatchQueue.main.async {
                    AlertFunctions.showAlert(message: "", title: "\(username)\(password)")
                }
            default:
                break
            }
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
    
}
extension LoginVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        UserDefaults.standard.setValue(String(locations[0].coordinate.latitude) , forKey: "CurrentLat")
        UserDefaults.standard.setValue(String(locations[0].coordinate.longitude) , forKey: "CurrentLong")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError0000 ------ \(error.localizedDescription)")
    }
}
extension LoginVC: SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariViewControllerDidFinish")
        self.navigationController?.popViewController(animated: true)
    }
}
