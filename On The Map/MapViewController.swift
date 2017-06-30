//
//  MapViewController.swift
//  On The Map
//
//  Created by Ankita Satpathy on 29/06/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit
import Foundation
import  MapKit

class MapViewController: UIViewController , MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let b1 =  UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshView))
        let b2 = UIBarButtonItem(image:#imageLiteral(resourceName: "pin")  , style: .plain, target: self, action: #selector(pinIt))
        self.navigationItem.rightBarButtonItems = [b1,b2]
        let b3 = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.leftBarButtonItem = b3
        mapView.delegate = self
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ParseAPIClient.sharedInstance().taskForGetLocation(uniqueKey: StudentModel.userKey) { (data, error) in
            print("In taskForGetLocation")
            if error == nil {
                guard let results = data?[ParseAPIClient.ParseAPIConstants.results] as? [[String:AnyObject]] else {
                   self.displayAlert(error: "Could  not find results key")
                    return
                }
                
                guard let latitude = results.last?[ParseAPIClient.ParseAPIConstants.latitude] as? Double else{
                    self.displayAlert(error: "Could not find latitude key")
                    return
                }
                StudentModel.latitude = latitude
                
                guard let longitude = results.last?[ParseAPIClient.ParseAPIConstants.longitude] as? Double else{
                    self.displayAlert(error: "Couldn't find longitude key")
                    return
                }
                StudentModel.longitude = longitude
                
                guard let mediaURL = results.last?[ParseAPIClient.ParseAPIConstants.mediaURL] as? String else{
                    self.displayAlert(error: "Couldn't find mediaURL key")
                    return
                }
                StudentModel.mediaURL = mediaURL
                
                guard let mapString = results.last?[ParseAPIClient.ParseAPIConstants.mapString] as? String else{
                    self.displayAlert(error: "Couldn't find mapString key")
                    return
                }
                StudentModel.mapString = mapString
                
                guard let objectId = results.last?[ParseAPIClient.ParseAPIConstants.objectId] as? String else{
                    self.displayAlert(error: "Couldn't find objectId key")
                    return
                }
            StudentModel.objectID = objectId
                
                let mapLat = StudentModel.latitude
                let mapLong = StudentModel.longitude
                
                UIApplication.shared.isNetworkActivityIndicatorVisible =  false
                
                performUIUpdatesOnMain {
                    let coordinates = CLLocationCoordinate2D(latitude: mapLat, longitude: mapLong)
                    let corrdinateSpan = MKCoordinateSpanMake(10, 10)
                    let coordinateRegion = MKCoordinateRegionMake(coordinates, corrdinateSpan)
                    self.mapView.setRegion(coordinateRegion, animated: true)
                }
            
            }
            else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(error: error)
                print(error!)
            }
            
        }
        self.refreshView()
    }
    
    func refreshView() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ParseAPIClient.sharedInstance().taskForGetStudentLocation { (data, error) in
            print("In taskForGetStudentLocation")
            performUIUpdatesOnMain {
                if error == nil{
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    guard let results = data?[ParseAPIClient.ParseAPIConstants.results] as? [[String:AnyObject]] else{
                        self.displayAlert(error: "Couldn't get results key")
                        return
                    }
                    StudentShared.sharedInstance.students = ParseAPIClient.ParseModel.studentInformationFromResults(results: results)
                    self.reAnnotateMap()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                else{
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(error: error)
                }
            }
        }
    }
    
    func pinIt(){
        //let controller = self.storyboard?.instantiateViewController(withIdentifier: <#T##String#>)
    }
    
    func logout() {
        UdacityAPIClient.sharedInstance().taskForDeleteMethod { (response, error) in
            
            if response! {
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            }
                else{
                    print(error!)
                    self.displayAlert(error: error)
                }
            }
        }
    
    
    func reAnnotateMap() {
        print("reannotating map")
        var annotations = [MKPointAnnotation]()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        for student in StudentShared.sharedInstance.students {
            let studentLatitude = CLLocationDegrees(student.latitude)
             let studentLongitude = CLLocationDegrees(student.longitude)
            let coordinates = CLLocationCoordinate2D(latitude: studentLatitude, longitude: studentLongitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle =  student.mediaURL
            
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        UIApplication.shared.isNetworkActivityIndicatorVisible  = false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
