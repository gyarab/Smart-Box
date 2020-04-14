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
    private var nearbyBoxes: [Box] = []
    private var allBoxes: [Box] = []
    static let shared = UserController()
    private let baseURL = URL(string: "https://polar-plateau-63565.herokuapp.com/")!
    static var offlineMode = false
    private static var token: String?
    
    func registerUser(email: String, password: String, name: String, completion: @escaping (Bool) -> Void) {
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
            if let data = data, let _ = try? jsonDecoder.decode(ComUser.self, from: data) {
                print("register checkpoint")
                self.loginUser(email: email, password: password, completion: { (_) in
                    completion(true)
                })
            } else {
                print("error: \(String(describing: error)) data: \(String(describing: data))")
                completion(false)
            }
        }
        task.resume()
    }
    
    
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let orderURL = baseURL.appendingPathComponent("auth/token/login/") //vytvoreni url
        
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
                if let data = data, let token = try? jsonDecoder.decode(Token.self, from: data) {
                    print("login checkpoint")
                    UserController.token = token.auth_token
                    self.loadAll {
                        completion(true)
                    }
                } else {
                    completion(false)
            }
        }
        task.resume()
    }
    
    
    func loadAll(completion: @escaping () -> Void) {
        self.getNearby { () in
            self.getUser { () in
                self.mergeBoxData()
                completion()
                print("actual user: \(String(describing: self.user))\n boxes nearby: \(self.allBoxes)")
            }
        }
    }
    
    func getNearby(completion: @escaping () -> Void) {
        let orderURL = baseURL.appendingPathComponent("boxes/")
        print("token \(String(describing: UserController.token))")
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue("Token \(UserController.token ?? "")", forHTTPHeaderField: "Authorization")

        
        //navazani spojeni se serverem - konfigurace + ziskani dat
        let task = URLSession.shared.dataTask(with: request) { (data, responce, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let nearbyBoxes = try? jsonDecoder.decode([Box].self, from: data) {
                print("getNearby checkpoint")
                self.nearbyBoxes = nearbyBoxes
                completion()
            }
        }
        //zahajeni spojeni
        task.resume()
    }
    
    func getUser(completion: @escaping () -> Void) {
        let orderURL = baseURL.appendingPathComponent("auth/users/me/") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue("Token \(UserController.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
                if let data = data, let user = try? jsonDecoder.decode(ComUser.self, from: data) {
                    print("getUser checkpoint")
                    self.getMyBoxes { (myBoxes) in
                        self.user = User(id: user.id, name: user.name, email: user.email, password: "", Boxes: myBoxes ?? [])
                        completion()
                    }
            }
        }
        task.resume()
    }
    
    private func getMyBoxes(completion: @escaping ([Box]?) -> Void) {
        let orderURL = baseURL.appendingPathComponent("user/boxes/") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue("Token \(UserController.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let userBoxes = try? jsonDecoder.decode([Box].self, from: data) {
                print("getMyBoxes checkpoint")
                completion(userBoxes)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    private func mergeBoxData() {
        var all: [Box] = self.user?.Boxes ?? []
        
        for box in nearbyBoxes {
            all.removeAll{$0.id == box.id}
            all.append(box)
        }
        all.reverse()
        self.allBoxes = all
    }
    
    /*
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
    
 */
    
    func unlockBox(boxID: Int, competion: @escaping (Bool) -> Void) {
        let orderURL = baseURL.appendingPathComponent("box/\(boxID)/unlock/") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue("Token \(UserController.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let _ = try? jsonDecoder.decode(Stav.self, from: data) {
                print("unlock checkpoint")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.lockBox(boxID: boxID) { (success) in
                        if success {
                            competion(true)
                        } else {
                            competion(false)
                        }
                    }
                }
            } else {
                competion(false)
            }
        }
        
        task.resume()
    }
    
    func lockBox(boxID: Int, competion: @escaping (Bool) -> Void) {
        let orderURL = baseURL.appendingPathComponent("box/\(boxID)/lock/") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue("Token \(UserController.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let _ = try? jsonDecoder.decode(Stav.self, from: data) {
                print("lock checkpoint")
                competion(true)
            } else {
                competion(false)
            }
        }
        
        task.resume()
    }
    
    func borrowBox(boxID: Int, competion: @escaping (Bool) -> Void) {
        let orderURL = baseURL.appendingPathComponent("box/\(boxID)/borrow/") //vytvoreni url
        
        print("url \(orderURL)")
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue("Token \(UserController.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let _ = try? jsonDecoder.decode(Stav.self, from: data) {
                print("borrow checkpoint")
                self.getUser {
                    competion(true)
                }
            } else {
                competion(false)
            }
        }
        
        task.resume()
    }
    
    func returnBox(boxID: Int, competion: @escaping (Bool) -> Void) {
        let orderURL = baseURL.appendingPathComponent("box/\(boxID)/return/") //vytvoreni url
        
        //configurace urlRequest
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue("Token \(UserController.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let _ = try? jsonDecoder.decode(Stav.self, from: data) {
                self.getUser {
                    competion(true)
                }
            } else {
                competion(false)
            }
        }
        
        task.resume()
    }
    
    func getBoxes() -> [Box] {
        return UserController.shared.allBoxes
    }
}
