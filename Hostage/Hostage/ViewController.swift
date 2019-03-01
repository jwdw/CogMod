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

    @IBOutlet weak var Text: UITextView!
    @IBAction func Test(_ sender: Any) {
        print("hello")
        Text.text = "fasdfsdf"
    }
    
}

