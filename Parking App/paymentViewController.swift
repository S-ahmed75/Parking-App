//
//  paymentViewController.swift
//  Parking App
//
//  Created by sunny on 02/11/2018.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit

class paymentViewController: UIViewController {

    
    
    var Fname = ""
    var Lname = ""
    var email = ""
    var pass = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func paymentButton(_ sender: Any) {
    print("segg")
    self.performSegue(withIdentifier: "nextToTerms", sender: self)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextToTerms"{
            let dest = segue.destination as! TermsViewController
            dest.Fname = self.Fname
            dest.Lname = self.Lname
            dest.email = self.email
            dest.pass = self.pass
        }
    }
    /*
    // MARK: - Navigation

     
    // In a storyboard-based application, you will often want to do a little preparation before navigation nextToTerms
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
