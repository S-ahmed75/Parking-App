
//
//  bookedListCellTableViewCell.swift
//  Parking App
//
//  Created by sunny on 24/11/2018.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit

class bookedListCellTableViewCell: UITableViewCell {

    @IBOutlet weak var bookingDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var cancelBookingOutlet: UIButton!
    @IBOutlet weak var tabView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     //   self.cancelBookingOutlet.isHidden = true
      self.tabView.layer.cornerRadius = 7
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func cancelBooking(_ sender: Any) {
        
        
    }
    
}
