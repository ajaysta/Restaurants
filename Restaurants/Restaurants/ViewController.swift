//
//  ViewController.swift
//  Restaurants
//
//  Created by Ajay Somanal on 6/9/18.
//  Copyright © 2018 ist.ajaysta.com. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var restaurantsTableview: UITableView!
    @IBOutlet weak var restaurantSearchBar: UISearchBar!
    
    var restaurants : [Restaurant] = [Restaurant]()
    var locationManager: CLLocationManager!
    var networkManager = NetworkManager()
    var currentLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineMyCurrentLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail" {
            if let indexPath = self.restaurantsTableview.indexPathForSelectedRow {
                let controller = segue.destination as! DetailsViewController
                controller.restaurantID = restaurants[indexPath.row].palceID
                controller.restaurantName = restaurants[indexPath.row].restaurantName
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, !query.isEmpty {
            self.currentLocation = locationManager.location!
            let path = Bundle.main.path(forResource: "Utilities", ofType: "plist")
            let keyDetails = NSDictionary(contentsOfFile: path!)
            let radius = keyDetails!["Radius"] as? Int

            networkManager.fetchRestaurants(location: self.currentLocation.coordinate, radius: radius!, query:query) { (restaurants, errorDescription) in
                if errorDescription != nil {
                    // Display error to user
                }
                else if (restaurants?.count)! > 0 {
                self.restaurants = restaurants!
                self.sortBasedOnDistance()
                DispatchQueue.main.async {
                        self.restaurantsTableview.reloadData()
                    }
                }
            }
        }
    }
    
    func sortBasedOnDistance() {
        self.restaurants.sort(by: { (restaurant0:Restaurant , restaurant1: Restaurant) -> Bool in
            if  (restaurant0.location.distance(from: self.currentLocation) >  restaurant1.location.distance(from: self.currentLocation)) {
                return false
            }
            return true
        })
    }
    
}

extension ViewController : CLLocationManagerDelegate{
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }

    func calculateDistanceInMiles(coordinate: CLLocation) -> String {
        let coordinate₀ = CLLocation(latitude: self.currentLocation.coordinate.latitude,
                                                    longitude: self.currentLocation.coordinate.longitude)
        let distanceInMile = coordinate₀.distance(from: coordinate)/1609
        let distance = String(format: "%.2f", distanceInMile) + " mi"
        return distance
    }
}


extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCellView
        let restaurantInfo = restaurants[indexPath.row]  as Restaurant
        cell.restaurantName.text = restaurantInfo.restaurantName
        let distanceInMeters = self.calculateDistanceInMiles(coordinate: restaurantInfo.location)
        cell.restaurantDistance.text = distanceInMeters
        return cell
    }
}



