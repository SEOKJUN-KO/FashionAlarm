//
//  SnowScene.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/31.
//

import Foundation
import SpriteKit

class SnowScene: SKScene {
    override func didMove(to view: SKView) { // entry point
        super.didMove(to: view)
        
        setupParticleEmitter()
    }
    
    private func setupParticleEmitter(){
        let particleEmitter = SKEmitterNode(fileNamed: "Snow")!
        particleEmitter.position = CGPoint(x: size.width / 2, y: size.height - 50)
        addChild(particleEmitter)
    }
    
}
