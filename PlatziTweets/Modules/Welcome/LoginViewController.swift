//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Cesar Humberto Grifaldo Garcia on 09/11/22.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class LoginViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: - Actions
    @IBAction func loginButton() {
        view.endEditing(true)
        performLogin()
        saveEmail()
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Private Methods
    private func performLogin() {
        guard let email = emailTextField.text, !email.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo.", style: .warning).show()
                
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "Debes ingresar una contraseña.", style: .warning).show()
            
            return
        }
        
        if !email.isEmpty && !password.isEmpty{
            NotificationBanner(title: "Success", subtitle: "Has ingresado los datos correctamente", style: .success).show()
        }
        
        //MARK: - Simple Networking
        //Crear request
        let request = LoginRequest(email: email, password: password)
        
        //Inicializar carga
        SVProgressHUD.show()
        
        
        //LLamar a libreria de red
        SN.post(endpoint: Endpoints.login, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
            SVProgressHUD.dismiss()
            //usuario test = test@test.com contra = qwerty
            switch response{
            case .success(let user):
                self.performSegue(withIdentifier: "showHome", sender: nil)
                DispatchQueue.main.async {
                    NotificationBanner(subtitle: "Bienvenido \(user.user.names)", style: .success).show()
                }
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                
                
            case .error(let error):
                NotificationBanner(subtitle: "Error en consulta de usuario: \(error.localizedDescription)", style: .danger).show()
                
            case .errorResult(let entity):
                NotificationBanner(subtitle: "Error en consulta de usuario: \(entity.error)", style: .warning).show()
            }
        }
        
    }
    
    private func saveEmail(){
        let email = emailTextField.text
        
        guard let wrapEmail = email, !wrapEmail.isEmpty else{
            return
        }
        
        storage.set(wrapEmail, forKey: "emailKey")
        
    }
    
    private let storage = UserDefaults.standard
    

}
