//
//  MapViewController.swift
//  SmartBox
//
//  Created by Vlada on 15/01/2020.
//  Copyright © 2020 Vlada. All rights reserved.
//

import UIKit
import MapKit
import FloatingPanel

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, FloatingPanelControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bcUserView: UIView!
    @IBAction func userButtonAction(_ sender: Any) {
        defShowPanel(userDetailPanelVC)
    }
    
    let locationManager = CLLocationManager()
    var annotations: [MKPointAnnotation] = []
    
    var listPanelVC: FloatingPanelController! = FloatingPanelController()
    var boxDetailPanelVC: FloatingPanelController! = FloatingPanelController()
    var userDetailPanelVC: FloatingPanelController! = FloatingPanelController()
    lazy var panels: [FloatingPanelController: UIViewController] = [listPanelVC: BoxListViewController(),
                                                                    boxDetailPanelVC: BoxDetailViewController(),
                                                                    userDetailPanelVC: UserDetailViewController()]
    var panelQuery: [FloatingPanelController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(highlightBox), name: BoxListViewController.tableCellAction, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unhighlightBox), name: BoxDetailViewController.cancelDetailAction, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideUserDetail), name: UserDetailViewController.cancelDetailAction, object: nil)

        
        bcUserView.layer.cornerRadius = 10
        bcUserView.alpha = 0.90
        bcUserView.layer.shadowColor = UIColor.black.cgColor
        bcUserView.layer.shadowOpacity = 0.2
        bcUserView.layer.shadowOffset = .zero
        bcUserView.layer.shadowRadius = 7
        
        locationServicesCheck()
        centerMap()
        
        print("boxes map: \(UserController.shared.getBoxes())")
        showBoxes()
        
        addPanels()
        defShowPanel(listPanelVC)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Remove the views managed by the `FloatingPanelController` object from self.view.
        //listPanelVC.removePanelFromParent(animated: false)
    }
    
    @objc func hideUserDetail() {
        defHidePanel(userDetailPanelVC)
    }
    
    // MARK: - Floating panels
    
    func addPanels() {
        for panel in panels {
            panel.key.delegate = self // Optional

            // Set a content view controller.
            let contentVC = panel.value
            panel.key.set(contentViewController: contentVC)

            // Track a scroll view(or the siblings) in the content view controller.
            
            if panel.key == listPanelVC {
                let content = panel.value as! BoxListViewController
                panel.key.track(scrollView: content.tableView)
                print("tracking list")
            } else if panel.key == userDetailPanelVC {
                let content = panel.value as! UserDetailViewController
                panel.key.track(scrollView: content.scrollView)
                print("tracking user")
            }
            
            // Add and show the views managed by the `FloatingPanelController` object to self.view.
            //panel.key.addPanel(toParent: self)
        }
    }
    
    func showPanel(_ panel: FloatingPanelController) {
        self.view.addSubview(panel.view)

        panel.view.frame = self.view.bounds

        panel.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          panel.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
          panel.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0),
          panel.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0),
          panel.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
        ])

        self.addChild(panel)

        panel.surfaceView.cornerRadius = 15.0
        panel.surfaceView.alpha = 0.99
        
        panel.show(animated: true) {
            panel.didMove(toParent: self)
        }
    }

    func hidePanel(_ panel: FloatingPanelController) {
        panel.willMove(toParent: nil)
            
        // Hide the floating panel.
        panel.hide(animated: true) {
            // Remove the floating panel view from your controller's view.
            panel.view.removeFromSuperview()
            // Remove the floating panel controller from the controller hierarchy.
            panel.removeFromParent()
        }
    }
    
    func defHidePanel(_ panel: FloatingPanelController) {
        hidePanel(panel)
        panelQuery.removeLast()
        print("query remove: \(panelQuery.count)")
        if let lPanel = panelQuery.last { showPanel(lPanel) }
    }
    
    func defShowPanel(_ panel: FloatingPanelController) {
        showPanel(panel)
        if let lPanel = panelQuery.last { hidePanel(lPanel) }
        panelQuery.append(panel)
        print("query add: \(panelQuery.count)")
    }
    
    // MARK: - Map
    
    func centerMap() {
        guard let location = self.locationManager.location?.coordinate else { return }
        mapView.setCenter(location, animated: true)
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
    }
    
    func moveToBox() {
        let boxChosen = BoxListViewController.boxChosen
        let boxLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(boxChosen!.lattitude), longitude: CLLocationDegrees(boxChosen!.longtitude))
        mapView.setCenter(boxLocation, animated: true)
        let region = MKCoordinateRegion(center: boxLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    @objc func highlightBox() {
        if let boxChosen = BoxListViewController.boxChosen {
            var index = 0
            for box in UserController.shared.getBoxes() {
                if box.id == boxChosen.id {
                    mapView.selectAnnotation(annotations[index], animated: true)
                    return
                }
                index += 1
            }
        }
    }
    
    @objc func unhighlightBox() {
        if let boxChosen = BoxListViewController.boxChosen {
            var index = 0
            for box in UserController.shared.getBoxes() {
                if box.id == boxChosen.id {
                    mapView.deselectAnnotation(annotations[index], animated: true)
                    self.showBoxes()
                    return
                }
                index += 1
            }
        }
    }
    
    func locationServicesCheck() {
        if CLLocationManager.locationServicesEnabled() {
          authorizationStatusCheck()
        } else {
        }
    }
    
    func authorizationStatusCheck() {
      switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
        break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
            break
        case .restricted:
            break
        case .authorizedAlways: break
      @unknown default:
        break
        }
    }
    
    func showBoxes() {
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
        print(annotations)
        for box in UserController.shared.getBoxes() {
            let annotation = MKPointAnnotation()
            annotation.title = box.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(box.lattitude), longitude: CLLocationDegrees(box.longtitude))
            self.annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        print("map boxes reloaded")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for annotation in annotations {
            if annotation.coordinate.latitude == view.annotation?.coordinate.latitude && annotation.coordinate.longitude == view.annotation?.coordinate.longitude {
                for box in UserController.shared.getBoxes() {
                    if box.name == annotation.title && box.lattitude == annotation.coordinate.latitude && box.longtitude == annotation.coordinate.longitude {
                        BoxListViewController.boxChosen = box
                    }
                }
            }
        }
        moveToBox()
        NotificationCenter.default.post(name: BoxListViewController.tableCellAction, object: nil)
        defShowPanel(boxDetailPanelVC)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        centerMap()
        defHidePanel(boxDetailPanelVC)
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
