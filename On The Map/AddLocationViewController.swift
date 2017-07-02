//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Ankita Satpathy on 01/07/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit

class AddLocationViewController: UIViewController {
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var findOnMapLabel: UIButton!

    @IBAction func findOnMapPressed(_ sender: Any) {
        if locationTextfield.text != "" {
           let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddLinkViewController") as? AddLinkViewController
            controller?.locationName = locationTextfield.text!
          present(controller!, animated: true, completion: nil)
       }
        else{
            displayAlert(error: "Please enter a location")
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

   
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

   

}
