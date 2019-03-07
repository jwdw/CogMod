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
        initPlayerItems()
        initOpponentItems()
    }
    
    func initPlayerItems() {
        self.playerItems.append(Item(name: "helicopter", displayName: "Helicopter", value: 999))
        self.playerItems.append(Item(name: "bitcoin", displayName: "Bitcoin", value: 12121))
    }
    
    func initOpponentItems() {
        self.opponentItems.append(Item(name: "hostage1", displayName: "Hostage 1", value: 1))
        self.opponentItems.append(Item(name: "hostage2", displayName: "Hostage 2", value: 10000))
    }
    
    func evaluateOffer() {
        // act r decides to accept or reject offer
    }
    

}
