//
//  DetailsViewController.swift
//  Restaurants
//
//  Created by Ajay Somanal on 6/10/18.
//  Copyright © 2018 ist.ajaysta.com. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    var restaurantID : String?
    var restaurantName : String?
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var websiteName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.text = self.restaurantName
        fetchRestaurantDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchRestaurantDetail() {
        NetworkManager.sharedInstance.fetchRestaurantDetail(restaurantID: self.restaurantID!) { (restauranteDetail, errorDescription) in
            self.address.text = restauranteDetail?.address
            self.contactNumber.text = restauranteDetail?.contactNumber
            self.websiteName.text = restauranteDetail?.websiteAddress
        }
    }
    
}
