//
//  WelcomeViewController.swift
//  Trilheiros
//
//  Created by Laila Guzzon Hussein Lailota on 30/08/21.
//

import UIKit
import Firebase
import GoogleSignIn

class WelcomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var orLaber: UILabel!
    @IBOutlet weak var notYetUser: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var loginGoogle: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    private let images = [UIImage(named: "IMG1"), UIImage(named: "IMG2"), UIImage(named: "IMG3"), UIImage(named: "IMG4"), UIImage(named: "IMG5"), UIImage(named: "IMG6")]
    
    var bgTimer: Timer?
    
    var auth: Auth?
    var manager = TabBarController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.auth = Auth.auth()
        self.setupUI()
        setColorPattern()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    private func setupUI () {
        self.logInButton.layer.cornerRadius = 4
        self.forgotPasswordButton.layer.cornerRadius = 4
        self.signInButton.layer.cornerRadius = 4
        self.loginGoogle.layer.cornerRadius = 4
        self.backgroundImageView.image = UIImage(named: "IMG1")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            
            let randoElement = Int.random(in: 0...5)
            
            UIView.transition(with: self.backgroundImageView, duration: 5.0, options: .transitionCrossDissolve, animations: {self.backgroundImageView.image = self.images[randoElement]}, completion: nil)
            
        }
        validadeAuth()
    }
    
    private func validadeAuth() {
        if auth?.currentUser != nil {
            UIView.setAnimationsEnabled(false)
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func setColorPattern (){
        self.logInButton.circleButton()
        self.forgotPasswordButton.circleButton()
        self.signInButton.circleButton()
        self.loginGoogle.circleButton()
    }
    
    func alert(title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        self.auth?.signIn(withEmail: email, password: password, completion: { [weak self] (usuario, error) in
            guard let self = self else { return }
            if error != nil {
                self.alert(title: "Attention", message: "Incorrect data")
            } else if usuario == nil {
                    self.alert(title: "Attention", message: "The user does not exist")
            } else {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
                self.alert(title: "Success", message: "Login successfully!")
            }
        })
        emailTextField.text = ""
        passwordTextField.text = ""
        emailTextField.becomeFirstResponder()
    }
 
    @IBAction func loginGoogleTapped(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) {  [unowned self] user, error in
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (result, error) in
                if error != nil {
                    self.alert(title: "Login failed", message: "Please try again")
                } else {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                    self.alert(title: "Success", message: "Login successfully!")
                }
            }
        }
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "newPassword", sender: nil)
        
    }
    
    @IBAction func unWindSeague (_ sender : UIStoryboardSegue) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension WelcomeViewController: UITextFieldDelegate {
    
}
