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
    
    open var button = SKSpriteNode()
    //on display info about state of game and result
    open func display(message: String, score: Int?) {
        // display message about state of game
        let messageLable = SKLabelNode(text: message)
        messageLable.numberOfLines = 0
        messageLable.preferredMaxLayoutWidth = frame.width
        messageLable.lineBreakMode = .byWordWrapping
        let messageX = -frame.width
        let messageY = frame.height / 2.0
        messageLable.position = CGPoint(x: messageX, y: messageY)
        messageLable.horizontalAlignmentMode = .center
        messageLable.verticalAlignmentMode = .center
        messageLable.fontName = "Courier-Bold"
        messageLable.fontSize = 42.0
        messageLable.zPosition = 20
        addChild(messageLable)
        //animate text message
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.3)
        messageLable.run(messageAction)
        //display score of game
        if let scoreToDisplay = score {
            let scoreString = String(format: "Score: %04d".localized, scoreToDisplay)
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
    //configure start/resume button
    open func configureButton(with gameState: StateGame) {
        if gameState == .pause {
            button = SKSpriteNode(imageNamed: SpriteString.resumeButton.rawValue)
            button.name = SpriteString.resumeButton.rawValue
        } else {
            button = SKSpriteNode(imageNamed: SpriteString.startButton.rawValue)
            button.name = SpriteString.startButton.rawValue
        }
        let startButtonX = frame.midX
        let startButtonY = frame.midY / 3
        button.position = CGPoint(x: startButtonX, y: startButtonY)
        button.zPosition = 40.0
        addChild(button)
    }
}
