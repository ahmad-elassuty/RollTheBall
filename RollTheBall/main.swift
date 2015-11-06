//
//  main.swift
//  RollTheBall
//
//  Created by Mohamed Diaa on 10/27/15.
//  Copyright © 2015 Mohamed Diaa. All rights reserved.
//

import Foundation

let grid: [[Tile]] = genGrid()
search(grid, strategy: Strategy.GR_1, visualize: false, showGoalState: true)
search(grid, strategy: Strategy.A_Start, visualize: false)
search(grid, strategy: Strategy.BF, visualize: false)
search(grid, strategy: Strategy.DF, visualize: false)
search(grid, strategy: Strategy.ID, visualize: false)

