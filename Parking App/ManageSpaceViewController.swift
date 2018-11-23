//
//  ManageSpaceViewController.swift
//  Parking App
//
//  Created by Mohammad Ali Panhwar on 9/28/18.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SVProgressHUD
struct Parkings {
    var ownerType:String
    var Phone:String
    var spaceType:String
    var SpaceWidth:String
    var numberOfspaces:String
    var price:String
}


class ManageSpaceViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    var userId = ""
    
    var arr:[Parkings] = []
    var price1 = "18"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAnotherSpace: UIButton!
    
    @IBOutlet weak var menu: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addAnotherSpace.layer.cornerRadius = 8
        self.tableView.allowsSelection = false
        
        SVProgressHUD.show()

        


        tableView.dataSource = self
        tableView.delegate = self
        sideMenus()
       
    }

    func loaddata(){
        self.db.collection("Users").document(self.uid!).getDocument(completion: { (snaps, errr) in
            if let doc2 =  snaps, doc2.exists{
                print(doc2.data(),"mieeee")
                for d in doc2.data()!{
                    
                    var numberofSpa:Int = 0
                    var bookSpac:Int = 0
                    
                    if d.key == "userId"{
                        let  u:String = d.value as! String
                        self.userId = u
                        
                    }
                }}
        })
        
        
        DispatchQueue.global(qos: .background).async {
            var spaceID = ""
            
            self.db.collection("Users").document(self.uid!).getDocument { (document, error) in
                self.arr.removeAll()
                self.tableView.reloadData()
                
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    spaceID = document.data()!["SpaceId"] as! String
                    
                    
                    self.db.collection("ActiveParkings").document(self.userId).collection("parkingSpace").getDocuments() { (document, error) in
                        print("tiiii")
                       
                        if let errr = error {
                            print("Document Does not Exits")
                            
                        } else {
                            for document in document!.documents{
                                
                                
                                let spaceType = document.data()["SpaceType"] as! String
                                let ownerType = document.data()["OwnerType"] as! String
                                let spacewidth = document.data()["SpaceWidth"] as! String
                                let phone = document.data()["Phone"] as! String
                                let numberofSpaces = document.data()["numberofSpaces"] as! String
                                
                                if let price = document.data()["pricePerHour"] as? String {
                                    self.price1 = price
                                }
                                let ar = Parkings(ownerType: ownerType, Phone: phone, spaceType: spaceType, SpaceWidth: spacewidth, numberOfspaces: numberofSpaces, price: self.price1)
                                self.arr.append(ar)
                                
                                self.tableView.reloadData()
                                
                                print(spaceType)
                            }
                        }
                    }}
                
            }
            DispatchQueue.main.async {
                
                SVProgressHUD.dismiss()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       loaddata()
    }

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! ManagespaceTableViewCell
        cell.Space3.text = "\(arr[indexPath.row].ownerType) \(arr[indexPath.row].spaceType) - (\(arr[indexPath.row].numberOfspaces) space)"
        cell.Space3.sizeToFit()
        cell.Edit.tag = indexPath.row
        cell.Edit.addTarget(self, action: #selector(ManageSpaceViewController.segue(_sender:)), for: UIControlEvents.touchUpInside)
        cell.prices.text = arr[indexPath.row].price
    //    arr.removeAll()
        return cell
    }

    @objc func segue(_sender:UIButton){
        performSegue(withIdentifier: "edit", sender: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }

    func sideMenus(){
        if revealViewController() != nil {
            menu.target = revealViewController()
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }
    @IBAction func AddanotherSpace(_ sender: Any) {
     
        
    }
    

}
