//
//  SnowScene.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/31.
//

import Foundation
import SpriteKit

class WeatherAnimationScene: SKScene {
    override func didMove(to view: SKView) { // entry point
        super.didMove(to: view)
        setupParticleEmitter()
    }
    private func setupParticleEmitter(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "FashionAllInfo") as? [String: Any] else { return }
        guard let weather = data["weather"] as? String else { return }
        print(weather)
        if( weather.contains("눈") ){
            let particleEmitter = SKEmitterNode(fileNamed: "Snow")!
            particleEmitter.position = CGPoint(x: size.width / 2, y: size.height - 50)
            addChild(particleEmitter)
        }
        else if( weather.contains("비") ){
            let particleEmitter = SKEmitterNode(fileNamed: "Rain")!
            particleEmitter.position = CGPoint(x: size.width / 2, y: size.height - 50)
            addChild(particleEmitter)
        }

    }
}
