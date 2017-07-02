//
//  AddLinkViewController.swift
//  On The Map
//
//  Created by Ankita Satpathy on 01/07/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class AddLinkViewController: UIViewController , MKMapViewDelegate , UITextFieldDelegate{

    @IBOutlet weak var linkTextfield: UITextField!
    @IBOutlet weak var mapview: MKMapView!
    var locationName = ""
    var pinPlace: CLPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
        setDelegate(linkTextfield)
        
    }
    @IBAction func submitPressed(_ sender: Any) {
        updateLocationWithLink()
    }

    func getLocation() {
        print("Getting location")
        guard locationName != nil else{               //checks whether the location is entered or not
            displayAlert(error: "Please enter a location")
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //start geocoding the string mentioned for location
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.locationName) { (results, error) in
            print("Geocoding address")
            guard error == nil else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(error: "Sorry there was an error with your request")
                return
            }
            
            guard (results?.isEmpty) == false else{                 //find whether there is any data recieved
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(error: "Sorry we couldn't find the specified location")
                return
            }
            
            performUIUpdatesOnMain {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.pinPlace = results![0]
                
                self.mapview.showAnnotations([MKPlacemark(placemark: self.pinPlace)] , animated: true)        //annotate the map according to the location specified
                
                if StudentModel.mediaURL.isEmpty == false{
                    self.linkTextfield.text = StudentModel.mediaURL
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
        }

    }
    
    func updateLocationWithLink(){
        print("Updating location with link")
        guard linkTextfield.text != nil  else {
            displayAlert(error: "Please enter a link")
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //if the user already has an objectID then use taskForPUTMethod otherwise use taskForPostLocation
        if StudentModel.objectID.isEmpty {
            ParseAPIClient.sharedInstance().taskForPostLocation(uniqueKey: StudentModel.userKey, firstName: StudentModel.firstName, lastName: StudentModel.lastName, mapString: locationName, mediaURL: linkTextfield.text!, latitude: (self.pinPlace.location?.coordinate.latitude)!, longitude: (self.pinPlace.location?.coordinate.longitude)!, completionHandlerForPost: { (data, error) in
                print("In taskForPostLocation")
                if error == nil {
                    self.enterData()
                    
                    guard let objectId = data?[ParseAPIClient.ParseAPIConstants.objectId] as? String else {
                        self.displayAlert(error: "Couldn't find objectID")
                        return
                    }
                    StudentModel.objectID = objectId
                    performUIUpdatesOnMain {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else{
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(error: error)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }
        else{
            ParseAPIClient.sharedInstance().taskForPutMethod(objectID: StudentModel.objectID, uniqueKey: StudentModel.userKey, firstName: StudentModel.firstName, lastName: StudentModel.lastName, mapString: locationName, mediaURL: linkTextfield.text!, latitude: (self.pinPlace.location?.coordinate.latitude)!, longitude: (self.pinPlace.location?.coordinate.longitude)!, completionHandlerForPost: { (success, error) in
                print("In taskForPutMethod")
                print(StudentModel.objectID)
                if success! {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.enterData()
                    performUIUpdatesOnMain {
                        self.dismiss(animated: true, completion: nil)
                    }
                }else{
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(error: error)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })

        }
    }
    
    func enterData() {
        print("entering data")
        
        //save the data till the app runs
        StudentModel.latitude = (self.pinPlace.location?.coordinate.latitude)!
        StudentModel.longitude = (self.pinPlace.location?.coordinate.longitude)!
        
        StudentModel.mapString = self.locationName
        StudentModel.mediaURL = self.linkTextfield.text!

    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
    func setDelegate(_ textfield: UITextField){
        textfield.delegate = self
    }


}
