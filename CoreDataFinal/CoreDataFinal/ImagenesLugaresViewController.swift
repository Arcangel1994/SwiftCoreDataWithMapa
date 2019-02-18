//
//  ImagenesLugaresViewController.swift
//  CoreDataFinal
//
//  Created by Raúl Torres on 11/26/18.
//  Copyright © 2018 ISA. All rights reserved.
//

import UIKit
import CoreData

class ImagenesLugaresViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func conexion() -> NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }

    var imagenLugar: Lugares!
    var id: Int16!
    var imagen: UIImage!
    var imagenes : [Imagenes] = []
    @IBOutlet weak var collecion: UICollectionView!
    
    var refrescar: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collecion.delegate = self
        collecion.dataSource = self

        self.title = imagenLugar.nombre
        
        id = imagenLugar.id
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(accionCamara))
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        let itemSize = UIScreen.main.bounds.width/3 - 3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        
        collecion.collectionViewLayout = layout
        
        llamarImagenes()
        
        refrescar = UIRefreshControl()
        collecion.alwaysBounceVertical = true
        refrescar.tintColor = UIColor.green
        refrescar.addTarget(self, action: #selector(recargarDatos), for: .valueChanged)
        collecion.addSubview(refrescar)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        llamarImagenes()
        collecion.reloadData()
        
    }
    
    @objc func accionCamara() {
        
        let alerta = UIAlertController(title: "Tomar foto", message: "Camara/Galleria", preferredStyle: .actionSheet)
        
        let accionCamara = UIAlertAction(title: "Camara", style: .default) { (action) in
            self.tomarFotografia()
        }
        
        let accionGalleria = UIAlertAction(title: "Galeria", style: .default) { (action) in
            self.entrarGalleria()
        }
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
    
        alerta.addAction(accionCamara)
        alerta.addAction(accionGalleria)
        alerta.addAction(accionCancelar)
        
        present(alerta, animated: true)
        
    }//Fin accion of Camara

    func tomarFotografia(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func entrarGalleria(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imagenTomada = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        imagen = imagenTomada
        
        let contexto = conexion()
        let entityImagenes = NSEntityDescription.insertNewObject(forEntityName: "Imagenes", into: contexto) as! Imagenes
        
        let uuid = UUID()
        entityImagenes.id = uuid
        entityImagenes.id_lugares = id
        let imagenFinal = imagen.pngData() as Data?
        entityImagenes.imagenes = imagenFinal
    
        imagenLugar.mutableSetValue(forKey: "imagenes").add(entityImagenes)
        
        do{
            try contexto.save()
            self.llamarImagenes()
            self.collecion.reloadData()
            dismiss(animated: true, completion: nil)
            print("Guardado")
        }catch let error as NSError{
            print("Error al guardar un nuevo lugar",error)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagenes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collecion.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImagenCollectionViewCell
        
        let imagen = imagenes[indexPath.row]
        
        if let imagen = imagen.imagenes{
            cell.imagen.image = UIImage(data: imagen as Data )
        }
        
        return cell
        
    }
    
    func llamarImagenes(){
        let contexto = conexion()
        let fetchRequest : NSFetchRequest<Imagenes> = Imagenes.fetchRequest()
        
        let idLugar = String(id)
        fetchRequest.predicate = NSPredicate(format: "id_lugares == %@", idLugar)
        
        do{
            imagenes = try contexto.fetch(fetchRequest)
        }catch let error as NSError{
            print("No se pudo traer las imagenes", error)
        }
        
    }
    
    @objc func recargarDatos(){
        llamarImagenes()
        collecion.reloadData()
        stop()
    }
    
    func stop(){
        refrescar.endRefreshing()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "imagen", sender: indexPath)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imagen"{
            let id = sender as! NSIndexPath
            let fila = imagenes[id.row]
            let destino = segue.destination as! ImagenVistaViewController
            
            destino.imagenLugar = fila
            
        }
    }
    
}
