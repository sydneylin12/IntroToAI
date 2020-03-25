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
    
    // Make a move based on lowest f-score
    func expand() -> [Int]? {
        // Make sure the list has nodes in it
        var moveList: [Int] = []
        while open.count > 0 {
            open.sort {
                $0.fScore < $1.fScore
            }
            turns += 1
            
            // "Dequeue" the node at the start
            let dequeued: Node = open[0]
            print(dequeued.state)
            currentNode = dequeued
            open.remove(at: 0) // Remove from open list
            openStates.remove(at: 0)
            
            if dequeued.isSolution() {
                print("Solution found!")
                
                var arr: [[Int]] = []
                
                var curr = dequeued
                while curr.parent != nil {
                    //print(curr.state)
                    arr.append(curr.state)
                    curr = curr.parent!
                }
                arr.append(curr.state)
                
                arr.reverse()
                
                var i = 1
                for step in arr {
                    print("Step \(i): \(step)")
                    i += 1
                }
                
                var arr2: [Int] = []
                for i in 0...arr.count - 2 {
                    arr2.append(getMove(current: arr[i], next: arr[i+1]))
                }
                
                print(arr2)
                
                return arr2
            }
                        
            // Iterate through the children
            let children: [Node] = dequeued.generateChildren()
            print(children.count)
            for child in children {
                print("Child: \(child.state)")
                let idxOpen = openStates.firstIndex(of: child.state)
                let idxClosed = closedStates.firstIndex(of: child.state)

                if idxOpen != nil && open[idxOpen!].fScore < child.fScore {
                    continue
                }
                if idxClosed != nil && closed[idxClosed!].fScore < child.fScore {
                    continue
                }
                
                open.append(child)
                openStates.append(child.state)
            }
            
            closed.append(dequeued)
            closedStates.append(dequeued.state)
        }
            
        if !currentNode.isSolution() {
            print("A star failed - end of loop!")
            return nil
        }
        else {
            return nil
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
    
    // Helper method for backtracking
    func isLegal(move: [Int]) -> Bool {
        // If the moves are the same
        //print("Currrent move: \(move)")
        if currentNode.state.elementsEqual(move) {
            return true
        }
        let children = currentNode.generateChildren()
        for child in children {
            //print("Children move: \(child.state)")
            // Check if a child can make the optimal move
            if child.state.elementsEqual(move) {
                return true
            }
        }
        print("Illegal")
        return false // Move is illegal, must backtrack
    }
}
