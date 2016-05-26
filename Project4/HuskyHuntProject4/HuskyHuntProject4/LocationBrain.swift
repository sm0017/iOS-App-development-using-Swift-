//
//  LocationBrain.swift
//  HuskyHuntProject4
//  Copyright © 2016 USM. All rights reserved.
//

import Foundation

// Singleton pattern to share the data between MapView and tableView

class LocationBrain {
    
    var locations: [Location]?
    
    class var sharedInstance: LocationBrain {
        struct Singleton {
            static let instance = LocationBrain()
        }
        
        return Singleton.instance
    }
    
    // Load the locations from the saved File
    func loadLocations() -> [Location]? {
        locations = (NSKeyedUnarchiver.unarchiveObjectWithFile(Location.ArchiveURL.path!) as? [Location])
        return locations
    }
    
    //Saves the locations at given file path
    func saveLocations(locations: [Location]) {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(locations, toFile: Location.ArchiveURL.path!)
        if !isSuccessfulSave {
            print ("failed to save Locations")
        }
    }
    
}