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

struct Chunky {
    var score: Int = 0
    var value: Double = 0
    var decision: String = ""
    //TODO: activation/forgetting
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
    var memory : [Chunky] = []
//    var dm = Declarative()
    var chunkNum = 0
    var currentChunks :[Chunky] = []
    var numTurns = 0
    var gracePeriod = 3
    
    init(hosNum: Int) {
        
        totalHostages = hosNum
        hostagesLeft = totalHostages
        
        // Then reading it back from the file
        print("reading from file")
        let fileName = "chunkies1"
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)
        
        // If the directory was found, we write a file to it and read it back
        if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            
            var inString = ""
            do {
                inString = try String(contentsOf: fileURL)
            } catch {
                print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            }
            
            let chunkies = inString.components(separatedBy: "\n")
            for chunky in chunkies.dropLast() {
                let values = chunky.components(separatedBy: ",")
                memory.append(Chunky(score: Int(values[0])!, value: Double(values[1])!, decision: values[2]))
            }
            print(memory.count)
        }
        

        
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
        relativeGainForActr = Double(offer.getPlayerValue()) / Double(offer.getOpponentValue())
        
        var min_dist = 99999999999.0
        var best_decision = ""
        for chunk in memory {
            var distance = pow(chunk.value - relativeGainForActr, 2)
            distance += pow(Double(chunk.score - 9999), 2)
            if distance < min_dist {
                min_dist = distance
                best_decision = chunk.decision
                //TODO: decide whether chunk is similar enough, so that random actions can be chosen sometimes
            }
        }
        
        var feedbackChunk: Chunky = Chunky(score: 0, value: relativeGainForActr, decision: "")
        
        chunkNum += 1
        
        if Float.random(in: 0..<1) > (1 / Float(memory.count)) { // as the memory grows bigger, chance of random action decreases
            switch best_decision {
            case "reject":
                feedbackChunk.decision = "reject"
                currentChunks.append(feedbackChunk)
                return Deal(deal: false, response: "No way am I gonna accept this lame offer, dummies!")
            case "accept":
                makeDeal(offer: offer)
                feedbackChunk.decision = "accept"
                currentChunks.append(feedbackChunk)
                return Deal(deal: true, response: "That seems fair")
            default:
                return(Deal(deal: true, response: "this will never happen"))
            }
        } else { // random action
            if Float.random(in: 0..<1) > 0.5 {
                feedbackChunk.decision = "reject"
                currentChunks.append(feedbackChunk)
                return Deal(deal: false, response: "I don't think so.")
            } else {
                makeDeal(offer: offer)
                feedbackChunk.decision = "accept"
                currentChunks.append(feedbackChunk)
                return Deal(deal: true, response: "Sure, why not?" )
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
        var itemEx = 0
        for i in playerItems{
            if i.available == false {
                itemEx += i.value
            }
        }
        let opponentScore = (320 / hostageNum) * -hostagesSaved + (hostagesLeft * 25) + (hostagesKilled * -80) + itemEx
        
        print(opponentScore)
        
        for chunk in currentChunks {
            var chunk_copy = chunk
            chunk_copy.score = opponentScore
            memory.append(chunk_copy)
        }
    
        print(memory)
        
        print("writing to file")
        let fileName = "chunkies1"
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)
        
        // If the directory was found, we write a file to it and read it back
        if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
            
            // Write to the file named Test
            var outString = ""
            for chunk in memory {
                outString.append(String(chunk.score))
                outString.append(",")
                outString.append(String(chunk.value))
                outString.append(",")
                outString.append(chunk.decision)
                outString.append("\n")
            }
            
            do {
                try outString.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
        }
    }
    
    func gameEnd() {
        // TODO: CALCULATE AND ADD END SCORE
    }
    
}
