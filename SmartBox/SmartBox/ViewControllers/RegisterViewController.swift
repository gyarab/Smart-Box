//
//  RegisterViewController.swift
//  SmartBox
//
//  Created by Vlada on 18/02/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        let previousController = self.presentingViewController
        
        if UserController.offlineMode == false {
            if let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text {
                UserController.shared.registerUser(email: email, password: password, name: name) { (user) in
                    DispatchQueue.main.async {
                        if let user = user {
                            UserController.shared.user = user
                            print("connection successfull")
                            self.dismiss(animated: true) {
                                previousController!.performSegue(withIdentifier: "loginSeque", sender: nil)
                            }
                        } else {
                            print("connection failed")
                        }
                    }
                }
            }
        } else {
            UserController.shared.fetchTestData()
            if let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text {
                UserController.shared.user!.name = name
                UserController.shared.user!.email = email
                UserController.shared.user!.password = password
            }
            dismiss(animated: true) {
                previousController!.performSegue(withIdentifier: "loginSeque", sender: nil)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        updateUI()
    }
    
    func updateUI() {
        registerButton.backgroundColor = .white
        registerButton.layer.cornerRadius = 10
        registerButton.layer.shadowColor = UIColor.black.cgColor
        registerButton.layer.shadowOpacity = 0.15
        registerButton.layer.shadowOffset = .zero
        registerButton.layer.shadowRadius = 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
