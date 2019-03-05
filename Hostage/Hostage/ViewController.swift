//
//  ViewController.swift
//  Hostage
//
//  Created by J.W. de Wit on 01/03/2019.
//  Copyright © 2019 J.W. de Wit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    var offers: [String] = []
    
    @IBOutlet weak var offer: UITextView!
    @IBAction func offerButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        updateOffers()
    }
    
    func updateOffers() {
        print(" hdafadsfadsf " )
        model.hi()
    }
}

