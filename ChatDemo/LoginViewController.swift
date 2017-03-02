//
//  LoginViewController.swift
//  ChatDemo
//
//  Created by Dave Vo on 2/25/17.
//  Copyright © 2017 DaveVo. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        FIRAuth.auth()!.addStateDidChangeListener { (auth, user) in
            if user != nil {
                print("User \(user?.email) logged in")
                self.emailField.text = user?.email!
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let email = emailField.text ?? ""
        let pass = passwordField.text ?? ""
        
        if email.trimmingCharacters(in: .whitespaces).characters.count == 0 {
            self.showAlert(title: "Empty email", content: "Please enter an email")
            return
        }
        
        FIRAuth.auth()!.signIn(withEmail: email, password: pass) { (user: FIRUser?, error: Error?) in
            if error == nil {
                if let _ = user {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            } else {
                self.showAlert(title: "Login error", content: (error?.localizedDescription)!)
            }
        }
        /*
        FIRAuth.auth()!.signInAnonymously(completion: { (user, error) in
            if error == nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.showAlert(title: "Login error", content: (error?.localizedDescription)!)
            }
        })
 */
    }

    @IBAction func onSignup(_ sender: UIButton) {
        let email = emailField.text ?? ""
        let pass = passwordField.text ?? ""
        
        if email.trimmingCharacters(in: .whitespaces).characters.count == 0 {
            self.showAlert(title: "Empty email", content: "Please enter an email")
            return
        }
        
        FIRAuth.auth()!.createUser(withEmail: email, password: pass, completion: { (user: FIRUser?, error: Error?) in
            if error == nil {
                print("You have successfully signed up")
                self.showAlert(title: "Signup successfully", content: "You will be logged in now")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.showAlert(title: "Signup error", content: (error?.localizedDescription)!)
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as! UINavigationController
        let chatVC = navVC.viewControllers.first as! ChatViewController
        chatVC.currentUser = FIRAuth.auth()?.currentUser
        chatVC.senderId = FIRAuth.auth()?.currentUser?.uid
    }

}

extension UIViewController {
    func showAlert(title: String, content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
