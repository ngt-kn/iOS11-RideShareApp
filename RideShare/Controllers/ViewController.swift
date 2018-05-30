//
//  ViewController.swift
//  RideShare
//
//  Created by Kenneth Nagata on 5/29/18.
//  Copyright © 2018 Kenneth Nagata. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    
    var signUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func logInButtonPressed(_ sender: UIButton) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            displayAlert(title: "Missing Information", message: "Please enter a valid email or password")
        } else {
            if let email = emailTextField.text, let password = passwordTextField.text {
                if signUpMode {
                    // sign up
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                        } else {
                            if self.riderDriverSwitch.isOn{
                                // Driver
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Driver"
                                req?.commitChanges(completion: nil)
                                self.performSegue(withIdentifier: "driverSegue", sender: nil)                                
                            } else {
                                // Rider
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Rider"
                                req?.commitChanges(completion: nil)
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }                 
                        }
                    }
                } else {
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                        } else {
                            print("log in success")
                            
                            if user?.user.displayName == "Driver" {
                                // driver
                                print("driver")
                                self.performSegue(withIdentifier: "driverSegue", sender: nil)
                            } else {
                                // rider
                                print("rider")
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
  
                        }
                    }
                }
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectionButtonPressed(_ sender: UIButton) {
        if signUpMode {
            logInButton.setTitle("Log In", for: .normal)
            selectionButton.setTitle("Switch to Sign Up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signUpMode = false
        } else {
            logInButton.setTitle("Sign Up", for: .normal)
            selectionButton.setTitle("Switch to Log In", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signUpMode = true
        }
    }

}

