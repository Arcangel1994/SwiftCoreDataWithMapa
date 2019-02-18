//
//  AgregarViewController.swift
//  CoreDataFinal
//
//  Created by Raúl Torres on 11/23/18.
//  Copyright © 2018 ISA. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class AgregarViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var descripcion: UITextField!
    @IBOutlet weak var verCoordenadas: UIButton!
    
    var manager = CLLocationManager()
    var latitud : CLLocationDegrees!
    var longitud: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
    }
    
    @IBAction func obtenerCoordenas(_ sender: UIButton) {
        
        self.verCoordenadas.setTitle("Lat: \(latitud!) - Long: \(longitud!)", for: .normal)
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        nombre.resignFirstResponder()
        descripcion.resignFirstResponder()
        
        if let location = locations.first {
            self.latitud = location.coordinate.latitude
            self.longitud = location.coordinate.longitude
        }

    }
    
    
    @IBAction func guardar(_ sender: UIButton) {
        
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let entetyLugares = NSEntityDescription.insertNewObject(forEntityName: "Lugares", into: contexto) as! Lugares
        
        entetyLugares.nombre = nombre.text
        entetyLugares.descripcion = descripcion.text
        entetyLugares.latitud = latitud
        entetyLugares.longitud = longitud
        
        //[SELECT * Lugares ORDER BY id desc limit 1
        let fetchResult : NSFetchRequest<Lugares> = Lugares.fetchRequest()
        let orderById = NSSortDescriptor(key: "id", ascending: false)
        fetchResult.sortDescriptors = [orderById]
        fetchResult.fetchLimit = 1
        
        do {
            let idResult = try contexto.fetch(fetchResult)
            let id = idResult[0].id + 1
            entetyLugares.id = id
            nombre.text =  ""
            descripcion.text = ""
            verCoordenadas.setTitle("Coordenadas", for: .normal)
        } catch let error as NSError{
            print("Error en agregar un nuevo lugar", error)
        }
        
        do {
            try contexto.save()
            print("Guardado lugar")
        } catch let error as NSError {
            print("No se pudo guardar", error)
        }
        
        nombre.resignFirstResponder()
        descripcion.resignFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
