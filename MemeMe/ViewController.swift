//
//  ViewController.swift
//  MemeMe
//
//  Created by KJ Schmidt on 1/12/18.
//  Copyright © 2018 KJ Schmidt. All rights reserved.
//

import UIKit


var memes = [Meme]()

struct Meme {
    var top: String = ""
    var bottom: String = ""
    var image: UIImage?
    var memedImage: UIImage?
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var pickToolbar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextInput: UITextField!
    @IBOutlet weak var bottomTextInput: UITextField!
    
    
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0
    ]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        func textFieldsSetup(textField: UITextField) {
            textField.defaultTextAttributes = memeTextAttributes
            topTextInput.placeholder = "TOP"
            bottomTextInput.placeholder = "BOTTOM"
            textField.textAlignment = .center
            textField.delegate = self as UITextFieldDelegate
        }
        textFieldsSetup(textField: topTextInput)
        textFieldsSetup(textField: bottomTextInput)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    //creating meme image
    func generateMemedImage() -> UIImage {
        
        navigationBar.isHidden = true
        pickToolbar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        navigationBar.isHidden = false
        pickToolbar.isHidden = false
        
        return memedImage
    }
    
    
    
    // Sharing Meme image
    func save() {
        let memedImage = generateMemedImage()
        _ = Meme(top: topTextInput.text!, bottom: bottomTextInput.text!, image: imagePickerView.image, memedImage:memedImage)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, success, items, error in
            self.save()
            self.dismiss(animated: true, completion: nil)
        }
        
        present(activityController, animated: true, completion: nil)
        
    }
    
    
    //self made cancel button to start from scratch
    @IBAction func cancelAction(_ sender: Any) {
        
        topTextInput.text = ""
        bottomTextInput.text = ""
        self.imagePickerView.image = nil
    }
    
    
    
    //disables camera button if camera not available
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    
    //keyboard stuff
    
    func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    //end of keyboard stuff
    
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Image from Album
    
    @IBAction func pickAnImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        present(pickerController, animated: true, completion: nil)
        
    }
    //Cancel selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        self.dismiss(animated: true, completion: nil)
    }
    
    //gets image to the view controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage]
        
        if ((image as? UIImage) != nil){
            
            imagePickerView.image = image as! UIImage?
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Take new image with camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    


}

extension ViewController:  UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            unsubscribeFromKeyboardNotifications()
        }
        //  unsubriscribe from Notifications if editing the top text field (textField.tag == 1)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField.tag == 1 {
            subscribeToKeyboardNotifications()
        }
        //  subcribe to Notifications after editing the top text field (textField.tag == 1)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
