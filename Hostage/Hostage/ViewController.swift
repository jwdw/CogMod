//
//  ViewController.swift
//  Hostage
//
//  Created by J.W. de Wit on 01/03/2019.
//  Copyright © 2019 J.W. de Wit. All rights reserved.
//

import UIKit

var hostageNum = 7
class StartViewController: UIViewController {
    private let aggressOptions = ["Low", "Normal", "High"]
    
    @IBOutlet weak var hostageNumSlider: UISlider!
    @IBOutlet weak var hostageNumSliderLabel: UILabel!
    @IBAction func hostageNumFunc(_ sender: UISlider) {
        hostageNum = Int(sender.value)
        hostageNumSliderLabel.text = "\(hostageNum)"
    }
    
    @IBOutlet weak var aggressNumSlider: UISlider!
    @IBOutlet weak var aggressNumSliderLabel: UILabel!
    @IBAction func aggressNumFunc(_ sender: UISlider) {
        let aggressNum = Int(sender.value)
        aggressNumSliderLabel.text = aggressOptions[aggressNum]
    }
    
    @IBAction func startGameFunc(_ sender: Any) {
        performSegue(withIdentifier: "startSegue", sender: self)
    }
    
    
}

class ViewController: UIViewController {
    private let game = Game(hosNum: hostageNum)
    
    @IBOutlet weak var playerScore: UITextView!
    @IBOutlet weak var opponentScore: UITextView!

    @IBOutlet weak var feedbackTextField: UITextView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var totalHostageNum: UITextView!
    
    @IBOutlet weak var offerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        stepper.maximumValue = Double(game.noOfHostages)
        totalHostageNum.text = String(game.opponentItems.count)
        playerScore.text = String(game.getPlayerScore())
        opponentScore.text = String(game.getOpponentScore())
        feedbackTextField.text = "Gimme a " + game.getPrefs().lowercased() + " or heads are gonna roll!"
    }
    
    
    
    var offers: [String] = []
    
    @IBAction func itemButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        checkOfferButton()
    }
    
    @IBOutlet weak var hostageNumber: UILabel!
    @IBAction func stepper(_ sender: UIStepper) {
        hostageNumber.text = Int(sender.value).description
        checkOfferButton()
    }
    
    @IBOutlet weak var itemButtonView: UIView!
    @IBAction func offerButton(_ sender: Any) {
        var playerItemsOffered: [String] = []
        for case let button as UIButton in itemButtonView.subviews {
            if button.isSelected {
                playerItemsOffered.append(button.currentTitle!.lowercased().components(separatedBy: ":")[0])
            }
          
        }
        
        let hostHostagesOffered:Int = Int(hostageNumber.text!)!
        let offer = Offer(playerOffers: game.selectedPlayerItems(itemsStringList: playerItemsOffered),
                          opponentOffers: game.selectedOpponentItems(itemsInt: hostHostagesOffered))
        
        
        let response = game.evaluateOffer(offer: offer)
        
        updateResponse(response: response.response)
        
        if response.deal {
            updateUIAfterOffer()
        }
    }
    
    @IBOutlet weak var responseText: UITextView!
    func updateResponse(response: String) {
        responseText.text = response
    }
    
    func checkOfferButton() {
        if hostageNumber.text == "0" {
            offerButton.isEnabled = false
        } else {
            offerButton.isEnabled = false
            for case let button as UIButton in itemButtonView.subviews {
                if button.isSelected {
                    offerButton.isEnabled = true
                }
            }
        }
    }
    
    func updateUIAfterOffer() {
        var totalItemNum: Int = 12
        for case let button as UIButton in itemButtonView.subviews {
            for playerItem in game.playerItems {
                if button.titleLabel!.text!.lowercased().contains(playerItem.name) {
                    if !playerItem.available {
                        button.isEnabled = false
                        button.isSelected = false
                        totalItemNum -= 1
                        print(totalItemNum)
                    }
                }
            }
        }
        totalHostageNum.text = String(game.noOfHostagesLeft)
        stepper.maximumValue = Double(game.noOfHostagesLeft)
        stepper.value = 0.0
        hostageNumber.text = "0"
        
        playerScore.text = String(game.getPlayerScore())
        opponentScore.text = String(game.getOpponentScore())
        offerButton.isEnabled = false

        if Int(totalHostageNum.text) == 0 || totalItemNum < 1{
            performSegue(withIdentifier: "endSegue", sender: self)
        }
        
    }
    
   
}

class EndViewController: UIViewController {
    
    @IBAction func backMenu(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    
}
