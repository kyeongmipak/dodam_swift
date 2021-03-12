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
    
    var emotion = 0
    var receivedDate = ""
    var modifyCheck = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이미지 클릭 이벤트
        imageAction()
        print("viewdidload ", receivedDate)
        
        print("select modify check :", modifyCheck)
    
    }

    func imageAction() {
        // sleep
        let tapSleep = UITapGestureRecognizer(target: self, action: #selector(self.sleepImageTapped))
        sleepEmotion.addGestureRecognizer(tapSleep)
        sleepEmotion.isUserInteractionEnabled = true
        
        // frown
        let tapFrown = UITapGestureRecognizer(target: self, action: #selector(self.frownImageTapped))
        frownEmotion.addGestureRecognizer(tapFrown)
        frownEmotion.isUserInteractionEnabled = true
        
        // pain
        let tapPain = UITapGestureRecognizer(target: self, action: #selector(self.painImageTapped))
        painEmotion.addGestureRecognizer(tapPain)
        painEmotion.isUserInteractionEnabled = true
        
        // surprised
        let tapSurprised = UITapGestureRecognizer(target: self, action: #selector(self.surprisedImageTapped))
        surprisedEmotion.addGestureRecognizer(tapSurprised)
        surprisedEmotion.isUserInteractionEnabled = true
        
        // angry
        let tapAngry = UITapGestureRecognizer(target: self, action: #selector(self.angryImageTapped))
        angryEmotion.addGestureRecognizer(tapAngry)
        angryEmotion.isUserInteractionEnabled = true
        
        // lovely
        let tapLovely = UITapGestureRecognizer(target: self, action: #selector(self.lovelyImageTapped))
        lovelyEmotion.addGestureRecognizer(tapLovely)
        lovelyEmotion.isUserInteractionEnabled = true
        
        // sad
        let tapSad = UITapGestureRecognizer(target: self, action: #selector(self.sadImageTapped))
        sadEmotion.addGestureRecognizer(tapSad)
        sadEmotion.isUserInteractionEnabled = true
        
        // shame
        let tapShame = UITapGestureRecognizer(target: self, action: #selector(self.shameImageTapped))
        shameEmotion.addGestureRecognizer(tapShame)
        shameEmotion.isUserInteractionEnabled = true
        
        // pleasure
        let tapPleasure = UITapGestureRecognizer(target: self, action: #selector(self.pleasureImageTapped))
        pleasureEmotion.addGestureRecognizer(tapPleasure)
        pleasureEmotion.isUserInteractionEnabled = true
        
        // normal
        let tapNormal = UITapGestureRecognizer(target: self, action: #selector(self.normalImageTapped))
        normalEmotion.addGestureRecognizer(tapNormal)
        normalEmotion.isUserInteractionEnabled = true
        
        // normal
        let tapBored = UITapGestureRecognizer(target: self, action: #selector(self.boredImageTapped))
        boredEmotion.addGestureRecognizer(tapBored)
        boredEmotion.isUserInteractionEnabled = true
        
        // unknown
        let tapUnknown = UITapGestureRecognizer(target: self, action: #selector(self.unknownImageTapped))
        unknownEmotion.addGestureRecognizer(tapUnknown)
        unknownEmotion.isUserInteractionEnabled = true
    }
    
    // sleep
    @objc func sleepImageTapped(sender: UITapGestureRecognizer) {
        emotion = 0
        if modifyCheck == 1 {
//            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController else { return }
//            vc.modifyEmotion = emotion
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            
        } else {
            self.performSegue(withIdentifier: "sgRegisterMove", sender: self)
        }

    }
    
    // frown
    @objc func frownImageTapped(sender: UITapGestureRecognizer) {
        emotion = 1
        if modifyCheck == 1 {
//            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController else { return }
//            vc.modifyEmotion = emotion
////            self.navigationController!.pushViewController(vc, animated: true)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "sgRegisterMove", sender: self)
        }
    }
    
    // pain
    @objc func painImageTapped(sender: UITapGestureRecognizer) {
        emotion = 2
        self.performSegue(withIdentifier: "sgRegisterMove", sender: self)

    }
    
    // surprised
    @objc func surprisedImageTapped(sender: UITapGestureRecognizer) {
        emotion = 3
        self.performSegue(withIdentifier: "sgRegisterMove", sender: self)

    }
    
    // angry
    @objc func angryImageTapped(sender: UITapGestureRecognizer) {
        emotion = 4
        self.performSegue(withIdentifier: "sgRegisterMove", sender: self)

    }
    
    // lovely
    @objc func lovelyImageTapped(sender: UITapGestureRecognizer) {
        emotion = 5
        self.performSegue(withIdentifier: "sgRegisterMove", sender: self)

    }
    
    // sad
    @objc func sadImageTapped(sender: UITapGestureRecognizer) {
        emotion = 6
        self.performSegue(withIdentifier: "sgRegisterMove", sender: self)

    }
    
    // shame
    @objc func shameImageTapped(sender: UITapGestureRecognizer) {
        emotion = 7
        self.performSegue(withIdentifier: "sgRegisterMove", sender: self)

    }
    
    // pleasure
    @objc func pleasureImageTapped(sender: UITapGestureRecognizer) {
        emotion = 8
        self.performSegue(withIdentifier: "sgRegisterMove", sender: self)

    }
    
    // normal
    @objc func normalImageTapped(sender: UITapGestureRecognizer) {
        emotion = 9
        self.performSegue(withIdentifier: "sgRegisterMove", sender: self)

    }
    
    // bored
    @objc func boredImageTapped(sender: UITapGestureRecognizer) {
        emotion = 10
        self.performSegue(withIdentifier: "sgRegisterMove", sender: self)

    }
    
    // unknown
    @objc func unknownImageTapped(sender: UITapGestureRecognizer) {
        emotion = 11
        self.performSegue(withIdentifier: "sgRegisterMove", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgRegisterMove"{
           let registerView = segue.destination as! RegisterViewController
            registerView.receivedItem(selectedDate: receivedDate, selectedEmotion: emotion)
            print("prepare ", receivedDate)
        }
    }
    
}
