//
//  SettingsViewController.swift
//  TsaChat1819
//
//  Created by Milan Kokic on 24/02/2019.
//  Copyright © 2019 Marro Gros Gabriel. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var openGallery: UIButton!
    var context: NSManagedObjectContext!
    var fileUrl: URL?
    var photo: UIImage?
    var photoData: Data?
    @IBOutlet weak var textView: UITextField!
    var meMessageHelper: MeMessageHelper?
    private let textPlaceholder = "Enter your name"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        meMessageHelper = MeMessageHelper()
        textView.text = textPlaceholder
        textView.textColor = UIColor.lightGray
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        let user = meMessageHelper?.getUser(context: context)
        setUserData(user: user)
    }
    
    func setUserData(user: User?){
        if (user != nil){
            textView.text = user!.name
            if let userPhoto = user!.profilePhoto {
                imageView.image = UIImage(data: userPhoto)
                
            }
            openGallery.isEnabled = false
            saveButton.isEnabled = false
            
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func openGallery(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary;
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        
        if (textView.text != textPlaceholder && textView.text != ""){
            meMessageHelper?.saveUser(context: context, fileUrl: fileUrl, name: textView.text!, photoData: photoData)
            
            navigationController?.popViewController(animated: true)
            
            dismiss(animated: true, completion: nil)
        }
        else {
            let message = "Name cannot be empty"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)
            
            let duration: Double = 2
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func startEditing(_ textView: UITextField) {
        if textView.textColor == UIColor.lightGray{
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    @IBAction func stopEditing(_ textView: UITextField) {
        if textView.text!.isEmpty {
            textView.text = "Enter your name"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        photo = image.resizedRoundedImage(200)
        imageView.image = photo
        let smallImage = image.resizedRoundedImage(50)
        photoData = smallImage.pngData()
        fileUrl = (info[UIImagePickerController.InfoKey.imageURL] as! URL)
        
        dismiss(animated:true, completion: nil)
    }
}
