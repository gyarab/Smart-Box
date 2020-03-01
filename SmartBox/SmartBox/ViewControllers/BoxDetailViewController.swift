//
//  BoxDetailViewController.swift
//  SmartBox
//
//  Created by Vlada on 22/01/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import UIKit
import MapKit

class BoxDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var lockButtonView: UIView!
    @IBOutlet var buttonViews: [UIView]!
    @IBOutlet weak var unlockBcView: UIView!
    @IBOutlet weak var borrowLabel: UILabel!
    @IBOutlet weak var borrowIcon: UIImageView!
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        NotificationCenter.default.post(name: BoxDetailViewController.cancelDetailAction, object: nil)
    }
    @IBAction func directionButtonTapped(_ sender: Any) {
        print("directons button tapped")
        transferToMaps()
    }
    @IBAction func unlockButtonTapped(_ sender: Any) {
        print("open button tapped")
        //open box process
    }
    @IBAction func borrowButtonTapped(_ sender: Any) {
        if UserController.offlineMode == false {
            if myBox() {
                UserController.shared.returnBox(boxID: box!.id)
            } else {
                UserController.shared.borrowBox(boxID: box!.id)
            }
            UserController.shared.getUser { (user) in
                UserController.shared.user = user
            }
        } else {
            if myBox() {
                UserController.shared.nearbyBoxes.removeAll{$0.id == self.box!.id}
                box!.locked = false
                UserController.shared.nearbyBoxes.append(box!)
                UserController.shared.user?.Boxes.removeAll{$0.id == self.box!.id}
            } else {
                UserController.shared.nearbyBoxes.removeAll{$0.id == self.box!.id}
                box!.locked = true
                UserController.shared.nearbyBoxes.append(box!)
                UserController.shared.user?.Boxes.append(self.box!)
            }
        }
        print("new index \(index!),\n all boxes \(UserController.shared.getBoxes())")
        updateUI()
    }
    
    var index: Int?
    let boxes = UserController.shared.getBoxes()
    static let cancelDetailAction = Notification.Name("BoxDetailViewController.cancelTapped")
    var box: Box?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(initPanel), name: BoxListViewController.tableCellAction, object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func initPanel() {
        index = BoxListViewController.boxChosen
        box = boxes[index!]
        nameLabel.text = box!.name
        locationLabel.text = String(box!.id)
        
        lockButtonView.layer.cornerRadius = lockButtonView.bounds.width / 2
        lockButtonView.layer.shadowPath = UIBezierPath(roundedRect: lockButtonView.bounds, cornerRadius: lockButtonView.bounds.width / 2).cgPath
        lockButtonView.layer.shadowColor = UIColor.black.cgColor
        lockButtonView.layer.shadowOpacity = 0.15
        lockButtonView.layer.shadowOffset = .zero
        lockButtonView.layer.shadowRadius = 10
        lockButtonView.backgroundColor = .white

        
        for view in buttonViews {
            view.backgroundColor = .white
            view.layer.cornerRadius = 10
            view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.15
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = 10
        }
        updateUI()
    }
    
    func updateUI() {
        if myBox() {
            borrowLabel.text = "Return"
            unlockBcView.isHidden = false
            borrowIcon.image = UIImage(systemName: "person.crop.circle.badge.minus")
        } else {
            unlockBcView.isHidden = true
            borrowLabel.text = "Borrow"
            borrowIcon.image = UIImage(systemName: "person.crop.circle.badge.plus")
        }
    }
    
    func transferToMaps() {
        guard let index = index else { return }
        let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(boxes[index].possition.lattitude), longitude: CLLocationDegrees(boxes[index].possition.longtitude))
        let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
        
        let placeMark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = boxes[index].name
        mapItem.openInMaps(launchOptions: options)
    }
    
    func myBox() -> Bool {
        if (UserController.shared.user?.Boxes.contains(where: { (box) -> Bool in
            return box.id == self.box!.id
        }))! {
            return true
        }
        return false
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
