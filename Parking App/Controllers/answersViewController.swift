//
//  answersViewController.swift
//  Parking App
//
//  Created by sunny on 25/11/2018.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit

class answersViewController: UIViewController {

    @IBOutlet weak var ImageLabel: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var image = #imageLiteral(resourceName: "no image")
    var textV = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textLabel.text = textV
        self.ImageLabel.image = image
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
