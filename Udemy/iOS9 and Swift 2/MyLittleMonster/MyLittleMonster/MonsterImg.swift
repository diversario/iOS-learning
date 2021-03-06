//
//  MonsterImg.swift
//  MyLittleMonster
//
//  Created by Ilya Shaisultanov on 1/7/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import Foundation
import UIKit

class MonsterImg: AnimatedImage {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.idlePrefix = "idle"
        self.idleCount = 4
        self.deadPrefix = "dead"
        self.deadCount = 5
        
        playIdleAnimation()
    }
}