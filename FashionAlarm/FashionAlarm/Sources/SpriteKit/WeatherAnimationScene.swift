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
    private var emitter: SKEmitterNode?
}

extension WeatherAnimationScene {
    private func setupParticleEmitter(){
        stopEmitter() // 메모리 누수화 확인 가능 || 객체가 계속 쌓인다면 메모리 누수 가능
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "FashionAllInfo") as? [String: Any] else { return }
        guard let weather = data["weather"] as? String else { return }
        if( weather.contains("눈") ){
            emitter = SKEmitterNode(fileNamed: "Snow")! // 중복처리 
            emitter!.position = CGPoint(x: size.width / 2, y: size.height - 50)
            addChild(emitter!)
        }
        else if( weather.contains("비") ){
            emitter = SKEmitterNode(fileNamed: "Rain")!
            emitter!.position = CGPoint(x: size.width / 2, y: size.height - 50)
            addChild(emitter!)
        }
    }
    private func stopEmitter() {
        guard let emitter = emitter else { return }
        emitter.particleBirthRate = 0.0
        emitter.targetNode = nil
        emitter.removeFromParent()
        self.emitter = nil
    }
}
