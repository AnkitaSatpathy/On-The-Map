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

class AddLinkViewController: UIViewController {

    @IBOutlet weak var linkTextfield: UITextField!
    @IBOutlet weak var mapview: MKMapView!
    var locationName = ""
    var pinPlace: CLPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
        
    }
    @IBAction func submitPressed(_ sender: Any) {
        updateLocationWithLink()
    }

    func getLocation() {
        
    }
    
    func updateLocationWithLink(){
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
