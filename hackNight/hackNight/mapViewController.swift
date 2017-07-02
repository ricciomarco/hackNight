//
//  mapViewController.swift
//  hackNight
//
//  Created by Marco Riccio on 01/07/17.
//  Copyright © 2017 Marco Riccio. All rights reserved.
//

import UIKit
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var image: UIImage!
}

class mapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var shadowView2: UIView?

    @IBOutlet weak var customMap: MKMapView!
    
    var position: CLLocationManager!
    var userPosition: CLLocationCoordinate2D!
    var firstUpdatePosition = true
    
    @IBAction func donePressed(b:UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.customMap.delegate = self
        self.position = CLLocationManager()
        
        let color = UIColor(colorLiteralRed: 201/255.0, green: 116/255.0, blue: 28/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = color
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : color]
        
        position.delegate = self
        position.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        position.requestWhenInUseAuthorization()
        position.startUpdatingLocation()
        
        shadowView2 = UIView(frame: CGRect(x: 0, y: 63, width: self.view.frame.size.width, height: 1))
        self.view.addSubview(shadowView2!)
        self.view.bringSubview(toFront: shadowView2!)
        shadowView2?.backgroundColor = UIColor.red
        shadowView2?.layer.shadowColor = UIColor.black.cgColor
        shadowView2?.layer.shadowOpacity = 1.0
        shadowView2?.layer.shadowRadius = 4
        shadowView2?.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView2?.layer.masksToBounds = false
        
        self.customMap.showsUserLocation = true

        var arrayAnnotations = Array<MKPointAnnotation>()
        
        for friend in AppManager.sharedManager.friendsList {
            
            print("_____ANNOTATION")
            let annotationToAdd = MKPointAnnotation()
            
            annotationToAdd.title = friend.name
            annotationToAdd.subtitle = friend.locationName
            annotationToAdd.coordinate = friend.location.coordinate
            
            arrayAnnotations.append(annotationToAdd)
            self.customMap.addAnnotation(annotationToAdd)
        }
        
        //self.customMap.showAnnotations(arrayAnnotations, animated: true)

        
    }
    
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if firstUpdatePosition {
            self.userPosition = userLocation.coordinate
            
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            
            let region = MKCoordinateRegion(center: userPosition, span: span)
            
            mapView.setRegion(region, animated: true)
            
            firstUpdatePosition = false
        }
        
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let friend = AppManager.sharedManager.friend(named: ((view.annotation?.title)!)!) {
            let leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
            leftImage.image = friend.image
            
            if AppManager.sharedManager.userIsCloseTo(location: friend.location, maxDistance: 100) {
                let chatButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                let chatImage = UIImage(named: "nuvola.png")
                chatButton.setBackgroundImage(chatImage, for: UIControlState.normal)
                chatButton.accessibilityValue = friend.ID
                
                chatButton.addTarget(self, action: #selector(chatButtonPressed(sender:)), for: UIControlEvents.touchUpInside)
                view.rightCalloutAccessoryView = chatButton
            } else {
                let directionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                let directionImage = UIImage(named: "Route")
                directionButton.setBackgroundImage(directionImage, for: UIControlState.normal)
                directionButton.accessibilityElements = [friend]
                
                directionButton.addTarget(self, action: #selector(directionButtonPressed(sender:)), for: UIControlEvents.touchUpInside)
                view.rightCalloutAccessoryView = directionButton
            }
            

            
            view.leftCalloutAccessoryView = leftImage
        }
        
        
        
    }
    
    func directionButtonPressed(sender: UIButton) {
        let friend = sender.accessibilityElements?.first as! Friend
        
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = friend.location.coordinate
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = friend.name
        mapItem.openInMaps(launchOptions: options)
    }
    
    func chatButtonPressed(sender: UIButton) {
        AppManager.sharedManager.openConversationByBotID = sender.accessibilityValue!
        self.dismiss(animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        print("delegate called")
        
//        if !(annotation is CustomPointAnnotation) {
//            return nil
//        }
        
        if let friend = AppManager.sharedManager.friend(named: annotation.title!!) {
            let reuseId = "test"
            
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                anView?.canShowCallout = true
            }
            else {
                anView?.annotation = annotation
            }
            
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            
            
            anView?.image = UIImage(named: "statue")
            
            return anView
        }
        return nil
    }
}
