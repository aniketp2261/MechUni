//
//  CustomFontTextField.swift
//  Dhukan
//
//  Created by Suganya on 7/18/18.
//   Copyright © 2018 Suganya. All rights reserved.
//

import UIKit

class CustomFontTextField: UITextField {

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
        if Int((font?.fontName as NSString?)?.range(of: "bold", options: .caseInsensitive).location ?? 0) != NSNotFound
        {
            font = UIFont(name: Constants.FONTNAME_BOLD as String, size: (font?.pointSize)!)
        }
        else
        {
            font = UIFont(name: Constants.FONTNAME as String, size: (font?.pointSize)!)
        }
    }

}
