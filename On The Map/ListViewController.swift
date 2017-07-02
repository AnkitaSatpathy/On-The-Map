//
//  ListViewController.swift
//  On The Map
//
//  Created by Ankita Satpathy on 02/07/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit

class ListViewController: UIViewController  {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let b1 =  UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshView))
        let b2 = UIBarButtonItem(image:#imageLiteral(resourceName: "pin")  , style: .plain, target: self, action: #selector(pinIt))
        self.navigationItem.rightBarButtonItems = [b1,b2]
        let b3 = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOut))
        self.navigationItem.leftBarButtonItem = b3
    }

   

    func refreshView(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //refreshes the table
        print("refreshing view")
        ParseAPIClient.sharedInstance().taskForGetStudentLocation { (data, error) in            //starts getting students locations
            print("In taskForGetStudentLocation")
            if error == nil{
                performUIUpdatesOnMain {
                    
                    guard let results = data?[ParseAPIClient.ParseAPIConstants.results] as? [[String:AnyObject]] else{      //find results key in the parsed data
                        self.displayAlert(error: "Couldn't get results key")
                        return
                    }
                    StudentShared.sharedInstance.students = ParseAPIClient.ParseModel.studentInformationFromResults(results: results)           //make an array of the individual student objects
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    self.tableView.reloadData()
                }
            }else{
                print(error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(error: error)
            }
            
        }
    }
    
    func logOut(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //delete the session and bring back the login view
        UdacityAPIClient.sharedInstance().taskForDeleteMethod { (response, error) in
            if response!{
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                print(error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(error: error)
            }
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func pinIt(){
        
        //brings the information posting view controller
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") as! AddLocationViewController
        self.present(controller, animated: true, completion: nil)
    }
    
}

//MARK : TABLEVIEWCONTROLLER DATASOURCE AND DELEGATES

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(StudentShared.sharedInstance.students.count)
        return StudentShared.sharedInstance.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = StudentShared.sharedInstance.students[indexPath.row]                                                               //data to show in the table cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCell", for: indexPath)
        cell.textLabel?.text = student.firstName + " " + student.lastName
        cell.detailTextLabel?.text = student.mapString
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = StudentShared.sharedInstance.students[(indexPath as NSIndexPath).row]
        
                if let url = URL(string: student.mediaURL){
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else{
                self.displayAlert(error: "URL can't be opened.")
            }
        }else{
            self.displayAlert(error: "URL can't be opened.")
        }

    }
}
