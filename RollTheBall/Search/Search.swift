//
//  Generic.swift
//  RollTheBall
//
//  Created by Ahmed Elassuty on 11/3/15.
//  Copyright © 2015 Mohamed Diaa. All rights reserved.
//

import Foundation

/*
This file contains the implementation of

- Search Method as required
- General search algorithm:
    - With different configurations to
    be used with different search strategies
    - different configurations -> to limit checking unneeded conditions
        that are not compatable with different strategies
- Best first search for Greedy and A* strategies
- Blind search algorithms required
- Informed search algorithms required
*/

// variable represents number of dequeued nodes
var numberOfExaminedNodes: Int = 0

// variable represents number of nodes chosed for expansion
var numberOfNodesExpanded: Int = 0

// keep track of the dequeued nodes references
// used to log each node examined by any search algorithm
var dequeuedNodes: [Node] = []

// keep track of iterative deepning generated sub problems
var iterativeDeepingSubProblems: [Problem] = []

// keeps track if we can expand more or not
// if true iterative deepening will halt execution
var iterativeDeepingStopFlag: Bool = false

// enumeratur for different search strategies implemented
enum Strategy: Int {
    case BF, DF, ID, GR_1, GR_2, A_Start
}


// main search function
/* Inputs in order:
- grid: 2d array of tiles
- strategy: search strategy to be used
- visualize: boolean value indicates whether to print the correct path
or not (if any was discovered)
- showStep: boolean value indicates whether to print the board
in the console as it undergoes different states
*/
func search(grid: [[Tile]], strategy: Strategy, visualize: Bool, showStep: Bool = false, showGoalState: Bool = false){
    // reset variables
    numberOfExaminedNodes = 0
    numberOfNodesExpanded = 0
    dequeuedNodes = []
    iterativeDeepingSubProblems = []
    iterativeDeepingStopFlag = false

    let problem = RollTheBall(grid: grid)
    let result: Node?
    switch strategy {
    case .BF:
        result = breadthFirst(problem)
    case .DF:
        result = depthFirstSearch(problem)
    case .ID:
        result = iterativeDeepening(grid)
    case .GR_1:
        result = greedySearch(problem, heuristicFunc: greedyHeuristicFunc1)
    case .GR_2:
        result = greedySearch(problem, heuristicFunc: greedyHeuristicFunc2)
    case .A_Start:
        result = aStartSearch(problem, heuristicFunc: aStarHeuristicFunc)
    }
    
    // Output
    if visualize {
        if result != nil {
            print("--------------- Correct path ---------------")
            if strategy == .ID {
                correctPath(iterativeDeepingSubProblems.last!, node: result!)
            } else {
                print(result?.hValue)
                correctPath(problem, node: result!)
            }
        }
    }
    
    if (showStep){
        if strategy == .ID {
            for subProblem in iterativeDeepingSubProblems {
                stepTrack(subProblem)
            }
        } else {
            stepTrack(problem)
        }
    }
    
    
    print("Search Strategy applied      = \(strategy)")
    if result == nil {
        print(" No Solution")
    } else {
        if (showGoalState){
            print("-----------------The Solution ----------------------------")
            visualizeBoard(problem.stateSpace[result!.state]!)
        }
    }
    print("--------------- Cost of the solution ---------------")
    print("Cost = \(numberOfExaminedNodes)")

    print("--------------- Number of nodes chosen for expansion ---------------")
    print("Number of Nodes expaneded \(numberOfNodesExpanded)")
    print("--------------------------------------------------------------------")
}

// visualizes the dequeued nodes by any search strategy
func stepTrack(problem: Problem){
    for node in dequeuedNodes {
        visualizeBoard(problem.stateSpace[node.state]!)
    }
}

// recursive function visualizes the correct path
// by back tracking the parents of the goal node
// return by any strategy
func correctPath(problem: Problem, node: Node?){
    if node!.parentNode == nil {
        print("Initial Grid :")
        return visualizeBoard(problem.stateSpace[node!.state]!)
    }
    
    correctPath(problem, node: node!.parentNode!)
    print("Action: move node at \(node!.action?.move.inverse().apply((node!.action?.location)!).toString()) to \(node!.action?.location.toString())")
    return visualizeBoard(problem.stateSpace[node!.state]!)
}



// Search Algorithms

