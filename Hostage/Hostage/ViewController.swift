//
//  ViewController.swift
//  Hostage
//
//  Created by J.W. de Wit on 01/03/2019.
//  Copyright © 2019 J.W. de Wit. All rights reserved.
//

import UIKit
import AVFoundation

var hostageNum = 7
var testScore = 0
var killedHostages = 0

class StartViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var audioPlayer = AVAudioPlayer()
    
    func playSound(file:String, ext:String, loops:Int) -> Void {
        do {
            let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: file, ofType: ext)!)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = loops
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playSound(file: "hostage_soundtrack", ext: ".wav", loops: -1)
    }
    
    private let aggressOptions = ["Low", "Normal", "High"]
    
    @IBOutlet weak var audioOnOff: UIButton!
    var audioTrack = true
    @IBAction func audioSwitch(_ sender: Any) {
        audioTrack = !audioTrack
        if audioTrack == true {
            audioOnOff.setTitle("🔈", for: .normal)
            playSound(file: "hostage_soundtrack", ext: ".wav", loops: -1)
        } else {
            audioOnOff.setTitle("🔇", for: .normal)
            audioPlayer.stop()
        }
    }
    
    
    @IBOutlet weak var instructionButton: UIButton!
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
    
    @IBAction func infoScreenFunc(_ sender: Any) {
        performSegue(withIdentifier: "infoSegue", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "startSegue"){
            let displayVC = segue.destination as! ViewController
            
            displayVC.audioIdent = audioTrack
        }
    }
    
}

class ViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let game = Game(hosNum: hostageNum)
    
    var audioIdent: Bool!
    
    @IBOutlet weak var playerScore: UITextView!
    @IBOutlet weak var opponentScore: UITextView!
    @IBOutlet weak var hostageEmojis: UILabel!
    @IBOutlet weak var feedbackTextField: UITextView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var totalHostageNum: UITextView!
    
    @IBOutlet weak var offerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        stepper.maximumValue = Double(game.totalHostages)
        totalHostageNum.text = String(game.opponentItems.count)
        playerScore.text = String(game.getPlayerScore())
        opponentScore.text = String(game.getOpponentScore())
        feedbackTextField.text = "I want " + game.getPrefs().lowercased() + " or heads are gonna roll!"
        hostageEmojis.text = String(repeating: "😳", count: game.opponentItems.count)
        
    }
    
    var audioPlayer2 = AVAudioPlayer()
    func playSound(file:String, ext:String, loops:Int) -> Void {
        do {
            let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: file, ofType: ext)!)
            audioPlayer2 = try AVAudioPlayer(contentsOf: url)
            audioPlayer2.numberOfLoops = loops
            audioPlayer2.prepareToPlay()
            audioPlayer2.play()
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
    
    let freeSounds:[String] = ["free1",
                                 "free2",
                                 "free3",
                                 "free4",
                                 "free5"]
    
    let dieSounds:[String] = ["die1",
                              "die2",
                              "die3",
                              "die4",
                              "die5",
                              "die6"]
    
    func soundEffect(death: Bool) {
        if death == true {
            playSound(file: dieSounds.shuffled()[0], ext: ".wav", loops: 0)
        } else {
            playSound(file: freeSounds.shuffled()[0], ext: ".wav", loops: 0)
        }
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
        
        print(offer.playerOffers)
        
        let response = game.evaluateOffer(offer: offer)
        
        updateResponse(response: response.response)
        
        if response.deal {
            updateUIAfterOffer()
        } else {
            if game.gracePeriod == 1 {
                killHostage()
                feedbackTextField.text.append(" I killed a hostage MUHAHAHAHAHA! \(game.prefAfterOffer(currOffer: offer))")
            } else {
                game.gracePeriod -= 1
                feedbackTextField.text.append(" I will kill a hostage in " + String(game.gracePeriod) + " turns if you don't make a better offer! \(game.prefAfterOffer(currOffer: offer))")
            }
        }
        game.numTurns += 1
    }
    
    func killHostage() {
        soundEffect(death: true)
        game.hostagesLeft -= 1
        game.hostagesKilled += 1
        totalHostageNum.text = String(game.hostagesLeft)
        
        hostageEmojis.text = String(repeating: "☠️", count: game.hostagesKilled) + String(repeating: "😄", count: game.hostagesSaved) + String(repeating: "😳", count: game.hostagesLeft)
        
        if Int(totalHostageNum.text) == 0 {
            performSegue(withIdentifier: "endSegue", sender: self)
        }
        
        if(Int(hostageNumber.text!)! > game.hostagesLeft) {
            stepper.maximumValue = Double(game.hostagesLeft)
            stepper.value -= 1
            hostageNumber.text = String(game.hostagesLeft)
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
        soundEffect(death: false)
        var totalItemNum: Int = 12
        for case let button as UIButton in itemButtonView.subviews {
            for playerItem in game.playerItems {
                if button.titleLabel!.text!.lowercased().contains(playerItem.name) {
                    if !playerItem.available {
                        button.isEnabled = false
                        button.isSelected = false
                        totalItemNum -= 1
                    }
                }
            }
        }
        totalHostageNum.text = String(game.hostagesLeft)
        stepper.maximumValue = Double(game.hostagesLeft)
        stepper.value = 0.0
        hostageNumber.text = "0"
        
        playerScore.text = String(game.getPlayerScore())
        opponentScore.text = String(game.getOpponentScore())
        offerButton.isEnabled = false
        
        hostageEmojis.text = String(repeating: "☠️", count: game.hostagesKilled) + String(repeating: "😄", count: game.hostagesSaved) + String(repeating: "😳", count: game.hostagesLeft)
        

        if Int(totalHostageNum.text) == 0 || totalItemNum < 1{
            print("hello I'm gonna do teachAI")
            game.teachAI()
            performSegue(withIdentifier: "endSegue", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "endSegue"){
            let displayVC = segue.destination as! EndViewController
            
            displayVC.hostSav = game.hostagesSaved
            displayVC.hostLef = game.hostagesLeft
            displayVC.hostLos = game.hostagesKilled
            displayVC.hosTot = game.totalHostages
            
            
            var itemScoreTracker = 0
            var numItems = 0
            for i in game.playerItems{
                if i.available == false {
                    itemScoreTracker += i.value
                    numItems += 1
                }
            }
            displayVC.itemEx = itemScoreTracker
            displayVC.numItemsEx = numItems
        }
    }
    
   
}

class EndViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var hosTot: Int!
    var hostSav: Int!
    var hostLef: Int!
    var hostLos: Int!
    var itemEx: Int!
    var numItemsEx: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        func scoreColoring (label: UILabel, zero: UIColor) {
            if Int(label.text!)! > 0 {
                label.textColor = UIColor.green
            } else if Int(label.text!)! == 0{
                label.textColor = zero
            } else {
                label.textColor = UIColor.red
            }

        }
        
        hostSavNum.text = String(hostSav)
        hostSavSco.text = String((320 / hosTot) * hostSav)
        scoreColoring(label: hostSavSco, zero: UIColor.red)
        hostLefNum.text = String(hostLef)
        hostLefSco.text = String(hostLef * -25)
        scoreColoring(label: hostLefSco, zero: UIColor.green)
        hostLosNum.text = String(hostLos)
        hostLosSco.text = String(hostLos * -80)
        scoreColoring(label: hostLosSco, zero: UIColor.green)
        itemExNum.text = String(numItemsEx)
        itemExSco.text = String(-itemEx)
        scoreColoring(label: itemExSco, zero: UIColor.green)
        totalScore.text = String((320 / hosTot) * hostSav + (hostLef * -25) + (hostLos * -80) + -itemEx)
        scoreColoring(label: totalScore, zero: UIColor.yellow)
        
        emojiEndScore.text = String(repeating: "☠️", count: hostLos) + String(repeating: "😄", count: hostSav) + String(repeating: "☹️", count: hostLef)
        
        
    }
    
    @IBOutlet weak var hostSavNum: UILabel!
    @IBOutlet weak var hostSavSco: UILabel!
    @IBOutlet weak var hostLefNum: UILabel!
    @IBOutlet weak var hostLefSco: UILabel!
    @IBOutlet weak var hostLosNum: UILabel!
    @IBOutlet weak var hostLosSco: UILabel!
    @IBOutlet weak var itemExNum: UILabel!
    @IBOutlet weak var itemExSco: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var emojiEndScore: UILabel!
    
    
    @IBAction func backMenu(_ sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    
    
}

class InfoViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        playSound(file: "instructions", ext: ".wav", loops: 0)
        
        }
    
    var anotherAudioPlayer = AVAudioPlayer()
    
    func playSound(file:String, ext:String, loops:Int) -> Void {
        do {
            let url = URL.init(fileURLWithPath: Bundle.main.path(forResource: file, ofType: ext)!)
            anotherAudioPlayer = try AVAudioPlayer(contentsOf: url)
            anotherAudioPlayer.numberOfLoops = loops
            anotherAudioPlayer.prepareToPlay()
            anotherAudioPlayer.play()
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
    
    
    @IBOutlet weak var backMenuButton: UIButton!
    @IBAction func backMenu(_ sender: Any) {
        anotherAudioPlayer.stop()
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
}
