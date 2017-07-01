//
//  mapViewController.swift
//  hackNight
//
//  Created by Marco Riccio on 01/07/17.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import UIKit
import MapKit

class mapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var customMap: MKMapView!
    
    var position: CLLocationManager!
    var userPosition: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.customMap.delegate = self
        self.position = CLLocationManager()
        
        self.customMap.delegate = self
        
        position.delegate = self
        position.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        position.requestWhenInUseAuthorization()
        position.startUpdatingLocation()
        
        addAPin("Via di Miano,1, Napoli")
        
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        self.userPosition = userLocation.coordinate
        
        print("posizione aggiornata - lat: \(userLocation.coordinate.latitude) long: \(userLocation.coordinate.longitude)")
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        
        let region = MKCoordinateRegion(center: userPosition, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
        leftImage.image = UIImage(named: "image.jpg")
        
        
        let chatButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let chatImage = UIImage(named: "nuvola.png")
        chatButton.setBackgroundImage(chatImage, for: UIControlState.normal)
        
        view.leftCalloutAccessoryView = leftImage
        view.rightCalloutAccessoryView = chatButton
        
    }
    
    
    func addAPin(_ address: String) {
        
        let addressToPin = CLGeocoder()
        
        addressToPin.geocodeAddressString(address) { (placemarks, error) in
            
            if let placemarks = placemarks {
                let myPlc = placemarks[0]
                let annotationToAdd = MKPointAnnotation()
                
                annotationToAdd.title = "L'opera di Roberta"
                annotationToAdd.subtitle = "Museo di Capodimonte"
                annotationToAdd.coordinate = (myPlc.location?.coordinate)!
                
                self.customMap.showAnnotations([annotationToAdd], animated: true)
            }
        }
    }
}
