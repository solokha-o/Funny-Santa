//
//  GameScene.swift
//  Funny Santa
//
//  Created by Oleksandr Solokha on 27.06.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import SpriteKit
import GameplayKit
//get physics category to objects of game
struct PhysicsCategory {
    static let santa : UInt32 = 0x1 << 0
    static let brick : UInt32 = 0x1 << 1
    static let candy : UInt32 = 0x1 << 2
    static let water : UInt32 = 0x1 << 3
    static let tree : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //create enum of brick level
    enum BrickLevel: CGFloat {
        case low = 0.0
        case high = 64.0
    }
    //create enum state of game
    enum StateGame {
        case notRunning
        case running
    }
    //create enum for kind of brick
    enum  KindBrick: String {
        case first = "firstBrick"
        case main = "brick"
        case last = "lastBrick"
        case foundation = "foundationBrick"
    }
    
    //create instance of Santa
    var santa = Santa()
    //create SKTexture array for animate santa sprite
    var santaWalkingFrames : [SKTexture] = []
    //create SKTexture array for animate santa jump
    var santaJumpFrames : [SKTexture] = []
    //create array bricks
    var bricks = [SKSpriteNode]()
    //brick size on road
    var brickSize = CGSize.zero
    // bricks speed
    var scrollSpeed : CGFloat = 4.0
    //create starting speed
    let startingScrollSpeed : CGFloat = 4.0
    // create property for time interval update game
    var lastUpdateTime : TimeInterval?
    // create gravity
    let gravitySpeed : CGFloat = 1.5
    // create instance of brick level
    var brickLevel = BrickLevel.low
    // create array of candies
    var candies = [SKSpriteNode]()
    //create instance score and best score
    var score = 0
    var highScore = 0
    var lastScoreUpdateTime : TimeInterval = 0.0
    //create state of game
    var stateGame = StateGame.notRunning
    //create kindBrick instance
    var kindBrick = KindBrick.main
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        loadSantaImage()
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        // add contact delegate
        physicsWorld.contactDelegate = self
        anchorPoint = CGPoint.zero
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // add tapGesture to scene
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameScene.handleTap(tapGesture:)))
        view.addGestureRecognizer(tapGesture)
        //call setup and configure function
        setupBackground()
        setBackgroundSong()
        setSnowing()
        setupLabels()
        buildSanta()
        santaAnimate()
        //display start game menu
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint(x: 0, y: 0)
        menuLayer.position = CGPoint(x: 0, y: 0)
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Press to Start game", score: nil)
        addChild(menuLayer)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // break game
        if stateGame != .running {
            return
        }
        //boost speed
        scrollSpeed += 0.0001
        // configure time update animation
        var elapsedTime : TimeInterval = 0.0
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }
        lastUpdateTime = currentTime
        let expectedElapsedTime : TimeInterval = 1.0 / 60.0
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        // call function update node by currentScrollAmount
        updateBricks(withScrollAmount: currentScrollAmount)
        updateSanta()
        if let velocityY = santa.physicsBody?.velocity.dy {
            if velocityY == 0.0 {
                santaAnimate()
            }
            else if !santa.isOnGroud {
                santaJumpAnimate()
            }
        }
        // santa animate when on ground
        updateCandy(withScrollAmount: currentScrollAmount)
        //call function update node by currentTime
        updateScore(withCurrentTime: currentTime)
    }
    //configure tapGesture
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        if stateGame == .running {
            if santa.isOnGroud {
                // sound when santa jump
                run(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false))
                santa.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 180.0))
                santa.isOnGroud = false
                print("Played sound of Santa's jump")
                print("Santa jump.")
            }
        } else {
            if let menuLayer: SKSpriteNode = childNode(withName: "menuLayer") as? SKSpriteNode {
                menuLayer.removeFromParent()
                startGame()
            }
        }
    }
    // MARK:- SKPhysicsContactDelegate Methods
    func didBegin(_ contact: SKPhysicsContact) {
        //configure contact santa & brick
        if contact.bodyA.categoryBitMask == PhysicsCategory.santa && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            santa.createSnowSplash()
            santa.isOnGroud = true
            print("Santa is running with speed - \(scrollSpeed)")
        }
        //configure contact santa & candy
        else if contact.bodyA.categoryBitMask == PhysicsCategory.santa && contact.bodyB.categoryBitMask == PhysicsCategory.candy {
            if let candy = contact.bodyB.node as? SKSpriteNode {
                removeСandy(candy)
                score += 50
                print("Score now - \(score)")
                //sound when take candy
                run(SKAction.playSoundFileNamed("candy.wav", waitForCompletion: false))
                run(SKAction.playSoundFileNamed("ho-ho-ho.wav", waitForCompletion: false))
                print("Played sound when Santa take a candy")
                print("Santa take candy")
                updateScoreTextLable()
            }
            //configure contact santa and water
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.santa && contact.bodyB.categoryBitMask == PhysicsCategory.water {
            //create water splash and sound when santa fills to water
            run(SKAction.playSoundFileNamed("waterSplash", waitForCompletion: true))
            print("Santa had fell to water.")
            santa.createWaterSplash()
            scrollSpeed = 0.0
        }
    }
    //load image from assets to array
    func loadSantaImage() {
        let santaAnimatedAtlas = SKTextureAtlas(named: "Santa")
        var walkFrames: [SKTexture] = []
        let numImages = santaAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let imageName = "Santa\(i)"
            walkFrames.append(SKTexture(imageNamed: imageName))
        }
        santaWalkingFrames = walkFrames
        print("Images for Santa walking are load: \(santaWalkingFrames)")
        let santaJumpTexture = SKTexture(imageNamed: "SantaJump")
        santaJumpFrames.append(santaJumpTexture)
        print("Images for Santa jamp are load: \(santaJumpFrames)")
    }
    // build frame santa on scene
    func buildSanta() {
        let firstTextureFrame = santaWalkingFrames[0]
        santa = Santa(texture: firstTextureFrame)
        santa.setupPhysicsBody()
        print("Santa had loaded.\n Texture - \(String(describing: santa.texture)).\n Santa position on screen: x - \(santa.position.x), y - \(santa.position.y).\n Santa scale: x - \(santa.xScale), y - \(santa.yScale).\n Santa size: height -  \(santa.size.height), width - \(santa.size.width).\n Santa anchor: \(santa.anchorPoint).\n Santa rotation: \(santa.zRotation)")
        addChild(santa)
    }
    //animate walking santa
    func santaAnimate() {
        let santaWalkAnimate = SKAction.animate(with: santaWalkingFrames, timePerFrame: 0.075)
        santa.run(SKAction.repeatForever(santaWalkAnimate))
    }
    //animate Santa jump
    func santaJumpAnimate() {
        let santaJumpAction = SKAction.animate(with: santaJumpFrames, timePerFrame: 0.01)
        santa.run(SKAction.repeatForever(santaJumpAction))
    }
    //setup background image
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        print("Background had setuped.\n Texture - \(String(describing: background.texture)).\n Background position on screen: x - \(background.position.x), y - \(background.position.y)./n")
        addChild(background)
    }
    //setup background song
    func setBackgroundSong() {
        let backgroundSong = SKAudioNode(fileNamed: "backgroundSong.mp3")
        addChild(backgroundSong)
        print("Play background song")
    }
    //setup snowing on main scene
    func setSnowing() {
        if let snowing = SKEmitterNode(fileNamed: "Snowing") {
            let xMid = frame.midX
            let yMid = frame.midY
            snowing.position = CGPoint(x: xMid, y: yMid)
            addChild(snowing)
            print("It is snowing.")
        }
    }
    //setup santa on scene
    func resetSanta() {
        let santaX = frame.midX / 2.0
        let santaY = santa.frame.height / 2.0 + 64.0
        santa.position = CGPoint(x: santaX, y: santaY)
        santa.zPosition = 10.0
        santa.minimumY = santaY
        santa.zPosition = 0.0
        santa.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        santa.physicsBody?.angularVelocity = 0.0
        print("Santa was reset.")
        
    }
    //configure labels with points gamer and best resault
    func setupLabels() {
        let scoreTextLabel : SKLabelNode = SKLabelNode(text: "Points")
        scoreTextLabel.position = CGPoint(x: 14.0, y: frame.size.height - 20.0)
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 18.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        print("Label 'Points' had setted.")
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 14.0, y: frame.size.height - 40.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 20.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        print("Label of score had seted.")
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text: "Best resault")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 20.0)
        highScoreTextLabel.horizontalAlignmentMode = .right
        highScoreTextLabel.fontName = "Courier-Bold"; highScoreTextLabel.fontSize = 18.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        print("Label 'Best resault' had setted.")
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 40.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 20.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
        print("Label of high score had setted.")
    }
    //configure update score text in labels
    func updateScoreTextLable() {
        if let scoreLable = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLable.text = String(format: "%04d", score)
            print("ScoreLabel was update - \(score)")
        }
    }
    //configure update high score text in labels
    func updateHighScoreTextLabel() {
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%04d", highScore)
            print("HighScoreLabel was update - \(highScore)")
        }
    }
    //configure start game
    func startGame() {
        stateGame = .running
        loadSantaImage()
        resetSanta()
        score = 0
        print("Score had began - \(score)")
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        for brick in bricks {
            brick.removeFromParent()
        }
        bricks.removeAll(keepingCapacity: true)
        print("All bricks had removed from screen.")
        for candy in candies {
            removeСandy(candy)
        }
    }
    // configure game over
    func gameOver() {
        if score > highScore {
            highScore = score
            print("High score now - \(highScore)")
            updateHighScoreTextLabel()
        }
        stateGame = .notRunning
        //display game over menu
        let menuBackgroundColor = UIColor.black.withAlphaComponent(0.4)
        let menuLayer = MenuLayer(color: menuBackgroundColor, size: frame.size)
        menuLayer.anchorPoint = CGPoint(x: 0, y: 0)
        menuLayer.position = CGPoint(x: 0, y: 0)
        menuLayer.zPosition = 30
        menuLayer.name = "menuLayer"
        menuLayer.display(message: "Game over!", score: score)
        print("Game over!")
        run(SKAction.playSoundFileNamed("gameOver", waitForCompletion: false))
        print("Sound of game over play.")
        DispatchQueue.main.async {
            self.santaWalkingFrames.removeAll()
            self.santaJumpFrames.removeAll()
        }
        addChild(menuLayer)
    }
    //configure brick
    func spawnBrick (atPosition position: CGPoint, kindBriсk: KindBrick) -> SKSpriteNode {
        let brick = SKSpriteNode(imageNamed: kindBriсk.rawValue)
        brick.position = position
        brick.zPosition = 8
        addChild(brick)
        brickSize = brick.size
        bricks.append(brick)
        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: center)
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        return brick
    }
    //configure candy
    func spawnСandy(atPosition position: CGPoint) {
        let candy = SKSpriteNode(imageNamed: "candy")
        candy.position = position
        candy.zPosition = 8
        addChild(candy)
        candy.physicsBody = SKPhysicsBody(rectangleOf: candy.size, center: candy.centerRect.origin)
        candy.physicsBody?.categoryBitMask = PhysicsCategory.candy
        candy.physicsBody?.affectedByGravity = false
        candies.append(candy)
        print("Candy was added on screen.")
    }
    //configure remove candy
    func removeСandy (_ candy: SKSpriteNode) {
        candy.removeFromParent()
        if let candyIndex = candies.firstIndex(of: candy) {
            candies.remove(at: candyIndex)
        }
        print("Candy was removed from screen.")
    }
    //configure water
    func spawnWater(atPosition position: CGPoint) -> SKSpriteNode {
        let water = SKSpriteNode(imageNamed: "water")
        water.position = position
        water.zPosition = 8
        addChild(water)
        bricks.append(water)
        let center = water.centerRect.origin
        water.physicsBody = SKPhysicsBody(rectangleOf: water.size, center: center)
        water.physicsBody?.affectedByGravity = false
        water.physicsBody?.categoryBitMask = PhysicsCategory.water
        water.physicsBody?.collisionBitMask = 0
        print("Water created on screen.")
        return water
    }
    //configure tree
    func spawnTree(atPosition position: CGPoint) -> SKSpriteNode {
        let treeArray = ["trees", "tree", "trees"]
        let rundomNumber = arc4random_uniform(2)
        let tree = SKSpriteNode(imageNamed: treeArray[Int(rundomNumber)])
        tree.position = position
        tree.zPosition = 10
        addChild(tree)
        bricks.append(tree)
        let center = tree.centerRect.origin
        tree.physicsBody = SKPhysicsBody(rectangleOf: tree.size, center: center)
        tree.physicsBody?.affectedByGravity = false
        tree.physicsBody?.categoryBitMask = PhysicsCategory.tree
        tree.physicsBody?.collisionBitMask = 0
        print("Trees created on screen.")
        return tree
    }
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        // position of first brick
        var farthestRightBrickX: CGFloat = 0.0 //update position of brick if position is not on screen remove brick else update new position for x
        for brick in bricks {
            let newX = brick.position.x - currentScrollAmount
            if newX < -brickSize.width {
                brick.removeFromParent()
                if let brickIndex = bricks.firstIndex(of: brick) {
                    bricks.remove(at: brickIndex)
                }
            } else {
                brick.position = CGPoint(x: newX, y: brick.position.y)
                if brick.position.x > farthestRightBrickX {
                    farthestRightBrickX = brick.position.x
                }
            }
        }
        // create new brick with brick level and kind of brick
        while farthestRightBrickX < frame.width {
            var brickX = farthestRightBrickX + brickSize.width
            let brickY = brickSize.height / 2.0 + brickLevel.rawValue
            kindBrick = .main
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY), kindBriсk: kindBrick)
            farthestRightBrickX = newBrick.position.x
            //create foundationBrick
            if brickLevel == .high {
                let foundationBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY - brickLevel.rawValue), kindBriсk: .foundation)
                farthestRightBrickX = foundationBrick.position.x
            }
            //create hole in brick
            let rundomNumber = arc4random_uniform(99)
            if rundomNumber < 5 && score > 10 {
                kindBrick = .last
                let lastBrick = spawnBrick(atPosition: CGPoint(x: brickX + brickSize.width, y: brickY), kindBriсk: kindBrick)
                farthestRightBrickX = lastBrick.position.x
                if brickLevel == .high {
                    let foundationBrick = spawnBrick(atPosition: CGPoint(x: brickX + brickSize.width, y: brickY - brickLevel.rawValue), kindBriсk: .foundation)
                    farthestRightBrickX = foundationBrick.position.x
                }
                let gap: CGFloat = 255
                brickX += gap
                // create candy where gap
                let randomcandyYamount = CGFloat(arc4random_uniform(150))
                let newcandyY = brickY + santa.size.height + randomcandyYamount
                let newcandyX = brickX - gap / 3.0
                spawnСandy(atPosition: CGPoint(x: newcandyX, y: newcandyY))
                //create water and add to line walk
                var water = spawnWater(atPosition: CGPoint(x: brickX - brickSize.width, y: brickY - brickLevel.rawValue - 5.0))
                farthestRightBrickX = water.position.x
                water = spawnWater(atPosition: CGPoint(x: brickX - 2 * brickSize.width , y: brickY - brickLevel.rawValue - 5.0))
                farthestRightBrickX = water.position.x
                kindBrick = .first
                let firstBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY), kindBriсk: kindBrick)
                farthestRightBrickX = firstBrick.position.x
                if brickLevel == .high {
                    let foundationBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY - brickLevel.rawValue), kindBriсk: .foundation)
                    farthestRightBrickX = foundationBrick.position.x
                }
            }
            else if rundomNumber < 15 && score > 20 {
                kindBrick = .last
                let lastBrick = spawnBrick(atPosition: CGPoint(x: brickX + brickSize.width, y: brickY), kindBriсk: kindBrick)
                farthestRightBrickX = lastBrick.position.x
                if brickLevel == .high {
                    kindBrick = .first
                    let firstBrick = spawnBrick(atPosition: CGPoint(x: brickX + brickSize.width, y: brickY - brickLevel.rawValue), kindBriсk: kindBrick)
                    farthestRightBrickX = firstBrick.position.x
                    brickLevel = .low
                }
                else if brickLevel == .low {
                    brickLevel = .high
                    kindBrick = .first
                    let firstBrick = spawnBrick(atPosition: CGPoint(x: brickX + brickSize.width, y: brickY + brickLevel.rawValue), kindBriсk: kindBrick)
                    farthestRightBrickX = firstBrick.position.x
                }
            }
            // create tree with rundom
            else if rundomNumber < 25 && score > 25 {
                let tree = spawnTree(atPosition: CGPoint(x: brickX, y: brickY + brickSize.height))
                farthestRightBrickX = tree.position.x
            }
        }
    }
    // configure update candies in scroll speed
    func updateCandy(withScrollAmount currentScrollAmount: CGFloat) {
        for candy in candies {
            let candyX = candy.position.x - currentScrollAmount
            candy.position = CGPoint(x: candyX, y: candy.position.y)
            if candy.position.x < 0.0 {
                removeСandy(candy)
                print("Candy has gone from screen.")
            }
        }
    }
    // configure update score
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        let elapsedTime = currentTime - lastScoreUpdateTime
        if elapsedTime > 1.0 {
            score += Int(scrollSpeed)
            print("Score now - \(score)")
            lastScoreUpdateTime = currentTime
            updateScoreTextLable()
        }
    }
    //configure update santa on screen - jump and down
    func updateSanta() {
        let isOffScreen = santa.position.y < 0.0 || santa.position.x < 0.0
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = santa.zRotation > maxRotation || santa.zRotation < -maxRotation
        if isOffScreen || isTippedOver {
            gameOver()
            print("Santa was gone from screen. Game over!")
        }
        // TODO: - when change santa position on screen return to his place
//        if santa.position.x != frame.midX / 2.0 && !santa.isOnGroud {
//            santa.position.x = frame.midX / 2.0
//        }
    }
}

