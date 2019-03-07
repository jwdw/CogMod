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
    @IBAction func itemButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBOutlet weak var hostageNumber: UILabel!
    @IBAction func stepper(_ sender: UIStepper) {
        hostageNumber.text = Int(sender.value).description
    }
    
    @IBOutlet weak var itemButtonView: UIView!
    @IBAction func offerButton(_ sender: Any) {
        for case let button as UIButton in itemButtonView.subviews {
            if button.isSelected {
                print(button.currentTitle)
            }
          
        }
    }
    
    
}

