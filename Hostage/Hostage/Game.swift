//
//  Model.swift
//  Hostage
//
//  Created by J.W. de Wit on 05/03/2019.
//  Copyright © 2019 J.W. de Wit. All rights reserved.
//

import Foundation

struct Item {
    var name: String
    var displayName: String
    var value: Int
}

struct Deal {
    var deal: Bool
    var response: String
}

class Offer {
    var playerOffers :[Item] = []
    var opponentOffers :[Item] = []
    
    init(playerOffers: [Item], opponentOffers: [Item]) {
        self.playerOffers = playerOffers
        self.opponentOffers = opponentOffers
    }
    
    func getPlayerValue() -> Int {
        var value: Int = 0
        for item in self.playerOffers {
            value += item.value
        }
        return value
    }
    
    func getOpponentValue() -> Int {
        var value: Int = 0
        for item in self.opponentOffers {
            value += item.value
        }
        return value
    }
}



class Game {
    var playerItems :[Item] = []
    var opponentItems :[Item] = []
    var noOfHostages: Int = 0
    
    init() {
        initItems()
    }
    
    func initItems() {
        // List of Item Names for the Player
        let namesPlayerItems: [String] = ["Helicopter",
                                          "Bitcoin",
                                          "Bicycle",
                                          "Getaway Car",
                                          "Amphetamins",
                                          "Food",
                                          "Weaponry",
                                          "Apple Stock",
                                          "Fair Trial",
                                          "Granny's Watch",
                                          "Retract Snipers",
                                          "Public Statement"]
        
        let itemValues: [Int] = [100, 50, 20, 50, 20, 10, 20, 70, 60, 100, 70, 20]
        
        // Number of Hostages and total amount, the combined Items of each side are worth
        noOfHostages = Int.random(in: 3 ... 10)
        let totalAmount: Int = Int(itemValues.reduce(0, +) / 2)
        print(totalAmount)
        
        // Complex way of randomly assigning value to the Police's Items
        /*
        var worthPlayerItems: [Double] = []
        for i in 0..<namesPlayerItems.count {
            worthPlayerItems.append(Double.random(in: 0..<1))
        }
        let totalWorth: Double = worthPlayerItems.reduce(0, +)
        
        var itemsWorthDic: [String:Int] = [:]
        for i in 0..<namesPlayerItems.count {
            let tempValue: Double = worthPlayerItems[i] / totalWorth * Double(totalAmount)
            itemsWorthDic[namesPlayerItems[i]] = Int(tempValue.rounded())
        }
        */
        // Creation of playerItems
        for i in 0..<namesPlayerItems.count {
            self.playerItems.append(Item(name: namesPlayerItems[i].lowercased(), displayName: namesPlayerItems[i], value: itemValues[i]))
        }
        
        // Creation of Hostages, each worth the same, in total worth as much as players Items(might change)
        for i in 0..<noOfHostages {
            self.opponentItems.append(Item(name: "hostage\(i)", displayName: "Hostage \(i)", value: Int(totalAmount / noOfHostages)))
        }
    }
    
//    func initPlayerItems() {
//       self.playerItems.append(Item(name: "helicopter", displayName: "Helicopter", value: 999))
//       self.playerItems.append(Item(name: "bitcoin", displayName: "Bitcoin", value: 12121))
//    }
//
//    func initOpponentItems() {
//        self.opponentItems.append(Item(name: "hostage1", displayName: "Hostage 1", value: 1))
//        self.opponentItems.append(Item(name: "hostage2", displayName: "Hostage 2", value: 10000))
//    }
    
    // Loops through items to add all selected items, returns as list
    func selectedPlayerItems(itemsStringList: [String]) -> [Item] {
        var currentPlayerItems: [Item] = []
        for i in self.playerItems {
            if itemsStringList.contains(i.name) {
                currentPlayerItems.append(i)
            }
        }
        return currentPlayerItems
    }
    
    // Takes as many hostage-items as indicated, in order of the opponentItem-list
    func selectedOpponentItems(itemsInt: Int) -> [Item] {
        var currentOpponentItems: [Item] = []
        for i in 0..<itemsInt {
            currentOpponentItems.append(self.opponentItems[i])
        }
        return currentOpponentItems
    }
    
    func evaluateOffer(playerVal: Int, hostVal: Int) -> Deal{
        // act r decides to accept or reject offer
        var response: String
        let relativeGainForActr: Double
        if playerVal != 0 {
            relativeGainForActr = Double(playerVal / hostVal)
        } else {
            relativeGainForActr = 0
        }
        if relativeGainForActr < 0.9 {
            // TODO: make counteroffer
            return Deal(deal: false, response: "No way am I gonna accept this lame offer, dummies!")
        } else {
            makeDeal()
            return Deal(deal: true, response: "That seems fair")
        }
    }
    
    
    func makeDeal() {
        // Update values
    }
}
