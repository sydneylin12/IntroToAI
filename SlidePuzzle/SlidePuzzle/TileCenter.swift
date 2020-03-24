//
//  TileCenter.swift
//  SlidePuzzle
//
//  Created by Sydney Lin on 3/24/20.
//  Copyright © 2020 Sydney Lin. All rights reserved.
//

import Foundation
import UIKit

class TileCenter {
    
    // Integer location of the center (these are in order)
    var location: Int
    var center: CGPoint
    
    init(location: Int, center: CGPoint) {
        self.location = location
        self.center = center
    }
}
