//
//  ViewController.swift
//  SeeFood
//
//  Created by Azis Ramdhan on 17/07/23.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    @IBOutlet weak private var imageView: UIImageView!
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
    }
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

private extension ViewController {
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    func detect(_ image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Load CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process iamge.")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    print("It's Hotdog!")
                } else {
                    print("It's not Hotdog!")
                }
            }
            print(results)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            
            guard let ciimage = CIImage(image: image) else {
                fatalError("Could not convert UIImage into CIImage.")
            }
            detect(ciimage)
        }
        imagePicker.dismiss(animated: true)
    }
}
