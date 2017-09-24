//
//  ViewController.swift
//  ARGallery
//
//  Created by Kyle Johnson on 9/24/17.
//  Copyright © 2017 Kyle Johnson. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import CoreImage

class ViewController: UIViewController, ARSKViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    var currentArtwork: UIImage!
    var imagePreview: UIImageView!
    var infoText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
//        sceneView.showsFPS = true
//        sceneView.showsNodeCount = true
        
        UIApplication.shared.isStatusBarHidden = false
        
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
            
            imagePreview = UIImageView(frame: CGRect(x: 10, y: view.bounds.height - 110, width: 100, height: 100))
            tabBarController?.view.addSubview(imagePreview)
            
            infoText = UILabel()
            infoText?.text = "Select or take a photo to begin."
            infoText?.textAlignment = .center
            infoText?.textColor = .white
            
            let frame = CGRect(x: 0, y: view.bounds.height - 39, width: view.bounds.width, height: 30)
            infoText.frame = frame
            tabBarController?.view.addSubview(infoText)
        }
        
        title = "ARGallery"
        
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        tabBarController?.tabBar.barStyle = UIBarStyle.black
        tabBarController?.tabBar.tintColor = UIColor.white
        tabBarController?.viewControllers = []
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePhoto))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openPhoto))
    }
    
    @objc func takePhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        present(picker, animated: true)
    }
    
    @objc func openPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        currentArtwork = image.frame(color: .white, width: 30)

        if let image = currentArtwork as UIImage? {
            imagePreview.image = image.frame(color: UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1), width: 30)
            infoText?.text = "Photo selected! Tap to place."
            let frame = CGRect(x: 130, y: view.bounds.height - 39, width: view.bounds.width - 150, height: 30)
            infoText.frame = frame
        }
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, didAdd node: SKNode, for anchor: ARAnchor) {
        guard let artwork = currentArtwork as UIImage? else { return }
        
        let artworkSize = CGSize(width: artwork.size.width * 0.05, height: artwork.size.height * 0.05)
        let artworkNode = SKSpriteNode(texture: SKTexture(image: artwork), size: artworkSize)
        node.addChild(artworkNode)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}

extension UIImage {
    func frame(color: UIColor, width: CGFloat) -> UIImage? {
        let size = CGSize(width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContext(size)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.draw(in: rect, blendMode: .normal, alpha: 1.0)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(color.cgColor)
        context?.setLineWidth(width)
        context?.stroke(rect)
        
        let framedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return framedImage
    }
}
