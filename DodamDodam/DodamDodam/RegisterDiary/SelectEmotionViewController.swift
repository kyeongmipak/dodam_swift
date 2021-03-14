//
//  SelectEmotionViewController.swift
//  DodamDodam
//
//  Created by 박경미 on 2021/03/08.
//

import UIKit

class SelectEmotionViewController: UIViewController {

    @IBOutlet weak var sleepEmotion: UIImageView!
    @IBOutlet weak var frownEmotion: UIImageView!
    @IBOutlet weak var painEmotion: UIImageView!
    @IBOutlet weak var surprisedEmotion: UIImageView!
    @IBOutlet weak var angryEmotion: UIImageView!
    @IBOutlet weak var lovelyEmotion: UIImageView!
    @IBOutlet weak var sadEmotion: UIImageView!
    @IBOutlet weak var shameEmotion: UIImageView!
    @IBOutlet weak var pleasureEmotion: UIImageView!
    @IBOutlet weak var normalEmotion: UIImageView!
    @IBOutlet weak var boredEmotion: UIImageView!
    @IBOutlet weak var unknownEmotion: UIImageView!
    
    var receivedDate = ""
    var modifyCheck = 0
    var emotion = 0
    
    // Transfer selected emotion to RegisterViewController
    var delegate: DeliveryEmotionCheckProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Move RegisterViewController when image tap
        imageAction()
    
    }
    
    // Move RegisterViewController when image tap
    func imageAction() {
        // when sleep emotion tap
        let tapSleep = UITapGestureRecognizer(target: self, action: #selector(self.sleepImageTapped))
        sleepEmotion.addGestureRecognizer(tapSleep)
        sleepEmotion.isUserInteractionEnabled = true
        
        // when frown emotion tap
        let tapFrown = UITapGestureRecognizer(target: self, action: #selector(self.frownImageTapped))
        frownEmotion.addGestureRecognizer(tapFrown)
        frownEmotion.isUserInteractionEnabled = true
        
        // when pain emotion tap
        let tapPain = UITapGestureRecognizer(target: self, action: #selector(self.painImageTapped))
        painEmotion.addGestureRecognizer(tapPain)
        painEmotion.isUserInteractionEnabled = true
        
        // when surprised emotion tap
        let tapSurprised = UITapGestureRecognizer(target: self, action: #selector(self.surprisedImageTapped))
        surprisedEmotion.addGestureRecognizer(tapSurprised)
        surprisedEmotion.isUserInteractionEnabled = true
        
        // when angry emotion tap
        let tapAngry = UITapGestureRecognizer(target: self, action: #selector(self.angryImageTapped))
        angryEmotion.addGestureRecognizer(tapAngry)
        angryEmotion.isUserInteractionEnabled = true
        
        // when lovely emotion tap
        let tapLovely = UITapGestureRecognizer(target: self, action: #selector(self.lovelyImageTapped))
        lovelyEmotion.addGestureRecognizer(tapLovely)
        lovelyEmotion.isUserInteractionEnabled = true
        
        // when sad emotion tap
        let tapSad = UITapGestureRecognizer(target: self, action: #selector(self.sadImageTapped))
        sadEmotion.addGestureRecognizer(tapSad)
        sadEmotion.isUserInteractionEnabled = true
        
        // when shame emotion tap
        let tapShame = UITapGestureRecognizer(target: self, action: #selector(self.shameImageTapped))
        shameEmotion.addGestureRecognizer(tapShame)
        shameEmotion.isUserInteractionEnabled = true
        
        // when pleasure emotion tap
        let tapPleasure = UITapGestureRecognizer(target: self, action: #selector(self.pleasureImageTapped))
        pleasureEmotion.addGestureRecognizer(tapPleasure)
        pleasureEmotion.isUserInteractionEnabled = true
        
        // when normal emotion tap
        let tapNormal = UITapGestureRecognizer(target: self, action: #selector(self.normalImageTapped))
        normalEmotion.addGestureRecognizer(tapNormal)
        normalEmotion.isUserInteractionEnabled = true
        
        // when normal emotion tap
        let tapBored = UITapGestureRecognizer(target: self, action: #selector(self.boredImageTapped))
        boredEmotion.addGestureRecognizer(tapBored)
        boredEmotion.isUserInteractionEnabled = true
        
        // when unknown emotion tap
        let tapUnknown = UITapGestureRecognizer(target: self, action: #selector(self.unknownImageTapped))
        unknownEmotion.addGestureRecognizer(tapUnknown)
        unknownEmotion.isUserInteractionEnabled = true
    }
    
    // Execute selector when sleep emotion tapped
    @objc func sleepImageTapped(sender: UITapGestureRecognizer) {
        emotion = 0
        modifyEmotionCheck()
    }
    
    // Execute selector when frown emotion tapped
    @objc func frownImageTapped(sender: UITapGestureRecognizer) {
        emotion = 1
        modifyEmotionCheck()
    }
    
    // Execute selector when pain emotion tapped
    @objc func painImageTapped(sender: UITapGestureRecognizer) {
        emotion = 2
        modifyEmotionCheck()

    }
    
    // Execute selector when surprised emotion tapped
    @objc func surprisedImageTapped(sender: UITapGestureRecognizer) {
        emotion = 3
        modifyEmotionCheck()

    }
    
    // Execute selector when angry emotion tapped
    @objc func angryImageTapped(sender: UITapGestureRecognizer) {
        emotion = 4
        modifyEmotionCheck()

    }
    
    // Execute selector when lovely emotion tapped
    @objc func lovelyImageTapped(sender: UITapGestureRecognizer) {
        emotion = 5
        modifyEmotionCheck()

    }
    
    // Execute selector when sad emotion tapped
    @objc func sadImageTapped(sender: UITapGestureRecognizer) {
        emotion = 6
        modifyEmotionCheck()

    }
    
    // Execute selector when shame emotion tapped
    @objc func shameImageTapped(sender: UITapGestureRecognizer) {
        emotion = 7
        modifyEmotionCheck()

    }
    
    // Execute selector when pleasure emotion tapped
    @objc func pleasureImageTapped(sender: UITapGestureRecognizer) {
        emotion = 8
        modifyEmotionCheck()

    }
    
    // Execute selector when normal emotion tapped
    @objc func normalImageTapped(sender: UITapGestureRecognizer) {
        emotion = 9
        modifyEmotionCheck()

    }
    
    // Execute selector when bored emotion tapped
    @objc func boredImageTapped(sender: UITapGestureRecognizer) {
        emotion = 10
        modifyEmotionCheck()

    }
    
    // Execute selector when unknown emotion tapped
    @objc func unknownImageTapped(sender: UITapGestureRecognizer) {
        emotion = 11
        modifyEmotionCheck()

    }
    
    // Check whether it comes from modify page or register page
    func modifyEmotionCheck() {
        // Transfer emotion to RegisterViewController when diary modify
        if modifyCheck == 1 {
            delegate?.deliveryEmotionCheckData(emotion, 2)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        // Move RegisterViewController when diary write
        } else {
            self.performSegue(withIdentifier: "sgRegisterMove", sender: self)
        }
    }
    
    // Transfer data to RegisterViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgRegisterMove"{
           let registerView = segue.destination as! RegisterViewController
            registerView.receivedItem(selectedDate: receivedDate, selectedEmotion: emotion)
        }
    }
    
}
