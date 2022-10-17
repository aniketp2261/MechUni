//
//  RightViewCell.swift
//  LGSideMenuControllerDemo
//

class RightViewCell: UITableViewCell {

  
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //titleLabel.alpha = highlighted ? 0.5 : 1.0
    }
    
}
