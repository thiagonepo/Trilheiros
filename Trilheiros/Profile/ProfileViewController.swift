//
//  ProfileViewController.swift
//  Trilheiros
//
//  Created by Gael on 28/08/21.
//

import UIKit
import Firebase
import GoogleSignIn
import Realm
import RealmSwift
import CoreLocation
import SwiftUI
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    var auth: Auth?
    let firestore = Firestore.firestore()
    let locationManager = CLLocationManager()
    let actualUser = User()
    var image: UIImage? = nil
    let window = UIApplication.shared.windows[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColorPattern()
        locationManager.delegate = self
    }
    
    @IBAction func lightOrDarkSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            window.overrideUserInterfaceStyle = .light
        } else {
            window.overrideUserInterfaceStyle = .dark
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        getUserInfo()
    }
    
    func getUserInfo(){
        auth = Auth.auth()
        firestore.collection("users").document(auth?.currentUser?.uid ?? "").getDocument { snapshot, error in
            let data = snapshot?.data()
            DispatchQueue.main.async {
                self.userNameButton.setTitle(data?["fullName"] as? String, for: .normal)
                if data?["profileImage"] as? String == "" {
                    self.userImageView.image = #imageLiteral(resourceName: "user")
                } else {
                    let url = URL(string: data?["profileImage"] as? String ?? "")
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        self.userImageView.image = UIImage(data: data!)
                    }
                    
                }
            }
        }
    }
    
    func changeUserName() {
        let updateName = firestore.collection("users").document(self.auth?.currentUser?.uid ?? "")
        updateName.updateData([
            "fullName": self.actualUser.name
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func changeUserImage() {
        let updateImage = firestore.collection("users").document(self.auth?.currentUser?.uid ?? "")
        updateImage.updateData([
            "profileImage": self.actualUser.userImagePath
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func setColorPattern (){
        self.userImageView.circleImage(borderColor: .white, borderWidth: 1)
        self.view.layer.backgroundColor = UIColor(named: "background")?.cgColor
        self.userLocationLabel.textColor = UIColor(named: "labelColor")
    }
    
    @IBAction func nameButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Hello",
                                      message: "What would you like to be called?",
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your name:"
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .destructive))
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.userNameButton.setTitle(textField?.text, for: .normal)
            self.actualUser.name = textField?.text ?? ""
            self.changeUserName()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addImageTappedButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Take a picture or select a photo from your photo album",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera",
                                      style: .default,
                                      handler: { action in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album",
                                      style: .default,
                                      handler: { action in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .default,
                                      handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getImage(fromSourceType: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(fromSourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = fromSourceType
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = selectImage
            self.userImageView.image = selectImage
            
            guard let imageData = selectImage.jpegData(compressionQuality: 0.4) else {
                return
            }
            
            let storageRef = Storage.storage().reference(forURL: "gs://trilheiros-fe042.appspot.com")
            let storageProfileRef = storageRef.child("profile").child(auth?.currentUser?.uid ?? "")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            storageProfileRef.putData(imageData, metadata: metadata, completion:
                                        { (storageMetaData, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                
                storageProfileRef.downloadURL(completion: { (url, error) in
                    if let metaImageUrl = url?.absoluteString {
                        self.actualUser.userImagePath = metaImageUrl
                        self.changeUserImage()
                    }
                })
            })
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
}

//MARK: - CLLocationManagerDelegate

extension ProfileViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(lastLocation) { [weak self] (placemarks, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        if let firstLocation = placemarks?[0],
                           let cityName = firstLocation.locality { // get the city name
                            self?.userLocationLabel.text = cityName
                            self?.locationManager.stopUpdatingLocation()
                        }
                    }
                    
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
