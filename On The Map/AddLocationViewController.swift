//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Ankita Satpathy on 01/07/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var findOnMapLabel: UIButton!
    var placemark : CLPlacemark!

    @IBAction func findOnMapPressed(_ sender: Any) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if locationTextfield.text != "" {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString((locationTextfield?.text)!, completionHandler: { (placemarks, error) in
                if error == nil {
                    if let placemarks = placemarks {
                        self.placemark = placemarks[0] as CLPlacemark
                        
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddLinkViewController") as? AddLinkViewController
                        controller?.locationName = self.locationTextfield.text!
                        controller?.pinPlace = self.placemark
                        self.present(controller!, animated: true, completion: nil)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
                else{
                    self.displayAlert(error: "Location not found,Enter a valid location")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    return
                }
            })
            
       }
        else{
            displayAlert(error: "Please enter a location")
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       locationTextfield.delegate = self
    }

   
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
   

}
