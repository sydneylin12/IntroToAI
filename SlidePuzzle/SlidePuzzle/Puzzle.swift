//
//  Puzzle.swift
//  SlidePuzzle
//
//  Created by Sydney Lin on 3/24/20.
//  Copyright © 2020 Sydney Lin. All rights reserved.
//

import Foundation

class Puzzle {
    
    // Size of the actual grid
    var size: Int
    
    // Number of turns taken
    var turns: Int
    
    // Which node we are currently on
    var currentNode: Node
    
    // Open list of nodes and their states
    var open: [Node]
    var openStates: [[Int]]
    
    // Closed list of nodes and their states
    var closed: [Node]
    var closedStates: [[Int]]
    
    // Solution to the puzzle
    var solution: [Int] = []
    
    // Debug to keep track of duplicate nodes in the frontier
    var numDuplicates: Int = 0
    
    // Initialize with a stae
    init(state: [Int]) {
        size = state.count
        turns = 0
        
        open = []
        openStates = []
        closed = []
        closedStates = []
        
        let node: Node = Node(state: state, level: 0, parent: nil)
        currentNode = node
        open.append(node)
        openStates.append(node.state)
    }
    
    // Run the A* algorithm and return the optimal list of moves, or NIL if no solution can be found
    func AStar() -> [Int]? {
        // Make sure the list has nodes in it
        while open.count > 0 {
            // Sort open list based on lowest f-score
            open.sort { $0.fScore < $1.fScore }
            turns += 1
            
            // "Dequeue" the node at the start
            let dequeued: Node = open[0]
            print("Current state: \(dequeued.state)")
            currentNode = dequeued
            open.remove(at: 0) // Remove from open list
            openStates.remove(at: 0)
            
            if dequeued.isSolution() {
                print("Solution found with number of turns: \(turns)")
                return generateSolution()
            }
                        
            // Iterate through the children
            let children: [Node] = dequeued.generateChildren()
            //print("Children total: \(children.count)")
            for child in children {
                //print("Child: \(child.state)")
                let idxOpen = openStates.firstIndex(of: child.state)
                let idxClosed = closedStates.firstIndex(of: child.state)

                // If the open list contains the child and the existing f-score is less
                if idxOpen != nil && open[idxOpen!].fScore < child.fScore {
                    continue // Discard the node
                }
                // If the closed list contains the child and the existing f-score is less
                if idxClosed != nil && closed[idxClosed!].fScore < child.fScore {
                    continue // Discard the node
                }
                
                // Add the child to the open list
                open.append(child)
                openStates.append(child.state)
            }
            // Add the expanded node to the closed list
            closed.append(dequeued)
            closedStates.append(dequeued.state)
        }
        
        // After the while loop ends
        if !currentNode.isSolution() {
            print("A star failed - no more nodes in the open list!")
            return nil
        }
        else {
            return generateSolution()
        }
    }
    
    // Get the move of the swap
    func getMove(current: [Int], next: [Int]) -> Int {
        // Return 0 if the move is equal
        if current.elementsEqual(next) {
            return 0
        }
        
        for i in 0...current.count - 1 {
            if current[i] != next[i] && current[i] != 9 {
                return i + 1
            }
        }
        return -1
    }
    
    // Generate the list of moves required to get initial state to goal state
    func generateSolution() -> [Int] {
        // Array of states
        var statesToSolution: [[Int]] = []
        
        // Clone to not mess up pointer
        var curr = currentNode
        
        // Backtrack over the parent path to find the move set
        while curr.parent != nil {
            statesToSolution.append(curr.state)
            curr = curr.parent!
        }
        statesToSolution.append(curr.state)
        // Reverse with the top-most node as the starting instead of the bottom-most
        statesToSolution.reverse()

        // Generate required moves to get from initial state to goal state with helper function
        var movesToSolution: [Int] = []
        
        // Error check for one move solution
        if statesToSolution.count <= 1 {
            return [0]
        }
        
        // Error check for solution set with 2 moves
        if statesToSolution.count == 2 {
            return [getMove(current: statesToSolution[0], next: statesToSolution[1])]
        }
        
        for i in 0...statesToSolution.count - 2 {
            movesToSolution.append(getMove(current: statesToSolution[i], next: statesToSolution[i+1]))
        }
        print("Move set to solution: \(movesToSolution) with length: \(movesToSolution.count)")
        return movesToSolution
    }
}
