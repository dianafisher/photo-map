//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, LocationsViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the initial location to San Francisco
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpanMake(0.1, 0.1))
        
        mapView.setRegion(sfRegion, animated: false)
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        // Instantiate a UIImagePickerController
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available, so we'll use the photo library instead")
            vc.sourceType = .photoLibrary
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: LocationsViewControllerDelegate
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        navigationController?.popToViewController(self, animated: false)
        
        // Add a pin to the map.
        let annotation = MKPointAnnotation()
        let lat = CLLocationDegrees(exactly: latitude)
        let lng = CLLocationDegrees(exactly: longitude)
        annotation.coordinate = CLLocationCoordinate2DMake(lat!, lng!)
        annotation.title = "\(latitude)"
        mapView.addAnnotation(annotation)
    }
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if (annotationView == nil) {
//            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)  // this is a pin annotation
            
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)  // so that we can customize the annotion view
            
            // Resize image
            let pinImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            pinImageView.layer.borderColor = UIColor.white.cgColor
            pinImageView.layer.borderWidth = 3.0
            pinImageView.contentMode = .scaleAspectFit
            pinImageView.image = self.selectedImage
            
            UIGraphicsBeginImageContext(pinImageView.frame.size)
            pinImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            annotationView?.image = resizedImage
            
            
            
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        }
        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
//        imageView.image = UIImage(named: "camera")
        
        // Resize the photo
        var resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = .scaleAspectFit
        resizeRenderImageView.image = self.selectedImage
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        var thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.image = thumbnail
        
        // Add a button to the right annotation view
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Launch the FullImageViewController
        
        self.performSegue(withIdentifier: "fullImageSegue", sender: self)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.selectedImage = editedImage
        
        // Dismiss the UIImagePickerController
        dismiss(animated: true) {
            // Launch the LocationsViewController
            self.performSegue(withIdentifier: "tagSegue", sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "tagSegue" {
            let locationsVC = segue.destination as! LocationsViewController
            locationsVC.delegate = self
            
        } else if segue.identifier == "fullImageSegue" {
            let fullImageVC = segue.destination as! FullImageViewController
            fullImageVC.photo = selectedImage
        }
        
        
    }
    

}
