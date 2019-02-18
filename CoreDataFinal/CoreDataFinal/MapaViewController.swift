//
//  MapaViewController.swift
//  CoreDataFinal
//
//  Created by Raúl Torres on 11/26/18.
//  Copyright © 2018 ISA. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapaViewController: UIViewController, CLLocationManagerDelegate {

    var coordLugares: Lugares!
    var manager = CLLocationManager()
    var latMap : CLLocationDegrees!
    var longMap : CLLocationDegrees!
    
    @IBOutlet weak var mapa: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    
        latMap = coordLugares.latitud
        longMap = coordLugares.longitud
        
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let localizacion = CLLocationCoordinate2DMake(latMap, longMap)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: localizacion, span: span)
        self.mapa.setRegion(region, animated: true)
        
        let anotacion = MKPointAnnotation()
        anotacion.coordinate = (localizacion)
        
        anotacion.title = coordLugares.nombre
        anotacion.subtitle = coordLugares.descripcion
        mapa.addAnnotation(anotacion)
        mapa.selectAnnotation(anotacion, animated: true)
        
    }
    

}
