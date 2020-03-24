//
//  MyLabel.swift
//  SlidePuzzle
//
//  Created by Sydney Lin on 3/23/20.
//  Copyright © 2020 Sydney Lin. All rights reserved.
//

import UIKit

class MyLabel: UILabel {
    
    // The number on the tile
    var data: Int = 0
    
    // Current position on the grid (ONE THRU NINE)
    var currentPosition: Int = 0
    
    // The solution position
    var originalPosition: Int = 0
    
    // Check if the tile is the empty tile
    func isEmptyTile(length: Int) -> Bool {
        return data == length
    }
    
    func isInPosition() -> Bool {
        // Last tile will have the last length (ex: 9 for a 3x3)
        return currentPosition == originalPosition
    }
}
