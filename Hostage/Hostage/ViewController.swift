//
//  ViewController.swift
//  Hostage
//
//  Created by J.W. de Wit on 01/03/2019.
//  Copyright © 2019 J.W. de Wit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    struct bargainingItem {
        var name 
    }
    
    var offers: [String] = []
    
    @IBOutlet weak var offer: UITextView!
    @IBAction func offerButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    func updateOffers() {
        print(" hdafadsfadsf " )
    }
}

