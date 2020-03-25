//
//  Node.swift
//  SlidePuzzle
//
//  Created by Sydney Lin on 3/24/20.
//  Copyright © 2020 Sydney Lin. All rights reserved.
//

import Foundation

class Node {
    
    // Current state of the node and the solution
    var state: [Int]
    var solution: [Int]
    
    // Edges used for the possible move set
    var leftEdgeNodes: [Int]
    var rightEdgeNodes: [Int]
    
    // Parent node used for backtracking
    var parent: Node?
    
    // Heuristic score
    var hScore: Int = 0
    
    // How many moves have been taken
    var gScore: Int = 0
    
    // F = G + H in A*
    var fScore: Int = 0
    
    // Anoter init with parent
    init(state: [Int], level: Int, parent: Node?) {
        self.state = state
        self.gScore = level
        self.parent = parent
        
        leftEdgeNodes = [0, 3, 6]
        rightEdgeNodes = [4, 7, 10]
        solution = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        hScore = manhattanDistance()
        fScore = gScore + hScore
    }
    
    // Generate child nodes from the current state
    func generateChildren() -> [Node] {
        // Generate all possible moves from the current state
        let moves = generatePossibleMoves()
        var nodes: [Node] = []
        let indexOf9 = state.firstIndex(of: 9)!
        
        // Iterate through the moves and create a node
        for i in 0...moves.count - 1 {
            var tempState = state
            
            //let toBeSwapped = state.firstIndex(of: moves[i])!
            //print(toBeSwapped)
            tempState.swapAt(moves[i] - 1, indexOf9)
            nodes.append(Node(state: tempState, level: gScore + 1, parent: self))
        }
        return nodes
    }
    
    // This HAS to be working
    // Generate all valid moves for the empty space as a list of integers (RETURNS SPACE NUMBER NOT INDEX)
    // 1 2 3 4 5 6 7 8 9
    /*
     1 2 3
     4 5 6
     7 8 9
     
     [1, 2, 3, 5, 9, 6, 4, 7, 8]
     Possible moves: [2, 8, 4, 6]
     4
     Child: [1, 9, 3, 5, 2, 6, 4, 7, 8]
     Child: [1, 2, 3, 5, 7, 6, 4, 9, 8]
     Child: [1, 2, 3, 9, 5, 6, 4, 7, 8]
     Child: [1, 2, 3, 5, 6, 9, 4, 7, 8]
     [1, 2, 3, 5, 7, 6, 4, 9, 8]
     Possible moves: [5, 7, 9]
     3
     Child: [1, 2, 3, 5, 9, 6, 4, 7, 8]
     Child: [1, 2, 3, 5, 7, 6, 9, 4, 8]
     Child: [1, 2, 3, 5, 7, 6, 4, 8, 9]
     [1, 2, 3, 5, 7, 6, 4, 8, 9]
     Possible moves: [6, 8]
     2
     Child: [1, 2, 3, 5, 7, 9, 4, 8, 6]
     Child: [1, 2, 3, 5, 7, 6, 4, 9, 8]
     [1, 2, 3, 9, 5, 6, 4, 7, 8]
     Possible moves: [1, 7, 5]
     3
     Child: [9, 2, 3, 1, 5, 6, 4, 7, 8]
     Child: [1, 2, 3, 4, 5, 6, 9, 7, 8]
     Child: [1, 2, 3, 5, 9, 6, 4, 7, 8]
     [1, 2, 3, 4, 5, 6, 9, 7, 8]
     Possible moves: [4, 8]
     2
     Child: [1, 2, 3, 9, 5, 6, 4, 7, 8]
     Child: [1, 2, 3, 4, 5, 6, 7, 9, 8]
     [1, 2, 3, 4, 5, 6, 7, 9, 8]
     Possible moves: [5, 7, 9]
     3
     Child: [1, 2, 3, 4, 9, 6, 7, 5, 8]
     Child: [1, 2, 3, 4, 5, 6, 9, 7, 8]
     Child: [1, 2, 3, 4, 5, 6, 7, 8, 9]
     [1, 2, 3, 4, 5, 6, 7, 8, 9]
     Solution found!
     [0, 8, 9, 4, 7, 8, 9]
     
     */
    func generatePossibleMoves() -> [Int] {
        var list: [Int] = []
        // Get the location (spot) of 9
        let idx = state.firstIndex(of: 9)! + 1
        // Upper row
        let up = idx - 3
        if up > 0 {
            list.append(up)
        }
        // Row below
        let down = idx + 3
        if down < 10 {
            list.append(down)
        }
        // Left column
        let left = idx - 1
        if left > 0 && !leftEdgeNodes.contains(left) {
            list.append(left)
        }
        // Right column
        let right = idx + 1
        if right < 10 && !rightEdgeNodes.contains(right) {
            list.append(right)
        }
        print("Possible moves: \(list)")
        return list
        /*
         [1, 2, 3, 5, 9, 6, 4, 7, 8]
         [2, 8, 4, 6]
         [1, 2, 3, 5, 7, 6, 4, 9, 8]
         [5, 7, 9]
         [1, 2, 3, 5, 7, 6, 4, 8, 9]
         [6, 8]
         [1, 2, 3, 9, 5, 6, 4, 7, 8]
         [1, 7, 5]
         [1, 2, 3, 4, 5, 6, 9, 7, 8]
         [4, 8]
         [1, 2, 3, 4, 5, 6, 7, 9, 8]
         [5, 7, 9]
         [1, 2, 3, 4, 5, 6, 7, 8, 9]
         Solution found!
         [0, 8, 9, 4, 7, 8, 9]
         */
    }
    
    // Check if the current node is the solution (all nodes are in place)
    func isSolution() -> Bool {
        return state.elementsEqual(solution)
    }
    
    // Distance from actual heuristic with absolute value
    func manhattanDistance() -> Int {
        var mhd: Int = 0
        for i in 0...solution.count - 1 {
            let temp = state[i] // Get element at position i
            let actualLocation = i + 1
            mhd += abs(temp - actualLocation)
        }
        return mhd
    }
}
