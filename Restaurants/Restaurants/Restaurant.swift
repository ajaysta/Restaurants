//
//  Restaurant.swift
//  Restaurants
//
//  Created by Ajay Somanal on 6/10/18.
//  Copyright © 2018 ist.ajaysta.com. All rights reserved.
//

import UIKit
import CoreLocation

class Restaurant: NSObject {

    var restaurantName : String? //Restaurant name
    var location :  CLLocation!
    var distance : String?  //Restaurant distance
    var palceID: String?
}


class RestaurantDetail: NSObject {
    var address : String?
    var contactNumber :  String?
    var websiteAddress: String?
}
