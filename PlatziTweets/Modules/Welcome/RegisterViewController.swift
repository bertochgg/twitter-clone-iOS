//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Cesar Humberto Grifaldo Garcia on 09/11/22.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var namesTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    //MARK: - Actions
    @IBAction func registerAction(){
        view.endEditing(true)
        performRegister()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    
    //MARK: - Private methods
    private func performRegister(){
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo.", style: .warning).show()
            
            return
        }
        
        guard isValidEmail(email) else{
            NotificationBanner(title: "Error", subtitle: "Debes ingresar un correo valido.", style: .warning).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar una contraseña.", style: .warning).show()
            
            return
        }
        
        guard let names = namesTextField.text, !names.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar tu nombre y apellido.", style: .warning).show()
            
            return
        }
        
        //MARK: - Simple Networking
        let request = RegisterRequest(email: email, password: password, names: names)
        
        SVProgressHUD.show()
        
        SN.post(endpoint: Endpoints.register, model: request) { (response: SNResultWithEntity<RegisterResponse, ErrorResponse>) in
            
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
        //performSegue(withIdentifier: "showHome", sender: nil)
        
        
        
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    //MARK: - Extensions
    
    
}
