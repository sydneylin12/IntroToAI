//
//  ViewController.swift
//  SlidePuzzle
//
//  Created by Sydney Lin on 3/23/20.
//  Copyright © 2020 Sydney Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var randomizeButton: UIButton!
    @IBOutlet weak var solveButton: UIButton!
    
    // Array of tile/label objects
    var tileArr: [MyLabel] = []
    
    // Array of center/index
    var centersArr: [TileCenter] = []
    
    var gridSize: Int = 3
    var numTiles: Int = 9
    var tileSize: CGFloat  = 0
    
    var time: Int = 0
    var timer: Timer = Timer()
    
    // Empty space location
    var empty: MyLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Force light theme for the game
        overrideUserInterfaceStyle = .light
        initUserInterface()
        generateTiles()
        randomizePressed(Any.self)
    }

    @IBAction func randomizePressed(_ sender: Any) {
        randomize()
        time = 0
        timerLabel.text = String(time)
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(action), userInfo: nil, repeats: true)
    }
    
    @IBAction func solve(_ sender: Any) {
        printBoardState()
    }
    
    @objc func action() {
        time += 1
        timerLabel.text = String(time)
    }
        
    // Style the UI elements
    func initUserInterface() {
        randomizeButton.layer.cornerRadius = 5.0
        solveButton.layer.cornerRadius = 5.0
        timerLabel.layer.cornerRadius = 5.0
        timerLabel.layer.masksToBounds = true
    }
    
    // Print the state of the board as an array
    func printBoardState() {
        var copy = tileArr
        copy.sort {
            $0.currentPosition < $1.currentPosition
        }
        
        print("[", terminator: "")
        for i in 0...copy.count - 1 {
            let tile = copy[i]
            var num: String = String(tile.data)
            if tile.data == numTiles {
                num = "_"
            }
            
            if i == copy.count - 1 {
                print(num, terminator: "")
            }
            else {
                print(num, terminator: ", ")
            }
        }
        print("]", terminator: "")
        print("")
        
        generateMoveList()
    }
    
    // Create tiles on the grid
    func generateTiles() {
        // Reset the game
        tileArr = []
        centersArr = []

        tileSize = gameView.frame.width / 3.0
        
        var xCenter = tileSize / 2.0
        var yCenter = tileSize / 2.0
        
        // Value of the tile
        var currentNumber: Int = 1
        
        for _ in 0...gridSize - 1 {
            for _ in 0...gridSize - 1 {
                
                // Construct a custom class for the tile
                let frame: CGRect = CGRect(x: 0, y: 0, width: tileSize - 5, height: tileSize - 5)
                let tile: MyLabel = MyLabel(frame: frame)
                tile.data = currentNumber
                tile.currentPosition = currentNumber
                tile.originalPosition = currentNumber
                
                tile.font = UIFont.systemFont(ofSize: 24.0)
                tile.text = String(tile.data)
                tile.textAlignment = .center
                tile.textColor = UIColor.white
                
                // Hold location and actual point position of current space
                let center = CGPoint(x: xCenter, y: yCenter)
                let tileCenter = TileCenter(location: currentNumber, center: center)
                
                tile.center = center
                tile.backgroundColor = UIColor.darkGray
                tile.isUserInteractionEnabled = true
                
                // Enable corners for UI label
                tile.layer.cornerRadius = 10.0
                tile.layer.masksToBounds = true
                
                // Add to the subview
                gameView.addSubview(tile)
                
                tileArr.append(tile)
                centersArr.append(tileCenter)
                
                xCenter += tileSize
                currentNumber += 1
            }
            xCenter = tileSize / 2.0
            yCenter += tileSize
        }
        
        // Initialize the empty tile
        let lastBlock: MyLabel = tileArr[numTiles - 1]
        lastBlock.text = nil
        lastBlock.backgroundColor = UIColor.clear
        empty = lastBlock
    }
    
    // Randomize tile placement on the grid
    func randomize() {
        // Clone the array for the randomization
        var duplicateCenters: [TileCenter] = centersArr
        
        // Iterate through each of the 8 tiles
        // Randomize by removing center points from clone array one by one
        for tile in tileArr {
            let idx: Int = Int.random(in: 0...duplicateCenters.count - 1)
            let randomTile: TileCenter = duplicateCenters[idx]
            
            // Assign tile center to new center
            tile.center = randomTile.center
            tile.currentPosition = randomTile.location
            duplicateCenters.remove(at: idx)
        }
        
        // Check if any of the tiles are in starting position
        for tile in tileArr {
            if tile.isInPosition() && !tile.isEmptyTile(length: 9) {
                tile.backgroundColor = UIColor.systemGreen
            }
            else if !tile.isInPosition() && !tile.isEmptyTile(length: 9) {
                tile.backgroundColor = UIColor.darkGray
            }
            else if tile.isEmptyTile(length: 9) {
                tile.backgroundColor = UIColor.clear
            }
            else {
                print("This should not happen!")
            }
        }
    }
    
    // Detect a touch on a tile and swap if eligible
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let myTouch: UITouch = touches.first!
        
        // Must use if let to prevent exceptions
        if let _ = myTouch.view as? MyLabel {
            let touchView: MyLabel = myTouch.view as! MyLabel
            
            // Disregard when touching empty tile
            if touchView.isEmptyTile(length: numTiles) {
                return // Cannot touch empty tile
            }
            
            print("Touched: \(touchView.data) at position: \(touchView.currentPosition)")
            
            // Compute distance formula
            let xDif: CGFloat = touchView.center.x - empty.center.x
            let yDif: CGFloat = touchView.center.y - empty.center.y
            let distance: CGFloat = sqrt(pow(xDif, 2.0) + pow(yDif, 2.0))

            // Must use this conditional because of decimal error in size 3 board
            if (distance - tileSize < 0.1) {
                swap(idx: touchView.currentPosition)
                
                // Highlight green when in the right spot
                if touchView.isInPosition() {
                    touchView.backgroundColor = UIColor.systemGreen
                }
                else {
                    touchView.backgroundColor = UIColor.darkGray
                }
            }
        }
    }
    
    // Swap two tiles - pass in POSITIONS (swaps with empty box)
    func swap(idx: Int) {
        let first: MyLabel = getAtPosition(position: idx)
        let second: MyLabel = getAtPosition(position: empty.currentPosition)
        
        // Swap the centers and the current positions
        let temp: CGPoint = first.center
        let tempNumber: Int = first.currentPosition
        
        // Swap positions and centers
        first.currentPosition = second.currentPosition
        UIView.animate(withDuration: 0.2, animations: {
            first.center = second.center
        })
        
        second.center = temp
        second.currentPosition = tempNumber
    }
    
    // Get the TILE at GRID POSITION "position"
    func getAtPosition(position: Int) -> MyLabel {
        for tile in tileArr {
            if tile.currentPosition == position {
                return tile
            }
        }
        return tileArr[0]
    }
    
    // Generate all valid moves for the empty space
    func generateMoveList() -> [Int] {
        var list: [Int] = []
        let up = empty.currentPosition - 3
        if up > 0 {
            list.append(up)
        }
        let down = empty.currentPosition + 3
        if down < 10 {
            list.append(down)
        }
        let left = empty.currentPosition - 1
        if left > 0 {
            list.append(left)
        }
        let right = empty.currentPosition + 1
        if right < 10 {
            list.append(right)
        }
        print(list)
        return list
    }
}

