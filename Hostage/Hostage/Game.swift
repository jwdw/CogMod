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
    var available: Bool // traded or not
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
    var noOfHostagesLeft: Int = 0
    var model = Model()
    var dm = Declarative()
    var chunkNum = 0
    
    init() {
        initItems()
    }
    
    func initItems() {
        // List of Item Names for the Player
        let namesPlayerItems: [String] = ["Helicopter",
                                          "Getaway Car",
                                          "Bicycle",
                                          "Food",
                                          "Amphetamins",
                                          "Weaponry",
                                          "Bitcoin",
                                          "Granny's Watch",
                                          "Apple Stock",
                                          "Public Statement",
                                          "Retract Snipers",
                                          "Fair Trial"]
        
        let itemValues: [Int] = [10, 20, 50]
        
        // Number of Hostages and total amount, the combined Items of each side are worth
        noOfHostages = Int.random(in: 3 ... 10)
        noOfHostagesLeft = noOfHostages
        

        // Creation of playerItems
        for i in 0..<namesPlayerItems.count {
            self.playerItems.append(Item(name: namesPlayerItems[i].lowercased(), displayName: namesPlayerItems[i], value: itemValues[i%3], available: true))
        }
        
        // Creation of Hostages, each worth the same, in total worth as much as players Items(might change)
        for i in 0..<noOfHostages {
            self.opponentItems.append(Item(name: "hostage\(i)", displayName: "Hostage \(i)", value: 37, available: true))
        }
    }
    
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
    
    func evaluateOffer(offer: Offer) -> Deal{
        
        var currentFeedBackChunk: Chunk? = Chunk(s: "chunk" + String(chunkNum), m: model)
        currentFeedBackChunk?.setSlot(slot: "dasdf", value: "ewrqerewq")
        model.dm.addToDM(currentFeedBackChunk!)
        print(model.dm.chunks)
        print("hi")
        chunkNum += 1
        
        // act r decides to accept or reject offer
        let relativeGainForActr: Double
        if offer.getPlayerValue() != 0 && offer.getOpponentValue() != 0{
            relativeGainForActr = Double(offer.getPlayerValue() / offer.getOpponentValue())
        } else if offer.getOpponentValue() == 0 {
            relativeGainForActr = 999999
        } else {
            relativeGainForActr = 0
        }
        if relativeGainForActr < 0.9 {
            // TODO: make counteroffer
            return Deal(deal: false, response: "No way am I gonna accept this lame offer, dummies!")
        } else {
            makeDeal(offer: offer)
            return Deal(deal: true, response: "That seems fair")
        }
    }
    
    
    func makeDeal(offer: Offer) {
        // Update values
        for playerIdx in 0..<playerItems.count {
            for offeredIdx in 0..<offer.playerOffers.count {
                if playerItems[playerIdx].name == offer.playerOffers[offeredIdx].name {
                    playerItems[playerIdx].available = false
                }
            }
        }
        
        for opponentIdx in 0..<opponentItems.count {
            for offeredIdx in 0..<offer.opponentOffers.count {
                if opponentItems[opponentIdx].name == offer.opponentOffers[offeredIdx].name {
                    opponentItems[opponentIdx].available = false
                    noOfHostagesLeft -= 1
                }
            }
        }
    }
    
    func getPlayerScore() -> Int {
        var value: Int = 0
        for item in playerItems {
            if !item.available {
                value -= item.value
            }
        }
        for item in opponentItems {
            if !item.available {
                value += item.value
            }
        }
        return value
    }
    
    func getOpponentScore() -> Int {
        var value: Int = 0
        for item in playerItems {
            if !item.available {
                value += item.value
            }
        }
        for item in opponentItems {
            if !item.available {
                value -= item.value
            }
        }
        return value
    }
}
