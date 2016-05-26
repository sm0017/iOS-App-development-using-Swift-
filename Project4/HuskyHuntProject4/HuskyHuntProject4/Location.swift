//
//  Location.swift
//  HuskyHuntProject4
//  Created by Smita Sukhadeve on 4/1/16.
//  Copyright © 2016 USM. All rights reserved.
//

import Foundation
import MapKit

// Model data structre

class Location: NSObject, NSCoding {
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("locations")
    
    var name: String
    var campus: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var locationVisited: NSDate?
    
    struct PropertyKey {
        static let nameKey = "name"
        static let campusKey = "campus"
        static let latitudeKey = "latitude"
        static let longitudeKey = "longitude"
        static let locationVisitedKey = "locationVisited"
    }
    
    
    init(name: String, campus : String , latitude: CLLocationDegrees, longitude:CLLocationDegrees, locationVisited: NSDate?) {
        self.name = name
        self.campus = campus
        self.latitude = latitude
        self.longitude = longitude
        self.locationVisited = locationVisited
        
    }
    
    //MARK : NSCoding encoder and decoder required for the persistent storage
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(campus, forKey: PropertyKey.campusKey)
        aCoder.encodeDouble(latitude, forKey: PropertyKey.latitudeKey)
        aCoder.encodeDouble(longitude, forKey: PropertyKey.longitudeKey)
        aCoder.encodeObject(locationVisited, forKey: PropertyKey.locationVisitedKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let campus = aDecoder.decodeObjectForKey(PropertyKey.campusKey) as! String
        let latitude = aDecoder.decodeDoubleForKey(PropertyKey.latitudeKey)
        let longitude = aDecoder.decodeDoubleForKey(PropertyKey.longitudeKey)
        let locationVisited = aDecoder.decodeObjectForKey(PropertyKey.locationVisitedKey) as? NSDate
        self.init(name: name, campus : campus , latitude: latitude, longitude:longitude, locationVisited: locationVisited)
    }
    
    
}


