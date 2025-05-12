//
//  ViewController.swift
//  Mascotas
//
//  Created by Ángel González on 26/04/25.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    var laMascota : Mascota!
    var detalle: DetailView!
    var pickerView: UIPickerView!
    var toolBar: UIToolbar!
    
    var responsables: [Responsable] = []
    var nombresResponsables: [String] = []
    var responsableSeleccionado: Responsable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        detalle = DetailView(frame:view.bounds.insetBy(dx: 40, dy: 40))
        view.addSubview(detalle)
        configurarPicker()
        responsables = obtenerResponsables()
        nombresResponsables = responsables.map { $0.nombre ?? "Sin nombre" }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: - Obtener y presentar la información de la mascota
        detalle.txtNombre.text = laMascota.nombre ?? ""
        detalle.txtGenero.text = laMascota.genero ?? ""
        detalle.txtTipo.text = laMascota.tipo ?? ""
        detalle.txtEdad.text = "\(laMascota.edad)"
        detalle.btnDelete.addTarget(self, action:#selector(borrar), for:.touchUpInside)
        
        // TODO: - Si la mascota ya tiene un responsable, ocultar el botón
        if laMascota.responsable != nil {
            detalle.btnAdopt.isHidden = true
            let ownerInfo = ((laMascota.responsable?.nombre) ?? "") + " " + ((laMascota.responsable?.apellido_paterno) ?? "")
            detalle.lblResponsable.isHidden = false
            detalle.lblResponsable.frame.size.height = 50
            detalle.lblResponsable.text = "Dueño: \(ownerInfo)"
            detalle.lblResponsable.sizeToFit()
        }
        else {
            detalle.btnAdopt.isHidden = false
            detalle.lblResponsable.isHidden = true
            detalle.lblResponsable.frame.size.height = 0
            detalle.btnAdopt.addTarget(self, action: #selector(mostrarPicker), for: .touchUpInside)
        }
    }
    
    @objc
    func borrar () {
        let ac = UIAlertController(title: "CONFIRME", message:"Desea borrar este registro?", preferredStyle: .alert)
        let action = UIAlertAction(title: "SI", style: .destructive) {
            alertaction in
            DataManager.shared.borrar(objeto:self.laMascota)
            // si se implementa con navigation controller:
            self.navigationController?.popViewController(animated: true)
            // self.dismiss(animated: true)
        }
        let action2 = UIAlertAction(title: "NO", style:.cancel)
        ac.addAction(action)
        ac.addAction(action2)
        self.present(ac, animated: true)

    }
    
    @objc
    func mostrarPicker() {
        // Posicionamos el picker en la parte inferior
        pickerView.frame = CGRect(x: 0, y: view.frame.height - 200, width: view.frame.width, height: 200)
        toolBar.frame = CGRect(x: 0, y: view.frame.height - 240, width: view.frame.width, height: 40)
        
        view.addSubview(toolBar)
        view.addSubview(pickerView)
    }
    
    @objc
    func donePicking() {
        pickerView.removeFromSuperview()
        toolBar.removeFromSuperview()
    }
    
    func configurarPicker() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .systemGray6
        
        toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Hecho", style: .done, target: self, action: #selector(donePicking))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
    }
    
    func obtenerResponsables() -> [Responsable] {
        let contexto = DataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Responsable> = Responsable.fetchRequest()
        
        do {
            let responsables = try contexto.fetch(fetchRequest)
            return responsables
        } catch {
            print("Error al obtener responsables: \(error.localizedDescription)")
            return []
        }
    }
}

extension DetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nombresResponsables.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nombresResponsables[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Al seleccionar un responsable, asignamos el objeto `Responsable` correspondiente
        responsableSeleccionado = responsables[row]
    }
}

