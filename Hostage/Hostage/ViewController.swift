//
//  ViewController.swift
//  Hostage
//
//  Created by J.W. de Wit on 01/03/2019.
//  Copyright © 2019 J.W. de Wit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let game = Game()

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var totalHostageNum: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        stepper.maximumValue = Double(game.noOfHostages)
        totalHostageNum.text = String(game.opponentItems.count)
    }
    
    
    
    var offers: [String] = []
    
    @IBAction func itemButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBOutlet weak var hostageNumber: UILabel!
    @IBAction func stepper(_ sender: UIStepper) {
        hostageNumber.text = Int(sender.value).description
    }
    
    @IBOutlet weak var itemButtonView: UIView!
    @IBAction func offerButton(_ sender: Any) {
        var playerItemsOffered: [String] = []
        for case let button as UIButton in itemButtonView.subviews {
            if button.isSelected {
                playerItemsOffered.append(button.currentTitle!.lowercased())
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
    
    func updateUIAfterOffer() {
        for case let button as UIButton in itemButtonView.subviews {
            for playerItem in game.playerItems {
                if button.titleLabel?.text?.lowercased() == playerItem.name {
                    if !playerItem.available {
                        button.isEnabled = false
                        button.isSelected = false
                    }
                }
            }
        }
        totalHostageNum.text = String(game.opponentItems.count)
        stepper.maximumValue = Double(game.opponentItems.count)
        stepper.value = 0.0
        hostageNumber.text = "0"
        
    }
    
   
}

