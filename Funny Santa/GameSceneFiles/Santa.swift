//
//  Santa.swift
//  Funny Santa
//
//  Created by Oleksandr Solokha on 30.06.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import SpriteKit

class Santa: SKSpriteNode {
    
    var velocity = CGPoint.zero
    var minimumY : CGFloat = 0.0
    var jumpSpeed : CGFloat = 20.0
    var isOnGroud = true
    //configure physics texture of santa
    func setupPhysicsBody() {
        if let santaTexture = texture {
            physicsBody = SKPhysicsBody(texture: santaTexture, size: size)
            physicsBody?.isDynamic = true
            physicsBody?.density = 6.0
            physicsBody?.allowsRotation = false
            physicsBody?.angularDamping = 1.0
            physicsBody?.categoryBitMask = PhysicsCategory.santa
            physicsBody?.collisionBitMask = PhysicsCategory.brick | PhysicsCategory.tree
            physicsBody?.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.candy | PhysicsCategory.water
        }
    }
    //create snow splash when santa jump
    func createSnowSplash() {
        if let snowSplashsNode = SKEmitterNode(fileNamed: "SnowSplash") {
            snowSplashsNode.position = CGPoint(x: 0.0, y: -50.0)
            addChild(snowSplashsNode)
            let waitAction = SKAction.wait(forDuration: 0.5)
            let removeAction = SKAction.removeFromParent()
            let waitThenRemove = SKAction.sequence([waitAction, removeAction])
            snowSplashsNode.run(waitThenRemove)
            print("Snow splash was displayed.")
        }
    }
    //create water splash when santa falls to water
    func createWaterSplash() {
        if let waterSplashsNode = SKEmitterNode(fileNamed: "WaterSplash") {
            waterSplashsNode.position = CGPoint(x: 0.0, y: -50.0)
            addChild(waterSplashsNode)
            let waitAction = SKAction.wait(forDuration: 0.5)
            let removeAction = SKAction.removeFromParent()
            let waitThenRemove = SKAction.sequence([waitAction, removeAction])
            waterSplashsNode.run(waitThenRemove)
            print("Water splash was displayed.")
        }
    }
}
