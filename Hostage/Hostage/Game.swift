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
    var opponentValue: Int
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
            value += item.opponentValue
        }
        return value
    }
}



class Game {
    var playerItems :[Item] = []
    var opponentItems :[Item] = []
    var totalHostages: Int
    var hostagesLeft: Int = 0
    var hostagesSaved: Int = 0
    var hostagesKilled: Int = 0
    var model = Model()
//    var dm = Declarative()
    var chunkNum = 0
    var currentChunks :[Chunk] = []
    var numTurns = 0
    var gracePeriod = 3
    
    var endScore = 0

    
    init(hosNum: Int) {
        
        totalHostages = hosNum
        hostagesLeft = totalHostages
        initItems()
    }
    
    func initItems() {
        // List of Item Names for the Player
        let namesPlayerItems: [String] = ["Bicycle",
                                          "Getaway Car",
                                          "Helicopter",
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
        let opponentItemValues: [Int] = itemValues.shuffled() + itemValues.shuffled() + itemValues.shuffled() + itemValues.shuffled()

        // Creation of playerItems
        for i in 0..<namesPlayerItems.count {
            self.playerItems.append(Item(name: namesPlayerItems[i].lowercased(), displayName: namesPlayerItems[i], value: itemValues[i%3], opponentValue: opponentItemValues[i], available: true))
        }
        
        // Creation of Hostages, each worth the same
        for i in 0..<totalHostages {
            self.opponentItems.append(Item(name: "hostage\(i)", displayName: "Hostage \(i)", value: 37, opponentValue: 37, available: true))
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
        var relativeGainForActr: Double
        print(offer.getPlayerValue())
        print(offer.getOpponentValue())
        relativeGainForActr = Double(offer.getPlayerValue()) / Double(offer.getOpponentValue())
        print(relativeGainForActr)

        
        // retrieve chunk
        let offerChunk: Chunk = Chunk(s: "", m: Model())
        offerChunk.setSlot(slot: "value", value: relativeGainForActr)
        offerChunk.setSlot(slot: "score", value: 9999)
        
        func masmitch(_: Value, _: Value) -> Double? {
            return 0.0
        }
        
        let chunk = model.dm.blendedPartialRetrieve(chunk: offerChunk, mismatchFunction: masmitch)
        
        
        
        
        model.time += 2
        
        // create feedback chunk
        var currentFeedBackChunk: Chunk? = Chunk(s: "chunk" + String(chunkNum), m: model)
        currentFeedBackChunk?.setSlot(slot: "value", value: relativeGainForActr)
        
        chunkNum += 1
        
        // act r decides to accept or reject offer
        if offer.getPlayerValue() != 0 && offer.getOpponentValue() != 0{
            relativeGainForActr = Double(offer.getPlayerValue() / offer.getOpponentValue())
        } else if offer.getOpponentValue() == 0 {
            relativeGainForActr = 999999
        } else {
            relativeGainForActr = 0
        }
        if chunk.1 != nil {
            switch chunk.1!.slotValue(slot: "decision")! {
            case .Text("reject"):
                print("fuck swift")
                currentFeedBackChunk?.setSlot(slot: "decision", value: "reject")
                currentChunks.append(currentFeedBackChunk!)
                return Deal(deal: false, response: "No way am I gonna accept this lame offer, dummies!")
            case .Text("accept"):
                makeDeal(offer: offer)
                currentFeedBackChunk?.setSlot(slot: "decision", value: "accept")
                currentChunks.append(currentFeedBackChunk!)
                return Deal(deal: true, response: "That seems fair")
                
            default:
                currentFeedBackChunk?.setSlot(slot: "decision", value: "reject")
                currentChunks.append(currentFeedBackChunk!)
                return Deal(deal: false, response: "I can't remember anything, but this will never happen anyway")
            
            }
        } else {
            if Float.random(in: 0..<1) > 0.5 {
                currentFeedBackChunk?.setSlot(slot: "decision", value: "reject")
                currentChunks.append(currentFeedBackChunk!)
                return Deal(deal: false, response: "I can't remember anything")
            } else {
                makeDeal(offer: offer)
                currentFeedBackChunk?.setSlot(slot: "decision", value: "accept")
                currentChunks.append(currentFeedBackChunk!)
                return Deal(deal: true, response: "I can't remember anything" )
            }
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
                    hostagesLeft -= 1
                    hostagesSaved += 1
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
    
    func getPrefs() -> String {
        var prefs: [String] = []
        for item in playerItems {
            if item.opponentValue == 50 {
                prefs.append(item.displayName)
            }
        }
        return prefs.shuffled()[0]
    }
    
    func teachAI() {
        for chunk in currentChunks {
            chunk.setSlot(slot: "score", value: String(endScore))
            model.dm.addToDM(chunk)
        }
    }
    
    func gameEnd() {
        // add end score to chunk
        // reset game
    }
    
}
