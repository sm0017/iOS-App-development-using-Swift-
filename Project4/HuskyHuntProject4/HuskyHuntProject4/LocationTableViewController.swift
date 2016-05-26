
//  LocationTableViewController.swift
//  HuskyHuntProject4
//  Created by Smita Sukhadeve on 4/1/16.
//  Copyright © 2016 USM. All rights reserved.
//

/*
Assignment 4: 

It represents the MasterViewController.  It contains necessory function to load the network data, calls required function to sync
local and remote data. It also acts as CLLocationManager delegates to monitor the circular regions when user come nearby set of 
monitored locations. When user comes near by these locations, it shows alert view, indicating user found locations.
based on user response it updates the location datastore.

*/

import MapKit
import UIKit
import CoreData
import CoreLocation

class LocationTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var locations = [Location]()  // locations datasource for the tableview
    var monitoredRegions = [CLCircularRegion]()  // Monitored regions
    var locationBrain = LocationBrain()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Loading all the locally saved locations
        let locationsInstore = LocationBrain.sharedInstance.loadLocations()
        
        //setting desired properties of CLLocationManager
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
       
        // Load any saved locations if there are any , otherwise load network data.
        if  locationsInstore != nil
        {
            // Load locally saved locations if there are any
            locations = locationsInstore!
            self.locations.sortInPlace() { $0.title < $1.title }
            self.tableView.reloadData()
            
        } else {
            // Load the data from network
            refreshTableView()
            LocationBrain.sharedInstance.saveLocations(locations)  // save the remote locations
        }
    }
    
    // This function get called when push to refresh
    // It feches the remote location and check for the updates if there are any
    // and merge local changes and reload table data
    
    @IBAction func refresh(sender: UIRefreshControl) {
        
        LocationRequest().fetchLocations {
            (newLocations) -> Void in
            dispatch_async(dispatch_get_main_queue(),
                { () -> Void in
                    if newLocations.count > 0 {
                        
                        let mergedlocations =  self.mergeLocalChange(LocationBrain.sharedInstance.locations, remoteLocations: newLocations)
                        LocationBrain.sharedInstance.saveLocations(mergedlocations)
                        self.locations = LocationBrain.sharedInstance.loadLocations()!
                        self.locations.sortInPlace() { $0.title < $1.title }
                        self.tableView.reloadData()
                    }
                    sender.endRefreshing()
            })
        }
    }
    
    
    // MARK: refresh the table view when pull to refresh
    func refreshTableView()
    {
        refreshControl?.beginRefreshing()
        refresh(refreshControl!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locations.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath)
        
        // Configure the cell...
     
        if LocationBrain.sharedInstance.loadLocations() != nil {
        locations  = LocationBrain.sharedInstance.loadLocations()!
        self.locations.sortInPlace() { $0.title < $1.title }
        }
        let location = locations[indexPath.row]
        cell.textLabel?.text = location.name + " " + location.campus
        if location.locationVisited != nil {
            cell.textLabel?.text = location.name + " " + location.campus
            cell.detailTextLabel?.text = "\(location.locationVisited!)"
        }else {
            cell.textLabel?.text = location.name
            cell.detailTextLabel?.text = location.campus
        }
        
        if location.locationVisited != nil {
            cell.accessoryType = .Checkmark
         
        }else {
         
            cell.accessoryType = .None
        }
        return cell
    }
    
    // Whenever viewWillAppear check for the updates and check local changes and sync between local and remote data
    
    override func viewWillAppear(animated: Bool) {
        refreshControl?.beginRefreshing()
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, {
            LocationRequest().fetchLocations { (newLocations) -> Void in
                if newLocations.count > 0 {
                    
                    let mergedlocations =  self.mergeLocalChange(LocationBrain.sharedInstance.locations, remoteLocations: newLocations)
                    LocationBrain.sharedInstance.saveLocations(mergedlocations)
                    self.locations = LocationBrain.sharedInstance.loadLocations()!
                    self.locations.sortInPlace() { $0.title < $1.title }
                }
            }
        })
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    
    
    // MARK: - Segue to the MAP View
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "show map" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let mvc = (segue.destinationViewController as! UINavigationController).topViewController as! MapViewController
                
                if LocationBrain.sharedInstance.loadLocations() != nil {
                    locations  = LocationBrain.sharedInstance.loadLocations()!
                    self.locations.sortInPlace() { $0.title < $1.title }
                }
                let location = locations[indexPath.row]
                mvc.selectedLocation = location
            }
        }
    }
    
    
    // MARK : Location Manager delegates method. Add All the  regions to be monitored
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            
            addAllregionForMonitoring(locations, locationManager: locationManager)
        }
    }
    
    // When user enters the monitored region , add save those regions in MonitoredArray and then call alert on each of the location
    // and update the locationVisited Date if user answers with ok .
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
      
        if region is CLCircularRegion {
            monitoredRegions.append(region as! CLCircularRegion)
            locationManager.stopMonitoringForRegion(region)
        }
        
        if !monitoredRegions.isEmpty {
            while !monitoredRegions.isEmpty {
                let cr = monitoredRegions.removeFirst()
                handleFoundMonitoredRegions(cr, viewController: self, locationManager: manager)
            }
            
        }
        self.tableView.reloadData()
        self.tableView.setNeedsDisplay()
    }
    
    // Gives error if more than 20 locations are added. Hence I considred only first 20 locations
    func addAllregionForMonitoring(locations: [Location], locationManager : CLLocationManager) {
        
        if !locations.isEmpty {
        let first20 = locations[0..<20]
        for location in first20 {
            if location.locationVisited == nil {
                let region = convertEachRegion(location)
                locationManager.startMonitoringForRegion(region)
            }
        }
        }
    }
    
    // This function convert each location to CLcircular region which will be monitored by CLLocation Manager
    func convertEachRegion (location: Location) -> CLCircularRegion {
        let cr  = CLCircularRegion(center: location.coordinate, radius: 10, identifier: location.name)
        return cr
    }
    
    
    // Function get called when User  finds any of the monitored locations
    func handleFoundMonitoredRegions(region: CLCircularRegion, viewController: UIViewController, locationManager: CLLocationManager) {
        // Show an alert if application is active
        if UIApplication.sharedApplication().applicationState == .Active {
            showLocationAlert(region, viewController: viewController, locationManager: locationManager)
        }
    }
    
    
    // MARK: Functions To merge the remote and local data
    
    func mergeLocalChange(var localLocations : [Location]?, remoteLocations: [Location]) -> [Location]{
        var mergeLocations = [Location]()
        if localLocations == nil {
            localLocations = remoteLocations
        }
        else {
            for localLocation in localLocations! {
                if localLocation.locationVisited != nil {
                    for remoteLocation in remoteLocations {
                        if remoteLocation.name == localLocation.name
                        {
                            let location = remoteLocation
                            location.locationVisited = localLocation.locationVisited
                            mergeLocations.append(location)
                            
                        }
                    }
                }else {
                    
                    for remoteLocation in remoteLocations {
                        if remoteLocation.name == localLocation.name
                        {
                            let location = remoteLocation
                            mergeLocations.append(location)
                            
                        }
                    }
                }
            }
            localLocations = []
            localLocations = mergeLocations
        }
        return localLocations!
    }
    
    // get particular location by Name
    func getLocationByName(name: String, Locations: [Location] ) -> Location?
    {
        var l : Location?
        for location in locations
        {
            if location.name == name {
                l = location
            }
        }
        return l
    }
    
    
    // MARK: shows alert whenever user find any monitored locations and update the VisitedDate accordingly
    
    func showLocationAlert(region: CLCircularRegion, viewController: UIViewController, locationManager: CLLocationManager) {
        
        let title = "Congrats! You've found \(region.identifier)"
        let message = "Do you want to mark it as Visited?"
        
        let alertCtrl  = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Added Cancel Action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        alertCtrl.addAction(cancelAction)
        
        // Added Ok action
        let markVisited: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            
            // If User said Ok, we will update the LocationVisited
            self.updateVisitDate(region, locationManager: locationManager, locations: self.locations )
        }
        
        alertCtrl.addAction(markVisited)
        if viewController.presentedViewController == nil {
            viewController.presentViewController(alertCtrl, animated: true, completion: nil)
        }
    }
    
    // Whenever user discovered location we update the VisitedDate for the found locations
    func updateVisitDate(region: CLCircularRegion, locationManager: CLLocationManager, locations: [Location]) {
        locationManager.stopMonitoringForRegion(region)
        let foundLocation = self.getLocationByName(region.identifier, Locations: locations)
        if foundLocation?.locationVisited == nil {
            foundLocation?.locationVisited = NSDate()
        }
        LocationBrain.sharedInstance.saveLocations(locations)
    }
}