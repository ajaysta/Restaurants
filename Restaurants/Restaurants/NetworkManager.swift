//
//  NetworkManager.swift
//  Restaurants
//
//  Created by Ajay Somanal on 6/9/18.
//  Copyright © 2018 ist.ajaysta.com. All rights reserved.
//

import UIKit
import CoreLocation

class NetworkManager: NSObject {


    let LOCATION = "location="
    let RADIUS = "radius="
    var KEY = "key="
    let baseURL = "https://maps.googleapis.com/maps/api/place/"
    
    public static let sharedInstance = NetworkManager()
    
    
    func getKey() {
        var path = Bundle.main.path(forResource: "Utilities", ofType: "plist")
        
        var keyDetails = Dictionary()
        var google = NSDictionary(contentsOfFile: path!)
        if let apiKey = google["places-key"] as? String {
            self.KEY = "\(self.KEY)\(apiKey)"
        } else {
            // TODO: Exception handling
            println("Exception: places-key is not set in google.plist")
        }
    }
    
    func fetchRestaurants (location: CLLocationCoordinate2D,
                                         radius: Int,
                                          query: String,
                                          callback: @escaping (_ restaurants: [Restaurant]?, _ errorDescription: String?) -> Void) {
        
        let ACTION = "nearbysearch/json?"
        let urlEncodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlString = "\(baseURL)\(ACTION)\(LOCATION)\(location.latitude),\(location.longitude)&\(RADIUS)\(radius)&\(KEY)&name=\(urlEncodedQuery!)"
        
        guard let url = NSURL(string: urlString) else {
            print("Error: cannot create URL")
            callback(nil, "Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url as URL)

        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        // make the request
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling Places")
                callback(nil, error?.localizedDescription)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                callback(nil, "Error: did not receive data")
                return
            }
            DispatchQueue.main.sync {
                callback(NetworkManager.parseForRestaurantsList(data: responseData), nil)
            }
        }
        task.resume()
        
        print("Lets fetch restaurants")
    }
    
    func fetchRestaurantDetail ( restaurantID: String,
                                 callback: @escaping (_ restaurantDetail: RestaurantDetail?, _ errorDescription: String?) -> Void) {
        let DETAILS = "details/json?placeid="
        let urlString = "\(baseURL)\(DETAILS)\(restaurantID)&\(KEY)"
        
        guard let url = NSURL(string: urlString) else {
            print("Error: cannot create URL")
            callback(nil, "Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url as URL)
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                print("error calling Places")
                callback(nil, error?.localizedDescription)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                callback(nil, "Error: did not receive data")
                return
            }
            DispatchQueue.main.async {
                callback(NetworkManager.parseForRestaurantDetail(responseData: responseData), nil)
            }
        }
        task.resume()
    }
    
    class func parseForRestaurantDetail (responseData : Data)  -> RestaurantDetail {
        // parse the result as JSON, since that's what the API provides
        let restaurantInfo = RestaurantDetail()
        do {
            guard let jsonString = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions()) as? [String: Any] else {
                print("error trying to convert data to JSON")
                return restaurantInfo
            }
            guard let restaurantDetail  = jsonString["result"]as? NSDictionary else {
                print("error trying to get  restaurants list")
                return restaurantInfo
            }
            restaurantInfo.address = restaurantDetail["formatted_address"] as! String?
            restaurantInfo.contactNumber = restaurantDetail["formatted_phone_number"] as! String?
            restaurantInfo.websiteAddress = restaurantDetail["website"] as! String?
        }
        catch {
            print(" Exception occured in parseForRestaurantDetail")
        }
        return restaurantInfo
    }
    
    class func parseForRestaurantsList(data : Data) -> [Restaurant] {
        var restaurantsList = [Restaurant]()
        do  {
            guard let jsonString = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: Any] else {
                print("error trying to convert data to JSON")
                return restaurantsList
            }
            
            guard let restaurants  = jsonString["results"] as? Array<NSDictionary> else {
                print("error trying to get  restaurants list")
                return restaurantsList
            }
            
            for restaurant in restaurants {
                let restaurantInfo = Restaurant()
                let name = restaurant["name"] as! String
                if let geometry = restaurant["geometry"] as? NSDictionary {
                    if let location = geometry["location"] as? NSDictionary {
                        let lat = location["lat"] as! CLLocationDegrees
                        let long = location["lng"] as! CLLocationDegrees
                        restaurantInfo.location = CLLocation(latitude: lat, longitude: long)
                        restaurantInfo.restaurantName = name
                        restaurantInfo.palceID = restaurant["place_id"] as? String
                        restaurantsList.append(restaurantInfo)
                    }
                }
            }
        }
        catch {
            print("Exception occured in parseForRestaurantsList")
        }
        return restaurantsList
    }

}
