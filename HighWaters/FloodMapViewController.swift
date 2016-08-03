//
//  FloodMapViewController.swift
//  HighWaters
//
//  Created by James O'Connor on 7/29/16.
//  Copyright © 2016 James O'Connor. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CloudKit

class FloodMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var detailView :UIView!
    
    weak var selectedAnnotation :MKAnnotation!
    
    var locationManager :CLLocationManager!
    
    var container :CKContainer!
    var publicDB :CKDatabase!
    var privateDB :CKDatabase!
    
    @IBOutlet weak var mapView :MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        
        self.container = CKContainer.defaultContainer()
        self.publicDB = self.container.publicCloudDatabase
        self.privateDB = self.container.privateCloudDatabase

        // Do any additional setup after loading the view.
        
        populateMap()
    }
    
    func populateMap() {
        
        let query = CKQuery(recordType: "FloodSpot", predicate: NSPredicate(value: true))
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { (records: [CKRecord]?, error: NSError?) in
            
            for record in records! {
                
                let floodLocation = record["Location"] as! CLLocation
                
                print(floodLocation)
                
                let pinAnnotation = MKPointAnnotation()
                
                pinAnnotation.coordinate = floodLocation.coordinate
                
                pinAnnotation.title = record["Title"] as? String
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.addAnnotation(pinAnnotation)
                })
                
            }
        
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views:[MKAnnotationView]) {
        
        if let annotationView = views.first {
            
            if let annotation = annotationView.annotation {
                
                if annotation is MKUserLocation {
                    
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000,1000)
                    
                    self.mapView.setRegion(region, animated: true)
                    
                }
            }
            
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation:MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
            
        }
        
        var cautionAnnotationView =
        
            self.mapView.dequeueReusableAnnotationViewWithIdentifier("CautionAnnotationView")
        
        if cautionAnnotationView == nil {
            
            cautionAnnotationView = CautionAnnotationView(annotation: annotation, reuseIdentifier: "CautionAnnotationView")
            
        }
        
        cautionAnnotationView?.canShowCallout = true
        cautionAnnotationView?.rightCalloutAccessoryView = self.detailView
        
        return cautionAnnotationView
        
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {

        print("Phone Did Shake")
        
        if motion == .MotionShake {
            
            let pinAnnotation = MKPointAnnotation()
            
            let userLocation = self.mapView.userLocation.coordinate
            
            pinAnnotation.coordinate = CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
            self.mapView.addAnnotation(pinAnnotation)
            
            addFloodRecord()
            
        }
    
    }
    
    func addFloodRecord() {
        
        let floodRecord = CKRecord(recordType: "FloodSpot")
        floodRecord["Title"] = "Flood!"
        
        let addLocation :CLLocation = self.locationManager.location!
        floodRecord["Location"] = addLocation
        
        self.publicDB.saveRecord(floodRecord) { (record :CKRecord?, error :NSError?) in
            
            print(record?.recordID)
            
        }

    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        self.selectedAnnotation = view.annotation!
        
    }
    
    @IBAction func deleteButtonPressed() {
        
        deleteFloodRecord()
        
        self.mapView.removeAnnotation(selectedAnnotation)
    }
    
    
    func deleteFloodRecord() {
        
        let query = CKQuery(recordType: "FloodSpot", predicate: NSPredicate(value: true))
        
        self.publicDB.performQuery(query, inZoneWithID: nil) { (records :[CKRecord]?, error: NSError?) in
            
            if let records = records {
                
                if let record = records.first {
                    
                    self.publicDB.deleteRecordWithID(record.recordID, completionHandler: { (recordID :CKRecordID?, error :NSError?) in })
                    
                }
                
            }
          
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
