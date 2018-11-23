//
//  constant.swift
//  Parking App
//
//  Created by sunny on 13/11/2018.
//  Copyright © 2018 Mohammad Ali Panhwar. All rights reserved.
//


import UIKit
import GoogleMaps
import SVProgressHUD
import GooglePlaces
import CountryPickerView
import FirebaseFirestore
import Firebase
import PMAlertController
import Geofirestore

class constant{
     let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    
}

struct TableDAta {
    
    // MARK: Properties
    
    let userFirstName: String
    let userSecondName:String
     var space: Bool = false
    var Email:String = ""
    var OwnerType:String = ""
    var Phone: String = ""
    
    var SpaceType:String = ""
    var SpaceWidth: String = ""
    var address : String = ""
    var numberofSpaces : String = ""
    var password :String = ""
    
    
    // MARK: Initializer
    
    // Generate a Villain from a three entry dictionary
    
    init(userFirstName: String, userSecondName:String, space: Bool,Email:String, OwnerType:String, Phone: String, SpaceType:String, SpaceWidth: String, address : String, numberofSpaces : String, password :String){
        
        self.userFirstName = userFirstName
        self.userSecondName = userSecondName
        self.space = space
        self.Email = Email
        self.OwnerType = OwnerType
        self.Phone = Phone
        self.SpaceType = SpaceType
        self.SpaceWidth = SpaceWidth
        self.address = address
        self.numberofSpaces = numberofSpaces
        self.password = password
        
    }
    init(userFirstName: String, userSecondName:String, space: Bool){
        
        self.userFirstName = userFirstName
        self.userSecondName = userSecondName
        self.space = space
        
    }
}
