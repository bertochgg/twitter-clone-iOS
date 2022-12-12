//
//  PostTweetViewController.swift
//  PlatziTweets
//
//  Created by Cesar Humberto Grifaldo Garcia on 13/11/22.
//

import UIKit
import Simple_Networking
import NotificationBannerSwift
import SVProgressHUD
import FirebaseStorage
import AVFoundation
import AVKit
import MobileCoreServices
//libreria para el location
import CoreLocation

class PostTweetViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    //MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoURL: URL?
    //propiedades para el location
    private var locationManager: CLLocationManager?
    private var userLocation: CLLocation?
    
    //MARK: - Actions
    @IBAction func addTweetAction(){
        if currentVideoURL != nil {
                    uploadVideoToFirebase()
                    
                    return
                }
                
                if previewImageView.image != nil {
                    uploadPhotoToFirebase()
                    
                    return
                }
                
                savePost(imageUrl: nil, videoUrl: nil)
    }
    
    @IBAction func openCamaraAction() {
        
        let alert = UIAlertController(title: "Cámara",
                                              message: "Selecciona una opción",
                                              preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Foto", style: .default, handler: { _ in
                    self.openCamara()
                }))
                
                alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
                    self.openVideoCamera()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
                
                present(alert, animated: true, completion: nil)
    }
    
    @IBAction func openPreviewAction(){
        guard let currentVideoURL = currentVideoURL else{
            return
        }
        
        let avPlayer = AVPlayer(url: currentVideoURL)
        
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true) {
            avPlayerController.player?.play()
        }
    }
    
    @IBAction func dismissAction(){
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        videoButton.isHidden = true
        requestLocation()
    }
    
    //MARK: - Private Methods
    private func requestLocation(){
        // Vlaidamos que el usuario tenga el GPS activo y disponible.
                guard CLLocationManager.locationServicesEnabled() else {
                    return
                }
                
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.requestAlwaysAuthorization()
                locationManager?.startUpdatingLocation()
    }
    
    private func openVideoCamera() {
            imagePicker = UIImagePickerController()
            imagePicker?.sourceType = .camera
            imagePicker?.mediaTypes = [kUTTypeMovie as String]
            imagePicker?.cameraFlashMode = .off
            imagePicker?.cameraCaptureMode = .video
            imagePicker?.videoQuality = .typeMedium
            imagePicker?.videoMaximumDuration = TimeInterval(5)
            imagePicker?.allowsEditing = true
            imagePicker?.delegate = self
            
            guard let imagePicker = imagePicker else {
                return
            }
            
            present(imagePicker, animated: true, completion: nil)
        }
    
    private func openCamara(){
        //Setear las opciones de la camara
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera//Seleccionar el tipo de entrada de imagen
        imagePicker?.cameraFlashMode = .off//Seleccionar el flash
        imagePicker?.cameraCaptureMode = .photo//Que tipo captura el imagepicker
        imagePicker?.allowsEditing = true//Habilita la edicion de la imagen tomada
        imagePicker?.delegate = self//Delegado para controlar cuando se toma o no se toma la foto
        
        guard let imagePicker = imagePicker else{
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func uploadPhotoToFirebase() {
            // 1. Asegurarnos de que la foto exista
            // 2. Comprimir la imagen y convertirla en Data
            guard
                let imageSaved = previewImageView.image,
                let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
                    
                    return
            }
            
            SVProgressHUD.show()
            
            // 3. Configuración para guardar la foto en firebase
            let metaDataConfig = StorageMetadata()
            metaDataConfig.contentType = "image/jpg"
            
            // 4. Referencia al storage de firebase
            let storage = Storage.storage()
            
            // 5. Crear nombre de la imagen a subir
            let imageName = UUID().uuidString//Crea nombre aleatorio segun el tiempo en milisegundos
            
            // 6. Referencia a la carpeta donde se va a guardar la foto
            let folderReference = storage.reference(withPath: "fotos-tweets/\(imageName).jpg")
            
            // 7. Subir la foto a Firebase
            
            DispatchQueue.global(qos: .background).async {
                folderReference.putData(imageSavedData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
                    
                    DispatchQueue.main.async {
                        // Detener la carga
                        SVProgressHUD.dismiss()
                        
                        if let error = error {
                            NotificationBanner(title: "Error",
                                               subtitle: error.localizedDescription,
                                                style: .warning).show()
                            
                            return
                        }
                        
                        // obtener la URL de descarga
                        folderReference.downloadURL { (url: URL?, error: Error?) in
                            let downloadUrl = url?.absoluteString ?? ""
                            self.savePost(imageUrl: downloadUrl, videoUrl: nil)
                        }
                    }
                    
                }
            }
        }
    
    private func uploadVideoToFirebase() {
            // 1. Asegurarnos de que el video exista
            // 2. convertir en Data el video
            guard
                let currentVideoSavedURL = currentVideoURL,
                let videoData: Data = try? Data(contentsOf: currentVideoSavedURL) else {
                    
                    return
            }
            
            SVProgressHUD.show()
            
            // 3. Configuración para guard la foto en firebase
            let metaDataConfig = StorageMetadata()
            metaDataConfig.contentType = "video/MP4"
            
            // 4. Referencia al storage de firebase
            let storage = Storage.storage()
            
            // 5. Crear nombre de la imagen a subir
            let videoName = Int.random(in: 100...1000)
            
            // 6. Referencia a la carpeta donde se va a guardar la foto
            let folderReference = storage.reference(withPath: "video-tweets/\(videoName).mp4")
            
            // 7. Subir el video a Firebase
            
            DispatchQueue.global(qos: .background).async {
                folderReference.putData(videoData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
                    
                    DispatchQueue.main.async {
                        // Detener la carga
                        SVProgressHUD.dismiss()
                        
                        if let error = error {
                            NotificationBanner(title: "Error",
                                               subtitle: error.localizedDescription,
                                               style: .warning).show()
                            
                            return
                        }
                        
                        // obtener la URL de descarga
                        folderReference.downloadURL { (url: URL?, errror: Error?) in
                            let downloadUrl = url?.absoluteString ?? ""
                            
                            self.savePost(imageUrl: nil, videoUrl: downloadUrl)
                        }
                    }
                }
            }
        }
    
    private func savePost(imageUrl: String?, videoUrl: String?){
        
        // Crear un request de localización
                var postLocation: Location?
                
                if let userLocation = userLocation {
                    postLocation = Location(latitude: userLocation.coordinate.latitude,
                                                       longitude: userLocation.coordinate.longitude)
                }
        
        //Verificar si el tweet no es vacio
        guard let filledTweet = textView.text, !filledTweet.isEmpty else{
            NotificationBanner(title: "Error", subtitle: "Tu tweet esta vacio", style: .warning).show()
            return
        }
        
        //1. Hacer request = nuestro modelo
        let request = PostTweetRequest(text: filledTweet, imageUrl: imageUrl, videoUrl: videoUrl, location: postLocation)
        
        //2. Iniciar carga de HUD
        SVProgressHUD.show()
        
        //3. Llamar servicio de post
        SN.post(endpoint: Endpoints.posts, model: request) { (response: SNResultWithEntity<PostTweetResponse, ErrorResponse>) in
            //4. Terminar la carga
            SVProgressHUD.dismiss()
            //5. Codigo de funcionalidades
            switch response{
            case .success:
                self.dismiss(animated: true, completion: nil)
                
                
            case .error(let error):
                NotificationBanner(subtitle: "Error en consulta de usuario: \(error.localizedDescription)", style: .danger).show()
                
            case .errorResult(let entity):
                NotificationBanner(subtitle: "Error en consulta de usuario: \(entity.error)", style: .warning).show()
            }
        }
    }


}

// MARK: - UIImagePickerControllerDelegate
//Controla cuando se toma o no la foto
extension PostTweetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Metodo que controla cuando ya se termino de tomar o no la foto, buscar didFinishPickingMediaWithInfo
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Cerrar cámara
        imagePicker?.dismiss(animated: true, completion: nil)
        // Capturar imagen
        if info.keys.contains(.originalImage) {
            previewImageView.isHidden = false
            
            // Obtenemos la imagen tomada
            previewImageView.image = info[.originalImage] as? UIImage
        }
        
        // Aqui se captura el video y su url
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            videoButton.isHidden = false
            currentVideoURL = recordedVideoUrl
                }
        
    }
}

// MARK: - CLLocationManagerDelegate
extension PostTweetViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let bestLocation = locations.last else {
            return
        }
        
        // Ya tenemos la ubicación del usuario! 🥶
        userLocation = bestLocation
    }
}