/*
All search methods returns a goal node or nil
node: as a goal node
nil: if no solution found

General search method compatable with search algorithms (BF, DF)
inputs:
    problem    : problem to be proccessed
    enqueueFunc: function specifies the insertion policy of the main queue
*/
private func generalSearch(problem: Problem, enqueueFunc: [Node] -> Int) -> Node? {
    // hash the initialState
    let initialStateHashValue = hashGrid(problem.initialState)

    // create initialNode for the initialState
    let initialNode: Node = Node(parentNode: nil, state: initialStateHashValue, depth: 0, pathCost: 0, hValue: nil, action: nil)
    
    // create processing queue
    let nodes = Queue<Node>(data: initialNode)
    while !nodes.isEmpty {
        let node = nodes.dequeue()
        dequeuedNodes.append(node)
        numberOfExaminedNodes++
        if problem.goalState(node.state) {
            return node
        }
        // expand next level of the current node
        // and add the expanded nodes to the queue
        nodes.enqueue(node.expand(problem), insertionFunc: enqueueFunc)
        numberOfNodesExpanded++
    }

    return nil
}

// Breadth first search
// defines insert last function for the newly expanded nodes
private func breadthFirst(problem: Problem) -> Node? {
    return generalSearch(problem, enqueueFunc: enqueueLast)
}

// Depth first search
// defines insert first function for the newly expanded nodes
private func depthFirstSearch(problem: Problem) -> Node? {
    return generalSearch(problem, enqueueFunc: enqueueFirst)
}

// General search function for search algorithms with limited depth
/*inputs:
    problem    : problem to be proccessed
    enqueueFunc: function specifies the insertion policy of the main queue
    maxDepth: maximum depth of expansion
*/
private func generalSearch(problem: Problem, enqueueFunc: [Node] -> Int, maxDepth: Int) -> Node? {
    // hash the initialState
    let initialStateHashValue = hashGrid(problem.initialState)

    // create initialNode for the initialState
    let initialNode: Node = Node(parentNode: nil, state: initialStateHashValue, depth: 0, pathCost: 0, hValue: nil, action: nil)
    
    // create processing queue
    let nodes = Queue<Node>(data: initialNode)
    while !nodes.isEmpty {
        let node = nodes.dequeue()
        dequeuedNodes.append(node)
        numberOfExaminedNodes++
        if problem.goalState(node.state) {
            return node
        }
        // expand next level of the current node
        // and add the expanded nodes to the queue
        if node.depth < maxDepth {
            let expandedNodes: [Node] = node.expand(problem)
            if expandedNodes.count == 0 && nodes.isEmpty {
                // cannot expand more
                // and the main queue is already empty
                // stop iterative deeping search
                
                iterativeDeepingStopFlag = true
            }
            nodes.enqueue(expandedNodes, insertionFunc: enqueueFunc)
            numberOfNodesExpanded++
        }
    }
    return nil
}

// Depth limited search
private func depthLimitedSearch(problem: Problem, depth: Int) -> Node? {
    return generalSearch(problem, enqueueFunc: enqueueFirst, maxDepth: depth)
}

// Iterative deepening search
private func iterativeDeepening(grid: [[Tile]]) -> Node? {
    for var depth = 0; !iterativeDeepingStopFlag; depth++ {
        let problem = RollTheBall(grid: grid)
        iterativeDeepingSubProblems.append(problem)
        if let result = depthLimitedSearch(problem, depth: depth){
            return result
        }
    }
    return nil
}

// general search function for search algorithms with heuristic function
/* inputs:
        problem: to be processed
        evalFunc: (pathcost + huristic value) for A* 
            or huristic value only for greedy
        heuristicFunc: the heuristic function to be applied to new nodes
*/
private func generalSearch(problem: Problem, evalFunc: Node -> Int, heuristicFunc: [[Tile]] -> Int) -> Node? {
    // hash the initialState
    let intialStateHashValue = hashGrid(problem.initialState)
    
    // Add it to the stateSpace
    problem.stateSpace[intialStateHashValue] = problem.initialState
    
    // create initialNode for the initialState
    let initialNode: Node = Node(parentNode: nil, state: intialStateHashValue, depth: 0, pathCost: 0, hValue: nil, action: nil)
    
    // create processing queue
    var nodes = Queue<Node>(data: initialNode)
    
    while !nodes.isEmpty {
        let node = nodes.dequeue()
        dequeuedNodes.append(node)
        numberOfExaminedNodes++
        if problem.goalState(node.state) {
            return node
        }
        // expand next level of the current node
        // and add the expanded nodes to the queue
        nodes.enqueue(node.expand(problem, heuristicFunc: heuristicFunc), insertionFunc: enqueueInIncreasingOrder, evalFunc: evalFunc)
        numberOfNodesExpanded++
    }
    return nil
}

// Greedy search
// takes the huristic function to be applied
private func greedySearch(problem: Problem, heuristicFunc: [[Tile]] -> Int) -> Node? {
    // function to define the attributes of a node
    // to be evaluated on, when inserted to the main queue
    func greedyEvalFunc(node: Node) -> Int {
        return node.hValue!
    }

    return generalSearch(problem, evalFunc: greedyEvalFunc, heuristicFunc: heuristicFunc)
}

