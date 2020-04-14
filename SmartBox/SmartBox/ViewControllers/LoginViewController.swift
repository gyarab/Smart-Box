//
//  LoginViewController.swift
//  SmartBox
//
//  Created by Vlada on 09/02/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signButton: UIButton!
    
    @IBAction func SignButtonTapped(_ sender: Any) {
        if UserController.offlineMode == false {
            if let email = emailTextField.text, let password = passwordTextField.text {
                UserController.shared.loginUser(email: email, password: password, completion: { (success) in
                    DispatchQueue.main.async {
                        if success {
                            print("connection successfull")
                            self.performSegue(withIdentifier: "loginSeque", sender: nil)
                        }
                    }
                })
            }
        } else {
            //UserController.shared.fetchTestData()
            if emailTextField.text != "" && passwordTextField.text != "" {
                UserController.shared.user!.email = emailTextField.text!
                UserController.shared.user!.password = passwordTextField.text!
            }
            self.performSegue(withIdentifier: "loginSeque", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    func updateUI() {
        signButton.backgroundColor = .white
        signButton.layer.cornerRadius = 10
        signButton.layer.shadowColor = UIColor.black.cgColor
        signButton.layer.shadowOpacity = 0.15
        signButton.layer.shadowOffset = .zero
        signButton.layer.shadowRadius = 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSeque" {
            if let email = emailTextField.text, let password = passwordTextField.text {
                UserController.shared.loginUser(email: email, password: password) { (user) in
                    
                }
            }
        }
    }
    */

}
