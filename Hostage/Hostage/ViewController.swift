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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    var offers: [String] = []
    
    @IBOutlet weak var offer: UITextView!
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
        print(playerItemsOffered)
        let hostHostagesOffered:Int = Int(hostageNumber.text!)!
        print(hostHostagesOffered)

        let offer = Offer(playerOffers: game.selectedPlayerItems(itemsStringList: playerItemsOffered),
                          opponentOffers: game.selectedOpponentItems(itemsInt: hostHostagesOffered))
        
        print(offer.opponentOffers)
        print(offer.playerOffers)
        
        print(offer.getPlayerValue())
        print(offer.getOpponentValue())
        
        game.evaluateOffer(playerVal: offer.getPlayerValue(), hostVal: offer.getOpponentValue())
        
    }
    
    
}

