//
//  ViewController.swift
//  Trilheiros
//
//  Created by Gael on 24/08/21.
//

import UIKit
import Firebase
import FirebaseAuth

class SignViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var createAccount: UIButton!
    
    private let images = [UIImage(named: "IMG1"), UIImage(named: "IMG2"), UIImage(named: "IMG3"), UIImage(named: "IMG4"), UIImage(named: "IMG5"), UIImage(named: "IMG6")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            let randoElement = Int.random(in: 0...5)
            UIView.transition(with: self.backgroundImageView, duration: 5.0, options: .transitionCrossDissolve, animations: {self.backgroundImageView.image = self.images[randoElement]}, completion: nil)
        }
    }
    
    
    private func setupUI () {
        self.createAccount.layer.cornerRadius = 4
        self.backgroundImageView.image = UIImage(named: "IMG2")
    }
    
    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        let _error = verifyTextFields()
        let fullName = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if error != nil {
                    self.alert(title: "Atention", message: "Failed to register")
                    print(_error!)
                } else {
                    let firestore = Firestore.firestore()
                    firestore.collection("users").document(authResult?.user.uid ?? "").setData(["fullName" : fullName, "uid" : authResult?.user.uid, "profileImage" : ""]) { (error) in
                        if error != nil {
                            self.alert(title: "Atention", message: "Error registering user")
                        }
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                    }
                    self.alert(title: "Success", message: "User created!")
                }
            }
        }
    }
    
    func alert(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func verifyTextFields() -> String? {
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Fill in all fields"
        }
        
        let currentlyPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isPasswordValid(currentlyPassword) == false {
            return "Your password is not valid, enter a password longer than 8 characters."
        }
        return nil
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    func showError(mensagem: String) {
        print(mensagem)
    }
}
