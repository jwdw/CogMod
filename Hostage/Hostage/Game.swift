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
    
    
    
    init() {
        initItems()
    }
    
    func initItems() {
        // List of Item Names for the Player
        let namesPlayerItems: [String] = ["Helicopter",
                                          "Bitcoin"]
        // Number of Hostages and total amount, the combined Items of each side are worth
        let noOfHostages: Int = 3
        let totalAmount: Int = 10000
        
        // Complex way of randomly assigning value to the Police's Items
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
        
        // Creation of playerItems
        for i in namesPlayerItems {
            self.playerItems.append(Item(name: i.lowercased(), displayName: i, value: itemsWorthDic[i]!))
        }
        
        // Creation of Hostages, each worth the same, in total worth as much as players Items(might change)
        for i in 0..<noOfHostages {
            self.opponentItems.append(Item(name: "hostage\(i)", displayName: "Hostage \(i)", value: Int(totalAmount / noOfHostages)))
        }
    }
    
//    func initPlayerItems() {
//        self.playerItems.append(Item(name: "helicopter", displayName: "Helicopter", value: 999))
//        self.playerItems.append(Item(name: "bitcoin", displayName: "Bitcoin", value: 12121))
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
    
    func evaluateOffer(playerVal: Int, hostVal: Int) -> String{
        // act r decides to accept or reject offer
        var response: String
        let relativeGainForActr: Double
        if playerVal != 0 {
            relativeGainForActr = Double(playerVal / hostVal)
        } else {
            relativeGainForActr = 0
        }
        if relativeGainForActr < 0.9 {
            response = "No way am I gonna accept this lame offer, dummies!"
        } else if relativeGainForActr <= 1.1 {
            response = "That seems fair"
        } else {
            response = "WUAHAHAHA You're so easy to beat"
        }
        return response
    }
    

}
