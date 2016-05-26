//
//  MapViewController.swift
//  HuskyHuntProject4
//
//  Created by Smita Sukhadeve on 4/1/16.
//  Copyright © 2016 USM. All rights reserved.
//

import MapKit
import UIKit
import CoreLocation


//MARK : // MARK: - MKAnnotation for the MAP View
extension Location: MKAnnotation
{
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var title: String? { return name }  // It can be nil but it should not be null
    var subtitle: String? { return campus }
    
}

// We added CLLocationManagerDelegate to get the user current location position
class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var  locationManager = CLLocationManager()
    var span: MKCoordinateSpan?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        handleLocations(location!)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var location: Location?
    var selectedLocation: Location {
        get {
            return location!
        }set {
            location = newValue
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!{
        didSet {
            mapView.mapType = .Standard
            mapView.delegate = self
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status{
        case .AuthorizedAlways:
            locationManager.startUpdatingLocation()
        case .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default : break
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userCurrentLocation = locations.last!
        let center = CLLocationCoordinate2D(latitude: userCurrentLocation.coordinate.latitude, longitude: userCurrentLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
        self.mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = userCurrentLocation.coordinate
        annotation.title = " Current location"
       
        mapView.addAnnotation(annotation)
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            self.handleMonitoredRegions(region as! CLCircularRegion, viewController: self, locationManager: manager)
        }
    }
    
    // function shows the selected location from the tableView
    private func handleLocations(location : Location) {
        mapView.addAnnotation(location)
     }
    
    // This function shows get called when monitored locations found when we are in mapView
    func handleMonitoredRegions(region: CLCircularRegion, viewController: UIViewController, locationManager: CLLocationManager) {
        if UIApplication.sharedApplication().applicationState == .Active {
            showLocationAlert(region, viewController: viewController, locationManager: locationManager)
        }
    }
    
    
    func showLocationAlert(region: CLCircularRegion, viewController: UIViewController, locationManager: CLLocationManager) {
        let title = "Congrats! you found \(region.identifier)"
        let message = " Do you want to mark the location as Visited?"
        let alertCtrl  = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            print("do nothing")
        }
        alertCtrl.addAction(cancelAction)
        
        // If user press ok, get the locations and update the visited date
        let markVisited: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            let locs = LocationBrain.sharedInstance.loadLocations()
            if locs != nil {
                self.updateVisitDate(region, locationManager: locationManager, locations: locs! ) }
        }
        alertCtrl.addAction(markVisited)
        
        if viewController.presentedViewController == nil {
            viewController.presentViewController(alertCtrl, animated: true, completion: nil)
        }
    }
    
    
    // Function changes the Visited date if found any
    func updateVisitDate(region: CLCircularRegion, locationManager: CLLocationManager, locations: [Location]) {
        locationManager.stopMonitoringForRegion(region)
        let foundLocation = getLocationByName(region.identifier, locations: locations)
        if foundLocation?.locationVisited == nil {
            foundLocation?.locationVisited = NSDate()
            LocationBrain.sharedInstance.saveLocations(locations)
        }
        
    }
  
    
    // MARK: CallOut alert function
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        var title: String
        var message: String
        if view.annotation is MKPointAnnotation{
          title = " Your current location"
          message = "  "
        }else {
    
         title = "This is Your selected location"
         message = "  "
        }
        let alertCtrl  = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
      
        //Create Cancel Action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        alertCtrl.addAction(cancelAction)
        
        // Create OK action to mark place as visited
        let markVisited: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
        }
        alertCtrl.addAction(markVisited)
        if self.presentedViewController == nil {
            self.presentViewController(alertCtrl, animated: true, completion: nil)
        }
        
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("locations")
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "locations")
            view?.canShowCallout = true
        }
        
        view?.annotation = annotation
        view!.rightCalloutAccessoryView = nil
        let infobtn = UIButton(type: UIButtonType.DetailDisclosure) as UIButton // button with info sign in it
        view?.rightCalloutAccessoryView = infobtn
        return view
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func getLocationByName(name: String, locations: [Location] ) -> Location?
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
    
}

