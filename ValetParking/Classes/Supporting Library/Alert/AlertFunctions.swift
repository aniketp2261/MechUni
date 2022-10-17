
import UIKit

class AlertFunctions {
  
  /**
   Call this function to show alert with message and get callback
   */
  
  static func showAlert(message: String, title: String? = nil, image: UIImage? = nil, callback: (()->())?) {
    DispatchQueue.main.async {
      let customWindow = UIWindow(frame: UIScreen.main.bounds)
      customWindow.rootViewController = UIViewController()
     // customWindow.windowLevel = UIWindow.Level.alert + 1
//      customWindow.windowLevel = UIWindow.Level(UIWindow.Level.alert + 1)
      customWindow.makeKeyAndVisible()
        
      var messageTitle = "MechUni"
      if let unwrappedTitle = title {
        messageTitle = unwrappedTitle
      }
      
      let alertController = AlertController(title: messageTitle, message:
        message, preferredStyle: .alert)
      if let image = image {
        alertController.setTitleImage(image)
      } else {
        if let image = UIImage(named: "warning_icon") {
          alertController.setTitleImage(image)
        }
      }
      alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
        customWindow.resignKey()
        if let callback = callback {
          callback()
        }
      }))
      customWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
  }
  
  /**
   Call this function to show alert with message
   */
  
  static func showAlert(message: String, title: String? = nil, image: UIImage? = nil) {
    showAlert(message: message, title: title, image: image, callback: nil)
  }

//    static func showAlertForNagetiveAction(_ message: String, callback: (()->())?) {
//        DispatchQueue.main.async {
//            let customWindow = UIWindow(frame: UIScreen.main.bounds)
//            customWindow.rootViewController = UIViewController()
//            customWindow.windowLevel = UIWindowLevelAlert + 1
//            customWindow.makeKeyAndVisible()
//
//            let alertController = AlertController(title: AppName, message:
//                message, preferredStyle: .alert)
//            
//            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
//                customWindow.resignKey()
//                if let callback = callback {
//                    callback()
//                }
//            }))
//            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//            customWindow.rootViewController?.present(alertController, animated: true, completion: nil)
//        }
//    }
    
}
