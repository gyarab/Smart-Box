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
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        NotificationCenter.default.post(name: BoxDetailViewController.cancelDetailAction, object: nil)
    }
    @IBAction func directionButtonTapped(_ sender: Any) {
        print("directons button tapped")
        transferToMaps()
    }
    @IBAction func OpenCloseButtonTapped(_ sender: Any) {
        print("open button tapped")
        //open box process
    }
    
    var index: Int?
    let boxes = UserController.shared.getBoxes()
    static let cancelDetailAction = Notification.Name("BoxDetailViewController.cancelTapped")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(initPanel), name: BoxListViewController.tableCellAction, object: nil)
        print("observer added")
        // Do any additional setup after loading the view.
    }
    
    @objc func initPanel() {
        index = BoxListViewController.boxChosen
        if let index = index {
            nameLabel.text = boxes[index].name
            locationLabel.text = String(boxes[index].id)
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
