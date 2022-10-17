//
//  ShadowView.swift
//  ValetParking
//
//  Created by admin on 03/03/22.
//  Copyright © 2022 fugenx. All rights reserved.
//

import Foundation
import UIKit

class ShadowView: UIView {
    var setupShadowDone: Bool = false
    var shadowCornerRadius:CGFloat = 15
    public func setupShadow() {
        if setupShadowDone { return }
        self.layer.cornerRadius = shadowCornerRadius
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,
                                             byRoundingCorners: .allCorners, cornerRadii: CGSize(width: shadowCornerRadius, height:shadowCornerRadius)).cgPath

        setupShadowDone = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShadow()
    }
}
extension UIImage {
    func withColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        // 1
        let drawRect = CGRect(x: 0,y: 0,width: size.width,height: size.height)
        // 2
        color.setFill()
        UIRectFill(drawRect)
        // 3
        draw(in: drawRect, blendMode: .destinationIn, alpha: 1)

        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
}
extension UIApplication {
    func openAppStore(for appID: String) {
        let appStoreURL = "https://itunes.apple.com/app/\(appID)"
        guard let url = URL(string: appStoreURL) else {
            return
        }

        DispatchQueue.main.async {
            if self.canOpenURL(url) {
                self.open(url)
            }
        }
    }
}
extension String {
  func convertToDate() -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      if let dt = dateFormatter.date(from: self) {
          dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
          let formatedStringDate = dateFormatter.string(from: dt)
              return formatedStringDate
      }
      return "01-01-70"
  }
}

class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "icChecked")! as UIImage
    let uncheckedImage = UIImage(named: "square")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
        
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
        
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