// A* search
// takes the huristic function to be applied
private func aStartSearch(problem: Problem, heuristicFunc: [[Tile]] -> Int) -> Node? {
    // function to define the attributes of a node
    // to be evaluated on, when inserted to the main queue
    func A_StarEvalFunc(node: Node) -> Int {
        return node.hValue! + node.pathCost!
    }

    return generalSearch(problem, evalFunc: A_StarEvalFunc, heuristicFunc: heuristicFunc)
}

// Heuristic Functions
func greedyHeuristicFunc1(grid: [[Tile]]) -> Int {
    let pathsWalked =  movedPathLocations(grid)
    let targetEdge = pathsWalked.1
    var targetLocation: Location? = pathsWalked.0.first!.translate(targetEdge.translationFactor())
    if !targetLocation!.withInRange(grid.count, col: grid.first!.count){
        targetLocation = nil
    }
    let value : Int =  pathToGoal(grid, targetLocation: targetLocation, pathLocations: pathsWalked.0)
    return value
}

func greedyHeuristicFunc2(grid: [[Tile]]) -> Int {
    return 0
}

func aStarHeuristicFunc(grid: [[Tile]]) -> Int {
    return greedyHeuristicFunc1(grid)
}

// Queue configurations
private func enqueueLast<Node>(input: [Node]) -> Int {
    return input.count
}

private func enqueueFirst<Node>(input: [Node]) -> Int{
    return 0
}

private func enqueueInIncreasingOrder<Node>(nodes: [Node], toInsert: Node, evalFunc: Node -> Int) -> Int {
    let evalValue = evalFunc(toInsert)
    for var i = 0; i < nodes.count; i++ {
        let node = nodes[i]
        if evalFunc(node) > evalValue {
            return i
        }
    }
    return nodes.count
}

// heuristic Function 1 helpers
func pathToGoal(grid: [[Tile]], targetLocation: Location?, pathLocations: [Location]) -> Int{
    
    if targetLocation == nil {
        return (grid.count * grid.first!.count)
    }
    
    let currentTile = grid[targetLocation!.row][targetLocation!.col]
    if currentTile is GoalTile {
        let goalEnterLocation = currentTile.getLocationForEdge(Location(row: grid.count, col:  grid.first!.count), exitEdge: (currentTile as! GoalTile).enterEdge)

        if pathLocations.first?.row == goalEnterLocation?.row && pathLocations.first?.col == goalEnterLocation?.col {
            return 0
        }

        return 6
    }
    
    var newPathLocations = pathLocations
    newPathLocations.insert(targetLocation!, atIndex:  0)

    var costsToGoal: [Int] = []
    
    let topLocation    : Location = Location(row: targetLocation!.row - 1, col: targetLocation!.col)
    let bottomLocation : Location = Location(row: targetLocation!.row + 1, col: targetLocation!.col)
    let leftLocation   : Location = Location(row: targetLocation!.row, col: targetLocation!.col-1)
    let rightLocation  : Location = Location(row: targetLocation!.row, col: targetLocation!.col+1)
    
    for loc in [topLocation,bottomLocation, leftLocation, rightLocation ] {
        if loc.withInRange(grid.count, col: grid.first!.count) {
            if !(newPathLocations.contains{$0.col == loc.col && $0.row == loc.row }){
                 costsToGoal.append(pathToGoal(grid, targetLocation: loc, pathLocations: newPathLocations))
            }
        }
        
    }
    let leastCost = costsToGoal.minElement() ??  50 //(grid.count * grid.first!.count)
    return leastCost + 1
}

func movedPathLocations(grid: [[Tile]]) -> ([Location], Edge) {
    let initialTile: InitialTile = (grid.flatten().filter { $0 is InitialTile}.first)! as! InitialTile
    let compatableEdge: Edge = initialTile.exitEdge.compatableEdge()
    let nextLocation = initialTile.location.translate(initialTile.exitEdge.translationFactor())
    var locations: [Location] = [initialTile.location]
    var lastExitEdge : Edge! = initialTile.exitEdge
    
    func recursiveGoalTest(targetLocation: Location, targetEdge: Edge) {
        if targetLocation.withInRange(grid.count, col: grid.first!.count) {
            let nextTile = grid[targetLocation.row][targetLocation.col]

            if nextTile is PathTile {
                let pathTile = (nextTile as! PathTile)
                if pathTile.config.contains(targetEdge){
                    let exitEdge = pathTile.config.filter { $0 != targetEdge }.first
                    let location = pathTile.location.translate(exitEdge!.translationFactor())
                    locations.insert(targetLocation, atIndex: 0)
                    lastExitEdge = exitEdge
                    return recursiveGoalTest(location, targetEdge: (exitEdge?.compatableEdge())!)
                }
            }
        }
        return
    }
    recursiveGoalTest(nextLocation, targetEdge: compatableEdge)
    
    return (locations, lastExitEdge)
}
