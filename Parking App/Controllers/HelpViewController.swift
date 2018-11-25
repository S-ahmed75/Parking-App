//
//  HelpViewController.swift
//  Parking App
//
//  Created by Danish Rehman on 15/11/2018.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var helpTableView: UITableView!
    
    @IBOutlet weak var Buttons: UIButton!
    @IBOutlet weak var Buttons2: UIButton!
     @IBOutlet weak var Buttons3: UIButton!
     @IBOutlet weak var Buttons4: UIButton!
    
    @IBOutlet weak var menu: UIBarButtonItem!
    var image:UIImage?
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        self.Buttons.layer.cornerRadius = 8
                self.Buttons2.layer.cornerRadius = 8
                self.Buttons3.layer.cornerRadius = 8
                self.Buttons4.layer.cornerRadius = 8
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
    @IBAction func buuton1(_ sender: Any) {
        self.text = "You find your desired place by searching in search bar."
       
        self.image = UIImage(named: "searc")
            self.performSegue(withIdentifier: "answer", sender: self)
        
    }
    @IBAction func buuton2(_ sender: Any) {
         self.text = "You can get back your location by tapping on this."
    self.image = UIImage(named: "location")
      print("ccc")
        self.performSegue(withIdentifier: "answer", sender: self)
    }
    @IBAction func buuton3(_ sender: Any) {
      self.text = "find your desired place tap on p to see detail and confirm parking."
        self.image = UIImage(named: "parking-sign")
    print("vvvvvv")
        self.performSegue(withIdentifier: "answer", sender: self)
    }
    @IBAction func buuton4(_ sender: Any) {
    self.text = "yes! in any case of in propriete situation , Signing In is important."
        self.image = UIImage(named: "handshake")
          self.performSegue(withIdentifier: "answer", sender: self)
   print("ddddddd")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
     print("ddddddd")
            let vc = segue.destination as! answersViewController
                vc.textV = self.text
        vc.image = self.image!
        
    }
    
}
