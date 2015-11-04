//
//  Problem.swift
//  RollTheBall
//
//  Created by Ahmed Elassuty on 11/3/15.
//  Copyright © 2015 Mohamed Diaa. All rights reserved.
//

import Foundation

class Problem {
    var operators: [Operator]!
    var initialState: [[Tile]]!
    var stateSpace: [String: [[Tile]]] = [String: [[Tile]]]()
    // path cost
    // goal test
    
    
    // Intializer
    init(grid: [[Tile]]){
        self.initialState = grid
    }
    
    func goalState(stateHashValue: String) -> Bool {
        assert(false, "This method must be overrided by the subclass")
    }
    
}