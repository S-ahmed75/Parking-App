//
//  receivedBookingTableViewCell.swift
//  Parking App
//
//  Created by sunny on 27/11/2018.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit

class receivedBookingTableViewCell: UITableViewCell {

    @IBOutlet weak var dispDate: UILabel!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var cancelBookingOutline: UIButton!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var tabView: UIView!
     @IBOutlet weak var phone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cancelBookingOutline.isHidden = true
        
         self.tabView.layer.cornerRadius = 7
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var cancelButton: UIButton!
}
