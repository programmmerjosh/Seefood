//
//  ViewController.swift
//  SeeFood
//
//  Created by Joshua Van Niekerk on 08/11/2019.
//  Copyright © 2019 Joshua Van Niekerk. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
    
        present(imagePicker, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate      = self
        
        // edit .camera below to .photoLibrary for user to access photo library instead of camera
        imagePicker.sourceType    = .camera
        imagePicker.allowsEditing = false
        
    }
    
    // image picker delegate method(s)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let coreImagePic = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: coreImagePic)
        }
        imagePicker.dismiss(animated: true)
    }
    
    func detect(image: CIImage) {
        
        // where does VNCoreMLModel come from?? Vision framework.
        // it allows one to perform an image analysis request that uses the coreML model to process images
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed.")
        }
        
        // create a vision coreML request
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let result = results.first {
                if result.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.backgroundColor = .green
                } else {
                    self.navigationItem.title = "Not hotdog!"
                    self.navigationController?.navigationBar.backgroundColor = .red
                }
            }
        }
        
        // need an image handler
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("\(error)\nHandler failed to perform request.")
        }
        
    }


}

