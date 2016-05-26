//
//  LocationRequest.swift
//  Created by Smita Sukhadeve on 3/30/16.
//  Copyright © 2016 USM. All rights reserved.
//
/*

It contains necessary methods to load the data from the network, pasring the JSON and converting it to Array of locations
*/

import Foundation

public class LocationRequest : NSObject {
    
    // Method to get the data from the site
    
    typealias PropertyList = AnyObject?
    
    // returns array of Locations
    func fetchLocations(handler: ([Location]) -> Void) {
        
        fetch { results in
            var locations = [Location]()
            if let locationsJSON = results as? [Dictionary<String, AnyObject>] {
                for locationJSON in locationsJSON {
                    if let location = locationFromJSON(locationJSON) {
                        locations.append(location)
                    }
                }
            }
            handler(locations)
        }
    }
    
    // Function which fetch the network data which takes the handler as an argument which in tern convert network data to Property list
    // Which we later convert to the Array of locations
    func fetch (handler: (results:PropertyList?)-> Void) {
        let urlString = "https://raw.githubusercontent.com/stephenhouser/cos470/master/locations.json"
        let locationURL = NSURL(string: urlString )!
        let session = NSURLSession.sharedSession()
        getData(locationURL , session: session, handler : handler)
    }
    
    // Read the data from the network and convert to property list
    func getData( url: NSURL, session: NSURLSession, handler: (PropertyList?) -> Void) {
        
        session.dataTaskWithURL(url) { (data, response, error) -> Void in
            
            var propertyListResponse: PropertyList?
            if data != nil  {
                
                propertyListResponse = try? NSJSONSerialization.JSONObjectWithData(
                    data!,
                    options: NSJSONReadingOptions.MutableLeaves)
                
                if propertyListResponse == nil {
                    let error = "Couldn't parse JSON response."
                    propertyListResponse = error
                }
            }else {
                let error = "No response"
                propertyListResponse = error
            }
            handler(propertyListResponse)
            }.resume()
    }
}

// Function takes JSON and create the location
func locationFromJSON(json: Dictionary<String, AnyObject>) -> Location? {
    if let name = json["name"] as? String,
        campus  = json["campus"] as? String,
        latitude = json["latitude"] as? Double,
        longitude = json["longitude"] as? Double {
            return Location(name: name, campus: campus, latitude: latitude, longitude: longitude, locationVisited: nil)
    }
    
    return nil
}


