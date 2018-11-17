//
//  EmailSignUpViewController.swift
//  Parking App
//
//  Created by Mohammad Ali Panhwar on 9/15/18.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import PMAlertController
import  SVProgressHUD

class EmailSignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    //    @IBOutlet weak var email: UITextField!
//    @IBOutlet weak var password: UITextField!
//    
    var name = ""
    var surname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        password.delegate = self
    }
    let uid = Auth.auth().currentUser?.uid

    @IBAction func signUpbutton(_ sender: Any) {
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: self.email.text!, password: self.password.text!) { (FirUser, error) in
            if error != nil {
               print(error?.localizedDescription)
                let alertVC = PMAlertController(title: "Error", description: (error?.localizedDescription)!, image: #imageLiteral(resourceName: "your-logo-here"), style: .alert)
                
                alertVC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: { () -> Void in
                    print("Capture action Cancel")
                }))
                SVProgressHUD.dismiss()
                
                self.present(alertVC, animated: true, completion: nil)
               
            }else{
                SVProgressHUD.dismiss()
                
            self.performSegue(withIdentifier: "nextToPayment", sender: self)
            }
        }
        
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextToPayment"{
            let dest = segue.destination as! paymentViewController
            dest.Fname = self.firstName.text!
            dest.Lname = self.lastName.text!
            dest.email = self.email.text!
            dest.pass = self.password.text!
        }
    }

}
