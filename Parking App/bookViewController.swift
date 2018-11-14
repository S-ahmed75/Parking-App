//
//  ModalViewController.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 17/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    
    
    
    @IBAction func paymentButtonTapped(sender: AnyObject) {
      
        
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
      
        self.dismiss(animated: true, completion: nil)
    }
}
