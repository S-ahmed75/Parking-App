//
//  HelpViewController.swift
//  Parking App
//
//  Created by Danish Rehman on 15/11/2018.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    
    @IBOutlet weak var menu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        // Do any additional setup after loading the view.
    }
    
    func sideMenus(){
        if revealViewController() != nil {
            menu.target = revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }

    
    @IBAction func revelBtnPressed(_ sender: Any) {
    }
    
    
}
