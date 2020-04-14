//
//  TableViewCell.swift
//  SmartBox
//
//  Created by Vlada on 21/01/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import UIKit

class BoxListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func availabilitySet(_ box: Box) {
        if box.current_owner != nil {
            availabilityLabel.text = "Occupied"
            availabilityLabel.textColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        } else {
            availabilityLabel.text = "Available"
            availabilityLabel.textColor = #colorLiteral(red: 0.1568627451, green: 0.8039215686, blue: 0.2549019608, alpha: 1)
        }
    }
    
    func myBoxSet(_ box: Box) {
        guard let userBoxes = UserController.shared.user?.Boxes else { return }
        for myBox in userBoxes {
            if box.id == myBox.id {
                availabilityLabel.text = "My Box"
                availabilityLabel.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            }
        }
    }
}
