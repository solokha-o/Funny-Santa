//
//  MenuLayer.swift
//  Funny Santa
//
//  Created by Oleksandr Solokha on 07.08.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import UIKit
import SpriteKit

class MainMenu: SKSpriteNode {
    //create start-resume button
    open var startResumeButton = SKSpriteNode()
    //create info button
    open var infoButton = SKSpriteNode()
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
    open func configureStartResumeButton(with gameState: StateGame) {
        if gameState == .pause {
            startResumeButton = SKSpriteNode(imageNamed: SpriteString.resumeButton.rawValue)
            startResumeButton.name = SpriteString.resumeButton.rawValue
        } else {
            startResumeButton = SKSpriteNode(imageNamed: SpriteString.startButton.rawValue)
            startResumeButton.name = SpriteString.startButton.rawValue
        }
        let startResumeButtonX = frame.midX
        let startResumeButtonY = frame.midY / 3
        startResumeButton.position = CGPoint(x: startResumeButtonX, y: startResumeButtonY)
        startResumeButton.zPosition = 40.0
        addChild(startResumeButton)
    }
    //configure info button
    open func configureInfoButton() {
        infoButton = SKSpriteNode(imageNamed: SpriteString.infoButton.rawValue)
        infoButton.name = SpriteString.infoButton.rawValue
        let infoButtonX = frame.midX / 0.6
        let infoButtonY = frame.midY / 0.6
        infoButton.position = CGPoint(x: infoButtonX, y: infoButtonY)
        infoButton.zPosition = 40.0
        addChild(infoButton)
    }
}
