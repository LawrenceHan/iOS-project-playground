//
//  Puzzle.swift
//  Swift_algorithm
//
//  Created by Hanguang on 23/11/2016.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

enum Block {
    case White
    case Red
    case Blue
}

enum Direction: String {
    case Upward = "U"
    case Downward = "D"
    case Leftward = "L"
    case Rightward = "R"
}

final class Puzzle {
    let puzzleBegin = "wbrbbrbrrbrbbrbr"
    let puzzleEnd = "wbrbbrbrrbrbbrbr"
    
    let stepBegin: Int = 0
    let stepEnd: Int = 0
    let columnCount: Int = 4
    let rowCount: Int = 4
    
    var totalStepCount = 0
    var stepResults = [String]()
    fileprivate var routeList = [Route]()
    var routeCount: Int = 0
    var snapshots = [String : Int]()
    
    public func drawTable() {
        
    }
    
    public func calcuateShortestWay() {
        stepResults = [String]()
        routeCount = 0
        snapshots = [String : Int]()
        
        let route = Route(previousStep: stepBegin, nextStep: stepBegin, frame: puzzleBegin)
        
        routeList.insert(route, at: 0)
        routeCount += 1
        snapshots[route.frame] = route.stepsList.characters.count
        
        var found = false
        
        while found == false {
            var routesNext = [Route]()
            var routeIndexNext = 0;
            
            for index in 0..<routeCount {
                let routeOld = routeList[index]
                let previousStep = routeOld.previousStep
                
                let nextStep = previousStep - 4 // upward
                if nextStep >= 0 && nextStep != previousStep {
                    moveBlock(routeOld: routeOld, nextStep: nextStep, direction: .Upward,
                              routesNext: routesNext, routeIndexNext: &routeIndexNext)
                }
                
            }
        }
    }
    
    private func moveBlock(routeOld: Route, nextStep: Int, direction: Direction, routesNext: [Route], routeIndexNext: inout Int) {
        var routesNext = routesNext
        let routeNew = Route(previousStep: routeOld.nextStep, nextStep: nextStep, frame: "")
        routeNew.stepsList = routeOld.stepsList.appending(direction.rawValue)
        let frame = routeOld.frame as NSString
        let previousBlock = frame.character(at: routeNew.previousStep)
        let nextBlock = frame.character(at: routeNew.nextStep)
        frame.replacingCharacters(in: NSMakeRange(routeNew.previousStep, 1), with: String(nextBlock))
        routeNew.frame = frame.replacingCharacters(in: NSMakeRange(routeNew.nextStep, 1), with: String(previousBlock))
        
        if routeNew.frame.hashValue == puzzleEnd.hashValue {
            stepResults.append(routeNew.stepsList)
        }
        
        if snapshots[routeNew.frame] != nil {
            if snapshots[routeNew.frame]! < routeNew.stepsList.characters.count {
                return
            }
        } else {
            snapshots[routeNew.frame] = routeNew.stepsList.characters.count
        }
        routesNext[routeIndexNext] = routeNew
        routeIndexNext += 1
    }
}

private class Route {
    
    var previousStep: Int = 0
    var nextStep: Int = 0
    var frame: String
    var stepsList: String
    
    init(previousStep: Int, nextStep: Int, frame: String) {
        self.previousStep = previousStep;
        self.nextStep = nextStep
        self.frame = frame
        self.stepsList = ""
    }
    
    public var description: String {
        get {
            return NSString(string: stepsList).capitalized
        }
    }
}
