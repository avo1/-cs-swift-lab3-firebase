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

    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let name = nameField.text ?? ""
        if name.trimmingCharacters(in: .whitespaces).characters.count == 0 {
            self.showAlert(title: "Empty username", content: "Please enter an username")
            return
        }
        
        FIRAuth.auth()!.signInAnonymously(completion: { (user, error) in
            if error == nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.showAlert(title: "Login error", content: (error?.localizedDescription)!)
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as! UINavigationController
        let channelsVC = navVC.viewControllers.first as! ChatViewController
        channelsVC.senderName = nameField.text!
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
