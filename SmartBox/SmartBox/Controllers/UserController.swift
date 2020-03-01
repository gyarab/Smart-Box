//
//  UserController.swift
//  SmartBox
//
//  Created by Vlada on 08/01/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import Foundation

class UserController {
    
    var user: User?
    var nearbyBoxes: [Box] = []
    static let shared = UserController()
    let baseURL = URL(string: "https://polar-plateau-63565.herokuapp.com/")!
    static var offlineMode = true
    static var token: String?
    
    func loginUser(email: String, password: String, completion: @escaping (User?) -> Void) {
        let orderURL = baseURL.appendingPathComponent("auth/token/login") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: [String: String] = ["email": email,
                                      "password": password]
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
                if let data = data, let token = try? jsonDecoder.decode(String.self, from: data) {
                    UserController.token = token
                    self.getUser { (user) in
                        completion(user)
                    }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func logoutUser() {
        let orderURL = baseURL.appendingPathComponent("auth/token/logout") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("Token \(UserController.token!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    func getUser(completion: @escaping (User?) -> Void) {
        let orderURL = baseURL.appendingPathComponent("auth/token/login") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("Authorization", forHTTPHeaderField: UserController.token ?? "")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
                if let data = data, let user = try? jsonDecoder.decode(User.self, from: data) {
                    completion(user)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func registerUser(email: String, password: String, name: String, completion: @escaping (User?) -> Void) {
        let orderURL = baseURL.appendingPathComponent("auth/users/") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: [String: String] = ["name": name,
                                      "email": email,
                                      "password": password]
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let _ = try? jsonDecoder.decode(Bool.self, from: data) {
                self.loginUser(email: email, password: password) { (user) in
                    completion(user)
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func updateUser(user: User, completion: @escaping (User?) -> Void) {
        let orderURL = baseURL.appendingPathComponent("auth/users/\(user.id)/update") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: User = user
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
                if let data = data, let user = try? jsonDecoder.decode(User.self, from: data) {
                completion(user)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func unlockBox(boxID: Int) {
        let orderURL = baseURL.appendingPathComponent("box/\(boxID)/unlock") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("Token \(UserController.token!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    func borrowBox(boxID: Int) {
        let orderURL = baseURL.appendingPathComponent("box/\(boxID)/borrow") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("Token \(UserController.token!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    func returnBox(boxID: Int) {
        let orderURL = baseURL.appendingPathComponent("box/\(boxID)/return") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("Token \(UserController.token!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    func getNearby() {
        let orderURL = baseURL.appendingPathComponent("boxes")
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        
        //navazani spojeni se serverem - konfigurace + ziskani dat
        let task = URLSession.shared.dataTask(with: orderURL) { (data, responce, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let boxes = try? jsonDecoder.decode([Box].self, from: data) {
                UserController.shared.nearbyBoxes = boxes
            }
        }
        //zahajeni spojeni
        task.resume()
    }
    
    func getBoxes() -> [Box] {
        var all: [Box] = self.user?.Boxes ?? []
        
        for box in nearbyBoxes {
            all.removeAll{$0.id == box.id}
            all.append(box)
        }
        all.reverse()
        return all
    }
    
    func fetchTestData() {
        self.user = User(id: 1,
                         name: "Vladimir Ekart",
                         email: "vladimir.ekart@email.cz",
                         password: "MyPassword",
                         Boxes: [Box(possition: Possition(lattitude: 50.0998, longtitude: 14.3601), locked: true, name: "SmartBox", id: 1),
                                 Box(possition: Possition(lattitude: 50.0510, longtitude: 14.3336), locked: true, name: "SmartBox 2", id: 2)],
                                 admin: true)
        self.nearbyBoxes = [Box(possition: Possition(lattitude: 50.0751, longtitude: 14.4375), locked: false, name: "MyBox", id: 3),
                            Box(possition: Possition(lattitude: 50.0651, longtitude: 14.4000), locked: false, name: "PragueBox", id: 4),
                            Box(possition: Possition(lattitude: 50.0998, longtitude: 14.3601), locked: true, name: "SmartBox", id: 1),
                            Box(possition: Possition(lattitude: 50.0510, longtitude: 14.3336), locked: true, name: "SmartBox 2", id: 2)]
    }
}
