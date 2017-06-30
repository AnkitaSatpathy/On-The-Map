//
//  ViewController.swift
//  On The Map
//
//  Created by Ankita Satpathy on 26/06/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
     var keyboardOnScreen = false
    
    @IBAction func loginPressed(_ sender: Any) {
        setUIEnabled(enabled: false)
        
        guard emailTF.text != nil && passwordTF.text != nil else{
            setUIEnabled(enabled: true)
            self.displayAlert(error: "One of the fields is empty")
            return
        }
        print("Login pressed")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
       
        UdacityAPIClient.sharedInstance().taskForPostmethod(username: emailTF.text!, password: passwordTF.text!) { (data, error) in
            print("In taskForPostMethod")
            if error == nil{
                guard let account = data?["account"] as? [String:Any] else{     //find account key in the parsed data
                    self.displayAlert(error: "The username/password is incorrect. Please try again.")
                    self.setUIEnabled(enabled: true)
                    return
                }
                
                self.completeLogin(account: account)
            }else{
                print(error!)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(error: error)
                self.setUIEnabled(enabled: true)
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate(emailTF)
        setDelegate(passwordTF)
        
        subscribeToNotification(notification: .UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(notification: .UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(notification: .UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(notification: .UIKeyboardDidHide, selector: #selector(keyboardDidHide))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeFromNotifications()
    }

    func completeLogin(account: [String:Any]){
        
        //continuing the login process
        setUIEnabled(enabled: true)
        if let key = account["key"] as? String{
            print("In completeLogin")
            StudentModel.userKey = key
            print(key)
            
            UdacityAPIClient.sharedInstance().taskForGetData(userId: key){ (data, error) in
                print("In taskForGetData")
                if error == nil{
                    let userData = data?["user"] as! NSDictionary
                    let firstName = userData["first_name"] as! String
                    let lastName = userData["last_name"] as! String
                    
                    
                    StudentModel.firstName = firstName
                    StudentModel.lastName = lastName
                    print(StudentModel.firstName)
                    print(StudentModel.lastName)
                }else{
                    print(error)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(error: error)
                }
            }
        }else{
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.displayAlert(error: "Couldn't find the user key")
            
        }
        performUIUpdatesOnMain {                //brings the map view controller on screen
            let controller =
                self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func setUIEnabled (enabled : Bool) {
        performUIUpdatesOnMain {
            self.loginBtn.isEnabled = enabled
            self.emailTF.isEnabled = enabled
            self.passwordTF.isEnabled = enabled
            
            if enabled{
                self.loginBtn.alpha = 1.0
                self.loginBtn.setTitle("Login", for: .normal)
            }else{
                self.loginBtn.alpha = 0.5
                self.loginBtn.setTitle("Logging In", for: .disabled)
            }
            
        }
    }
    
    @IBAction func signUp(_ sender: Any) {          
        UIApplication.shared.open(URL(string: UdacityAPIClient.UdacityAPIConstants.signUpURL)!, options: [:], completionHandler: nil)
    }
}




extension LoginViewController : UITextFieldDelegate{
    func setDelegate( _ textfield: UITextField){
        textfield.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow( notification: Notification){             //shifts the view when keyboard appears
        if !keyboardOnScreen{
            view.frame.origin.y -= keyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide( notification: Notification){             //brings the back to normal view when keyboard disappears
        if keyboardOnScreen{
            view.frame.origin.y += keyboardHeight(notification: notification)
            view.frame.origin.y = 0
        }
    }
    
    func keyboardDidShow(notification: Notification){
        keyboardOnScreen = true
    }
    
    func keyboardDidHide( notification: Notification){
        keyboardOnScreen = false
    }
    
    private func keyboardHeight( notification: Notification) -> CGFloat{                //measures the keyboard size to adjust the view accordingly
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToNotification( notification : NSNotification.Name, selector: Selector){                  //subscribe to notifications
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
}

extension UIViewController{
    func displayAlert(error: String?){     
        performUIUpdatesOnMain {
            let alertController = UIAlertController()
            alertController.title = "Error"
            alertController.message = error
            let alertAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

