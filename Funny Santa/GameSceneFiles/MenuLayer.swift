//
//  MenuLayer.swift
//  Funny Santa
//
//  Created by Oleksandr Solokha on 07.08.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import UIKit
import SpriteKit

class MenuLayer: SKSpriteNode {
    //on display info about state of game and resault
    func display(message: String, score: Int?) {
        // display message about state of game
        let messageLable = SKLabelNode(text: message)
        let messageX = -frame.width
        let messageY = frame.height / 2.0
        messageLable.position = CGPoint(x: messageX, y: messageY)
        messageLable.horizontalAlignmentMode = .center
        messageLable.fontName = "Courier-Bold"
        messageLable.fontSize = 48.0
        messageLable.zPosition = 20
        addChild(messageLable)
        //animate text message
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.3)
        messageLable.run(messageAction)
        //display score of game
        if let scoreToDisplay = score {
            let scoreString = String(format: "Score: %04d", scoreToDisplay)
            let scoreLabel = SKLabelNode(text: scoreString)
            let scoreLabelX = frame.width
            let scoreLabelY = messageLable.position.y - messageLable.frame.height
            scoreLabel.position = CGPoint(x: scoreLabelX, y: scoreLabelY)
            scoreLabel.horizontalAlignmentMode = .center
            scoreLabel.fontName = "Courier-Bold"
            scoreLabel.fontSize = 32.0
            scoreLabel.zPosition = 20
            addChild(scoreLabel)
            let scoreAction = SKAction.moveTo(x: finalX, duration: 0.3)
            scoreLabel.run(scoreAction)
        }
    }
}
