//
//  Tile.swift
//  RollTheBall
//
//  Created by Ahmed Elassuty on 10/27/15.
//  Copyright © 2015 Mohamed Diaa. All rights reserved.
//

import Foundation

//typealias Location = (row: Int!, col: Int!)

struct Location {
    var row: Int!
    var col: Int!
    
    init(row: Int!, col: Int!){
        self.row = row
        self.col = col
    }
    
    func equal(location: Location) -> Bool {
        if self.row == location.row && self.col == self.col {
            return true
        }
        return false
    }
    
    func translate(factor: Location) -> Location {
        return Location(row: self.row + factor.row, col: self.col + factor.col)
    }
    
    func withInRange(row: Int, col: Int) -> Bool {
        if self.row < 0 || self.row >= row || self.col < 0 || self.col >= col {
            return false
        }
        return true
    }
}

class Tile {
    // Instance properties
    var location: Location!
    var fixed = false
    var isEmpty = true

    // Initializers
    init(){}

    init(row: Int, col: Int, isEmpty: Bool = false, fixed: Bool = false){
        location = Location(row: row, col: col)
        self.fixed = fixed
        self.isEmpty = isEmpty
    }

    init(location: Location, isEmpty: Bool = false, fixed: Bool = false){
        self.location = location
        self.fixed = fixed
        self.isEmpty = isEmpty
    }
    
    func getLocationForEdge(boardlimits: Location, exitEdge: Edge) -> Location? {
        var location: Location!
        switch exitEdge {
        case .Right:
            location = Location(row: self.location.row, col: self.location.col + 1)
        case .Left:
            location = Location(row: self.location.row, col: self.location.col - 1)
        case .Top:
            location = Location(row: self.location.row - 1, col: self.location.col)
        case .Bottom:
            location = Location(row: self.location.row + 1, col: self.location.col)
        }

        if location.row < 0 || location.col < 0 || location.row == boardlimits.row || location.col == boardlimits.col {
            return nil
        }

        return location
    }
}

class BlankTile: Tile {}