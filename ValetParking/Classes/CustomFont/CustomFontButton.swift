//
//  CustomFontButton.swift
//  Dhukan
//
//  Created by Suganya on 7/18/18.
//   Copyright © 2018 Suganya. All rights reserved.
//

import UIKit

class CustomFontButton: UIButton {

    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
    }
    override init(frame:CGRect) {
        super.init(frame:frame)
    }
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.setFont()
    }
    
    func setFont()
    {
        if Int((titleLabel?.font.fontName as NSString?)?.range(of: "bold", options: .caseInsensitive).location ?? 0) != NSNotFound
        {
            titleLabel?.font = UIFont(name: Constants.FONTNAME_BOLD as String, size: (titleLabel?.font.pointSize)!)!
        }
        else
        {
            titleLabel?.font = UIFont(name: Constants.FONTNAME as String, size: (titleLabel?.font.pointSize)!)!
        }
    }

}
