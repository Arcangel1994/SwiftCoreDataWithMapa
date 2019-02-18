//
//  MapaFullViewController.swift
//  CoreDataFinal
//
//  Created by Raúl Torres on 11/26/18.
//  Copyright © 2018 ISA. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapaFullViewController: UIViewController {
    
    @IBOutlet weak var mapa: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let anotacion = traerCoordenadas() {
           mapa.addAnnotations(anotacion)
        }
    
    }
    
    func traerCoordenadas() -> [MKAnnotation]?{
        
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest : NSFetchRequest<Lugares> = Lugares.fetchRequest()
        
        do{
            let localizaciones = try contexto.fetch(fetchRequest)
            var anotacion = [MKAnnotation]()
            
            for item in localizaciones {
                let newAnotacion = MKPointAnnotation()
                newAnotacion.coordinate.latitude = item.latitud
                newAnotacion.coordinate.longitude = item.longitud
                newAnotacion.title = item.nombre
                newAnotacion.subtitle = item.descripcion
                anotacion.append(newAnotacion)
                
            }
            return anotacion
        }catch let error as NSError{
            print("",error)
        }
        
        return nil
        
    }
    
    

}
