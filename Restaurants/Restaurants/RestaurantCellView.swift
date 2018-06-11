//
//  RestaurantCellView.swift
//  Restaurants
//
//  Created by Ajay Somanal on 6/10/18.
//  Copyright © 2018 ist.ajaysta.com. All rights reserved.
//

import UIKit

class RestaurantCellView: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantDistance : UILabel!
}
