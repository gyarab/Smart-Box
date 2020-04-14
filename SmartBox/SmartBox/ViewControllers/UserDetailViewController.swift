//
//  UserDetailViewController.swift
//  SmartBox
//
//  Created by Vlada on 07/02/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet var bcViewCollection: [UIView]!
    @IBOutlet weak var tableBcView: UIView!
    @IBOutlet weak var emailStack: UIStackView!
    @IBOutlet weak var emailEditStack: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordStack: UIStackView!
    @IBOutlet weak var passwordEditStack: UIStackView!
    @IBOutlet weak var currentPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var passwordBcViewCon: NSLayoutConstraint!
    
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        NotificationCenter.default.post(name: UserDetailViewController.cancelDetailAction, object: nil)
    }
    
    /*
    @IBAction func emailEditAction(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.emailStack.alpha = 0
            self.emailEditStack.alpha = 0
        }) { (_) in
            self.emailEditStack.isHidden = false
            self.emailStack.isHidden = true
            UIView.animate(withDuration: 0.5) {
                self.emailEditStack.alpha = 1
            }
        }
    }
    
    @IBAction func emailEditDone(_ sender: Any) {
        emailTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.5, animations: {
            self.emailEditStack.alpha = 0
        }) { (_) in
            self.emailStack.isHidden = false
            self.emailEditStack.isHidden = true
            UIView.animate(withDuration: 0.5) {
                self.emailStack.alpha = 1
            }
        }
        
        guard let newEmail = emailTextField.text else { return }
        if newEmail != "" {
            var updatedUser = user
            updatedUser.email = newEmail
            if UserController.offlineMode == false {
                UserController.shared.updateUser(user: updatedUser) { (newUser) in
                    guard let newUser = newUser else { return }
                    UserController.shared.user = newUser
                }
            } else {
                UserController.shared.user = updatedUser
            }
            user = UserController.shared.user!
            updateUI()
        }
        emailTextField.text = ""
    }
    
    
    @IBAction func passwordEditAction(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.passwordStack.alpha = 0
            self.passwordEditStack.alpha = 0
        }) { (_) in
            self.passwordEditStack.isHidden = false
            self.passwordStack.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.passwordBcViewCon.constant = 100
                self.view.layoutIfNeeded()
            }) { (_) in
                UIView.animate(withDuration: 0.5) {
                    self.passwordEditStack.alpha = 1
                }
            }
        }
    }
    
    @IBAction func passwordEditDone(_ sender: Any) {
        currentPasswordTF.resignFirstResponder()
        newPasswordTF.resignFirstResponder()
        UIView.animate(withDuration: 0.5, animations: {
            self.passwordEditStack.alpha = 0
        }) { (_) in
            self.passwordStack.isHidden = false
            self.passwordEditStack.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.passwordBcViewCon.constant = 50
                self.view.layoutIfNeeded()
            }) { (_) in
                UIView.animate(withDuration: 0.5) {
                    self.passwordStack.alpha = 1
                }
            }
        }
        guard let newPassword = newPasswordTF.text, let oldPassword = currentPasswordTF.text else { return }
        if newPassword != "" && oldPassword == user.password {
            var updatedUser = user
            updatedUser.password = newPassword
            if UserController.offlineMode == false {
                UserController.shared.updateUser(user: updatedUser) { (newUser) in
                    guard let newUser = newUser else { return }
                    UserController.shared.user = newUser
                }
            } else {
                UserController.shared.user = updatedUser
            }
            user = UserController.shared.user!
            print("password updated \(user.password)")
        }
        currentPasswordTF.text = ""
        newPasswordTF.text = ""
    }
    */
    var user: User = UserController.shared.user ?? User(id: 0, name: "Loading User Failed", email: "no email", password: "", Boxes: [])
    let rowHeight = 80
    static let cancelDetailAction = Notification.Name("UserDetailViewController.cancelTapped")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        emailTextField.delegate = self
        currentPasswordTF.delegate = self
        newPasswordTF.delegate = self
        
        let nib = UINib(nibName: "BoxListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "boxListCell")
        updateUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        user = UserController.shared.user!
        updateUI()
        tableView.reloadData()
    }
    
    func updateUI() {
        nameLabel.text = user.name
        emailLabel.text = user.email
        tableViewHeightConstraint.constant = CGFloat(user.Boxes.count*rowHeight-1)
        for view in bcViewCollection {
            view.layer.cornerRadius = 10
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = 10
            view.backgroundColor = .white
        }
        tableView.layer.cornerRadius = 10
        tableBcView.layer.shadowPath = UIBezierPath(rect: CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: CGFloat(user.Boxes.count*rowHeight-1))).cgPath
        tableView.isScrollEnabled = false
    }

    // MARK: - TextField
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (UserController.shared.user?.Boxes.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boxListCell", for: indexPath) as! BoxListCell
        
        let user = UserController.shared.user!
        let box = user.Boxes[indexPath.row]
        
        cell.nameLabel.text = box.name
        cell.distanceLabel.text = String(box.id)
        cell.myBoxSet(box)
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeight)
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
