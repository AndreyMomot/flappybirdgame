//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Andrei Momot on 10/13/16.
//  Copyright (c) 2016 Dr_Mom. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score = 0
    var highscore = 0
    var scoreLabel = SKLabelNode()
    var highscoreLabel = SKLabelNode()
    var gameoverLabel = SKLabelNode()
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var topPipe = SKSpriteNode()
    var btmPipe = SKSpriteNode()
    var movingObjects = SKSpriteNode()
    var labelContainer = SKSpriteNode()
    
    /* enum for physicsWord */
    enum ColliderType: UInt32 {
        case bird = 1
        case object = 2
        case gap = 4
    }
    
    var gameOver = false
    
    /* creating a background */
    func makebg() {
        let bgTexture = SKTexture(imageNamed: "bg.png")
        let movebg = SKAction.moveBy(x: -bgTexture.size().width, y: 0, duration: 9)
        let replacebg = SKAction.moveBy(x: bgTexture.size().width, y: 0, duration: 0)
        let movebgForever = SKAction.repeatForever(SKAction.sequence([movebg, replacebg]))
        for i in (0..<3) {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * CGFloat(i), y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.zPosition = -1 /* giving bg a "background" effect */
            bg.run(movebgForever)
            movingObjects.addChild(bg)
        }
    }
    
    override func didMove(to view: SKView) {
        
            self.physicsWorld.contactDelegate = self
            self.addChild(movingObjects)
            self.addChild(labelContainer)
        
        /* creating a score label */
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.size.height - 70)
        scoreLabel.zPosition = 4
        self.addChild(scoreLabel)
      
        /* saving a highscore using Core Data */
        let highscoreDefault = UserDefaults.standard
        if highscoreDefault.value(forKey: "highscore") != nil {
            highscore = highscoreDefault.value(forKey: "highscore") as! NSInteger
        }
        highscoreLabel.text = NSString(format: "Best result: %i", highscore) as String
        
        makebg()
        
        /* creating birdTexture */
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1) /* to change pictures of a bird every 0.1 sec */
        let makeBirdFlap = SKAction.repeatForever(animation)
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY) /* set the position of a bird to the center of the screen */
        bird.run(makeBirdFlap) 
        
        /* creating bird physics */
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        bird.physicsBody!.isDynamic = true
        bird.physicsBody?.affectedByGravity  = false
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody!.categoryBitMask = ColliderType.bird.rawValue
        bird.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.object.rawValue
        bird.physicsBody!.allowsRotation = false
        bird.zPosition = 2
        self.addChild(bird)
        
        /* creating ground and ground physics */
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: 0)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        ground.physicsBody!.isDynamic = false
        ground.physicsBody!.categoryBitMask = ColliderType.object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.object.rawValue
        ground.zPosition = 3
        self.addChild(ground)
        
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.makePipes), userInfo: nil, repeats: true)
        
    }

        func makePipes() {
            
            /* distance between pipes */
        let gapHeight = bird.size.height * 5
        let movementAmount = arc4random() % UInt32(self.frame.size.height/2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height/4
            
            /* move pipes with the bg */
        let movePipes = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: TimeInterval(self.frame.size.width/100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
            /* creating top pipe */
            let topPipeTexture = SKTexture(imageNamed: "pipe1.png")
            let topPipe = SKSpriteNode(texture: topPipeTexture)
            topPipe.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + topPipeTexture.size().height/2 + gapHeight/2 + pipeOffset)
            topPipe.run(moveAndRemovePipes)
            
            /* top pipe physics */
            topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipeTexture.size())
            topPipe.physicsBody!.isDynamic = false
            topPipe.physicsBody!.categoryBitMask = ColliderType.object.rawValue
            topPipe.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
            topPipe.physicsBody!.collisionBitMask = ColliderType.object.rawValue
            topPipe.zPosition = 1
            movingObjects.addChild(topPipe)
        
            /* creating bottom pipe */
            let btmPipeTexture = SKTexture(imageNamed: "pipe2.png")
            let btmPipe = SKSpriteNode(texture: btmPipeTexture)
            btmPipe.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY - btmPipeTexture.size().height/2 - gapHeight/2 + pipeOffset)
            btmPipe.run(moveAndRemovePipes)
            
            /* bottom pipe physics */
            btmPipe.physicsBody = SKPhysicsBody(rectangleOf: btmPipeTexture.size())
            btmPipe.physicsBody!.isDynamic = false
            btmPipe.physicsBody!.categoryBitMask = ColliderType.object.rawValue
            btmPipe.physicsBody!.contactTestBitMask = ColliderType.object.rawValue
            btmPipe.physicsBody!.collisionBitMask = ColliderType.object.rawValue
            btmPipe.zPosition = 1
            movingObjects.addChild(btmPipe)
            
            /* creating a points gap between pipes */
            let gap = SKNode()
            gap.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + pipeOffset)
            gap.run(moveAndRemovePipes)
            
            /* gap physics */
            gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: topPipe.size.width/2, height: gapHeight))
            gap.physicsBody!.isDynamic = false
            gap.physicsBody!.categoryBitMask = ColliderType.gap.rawValue
            gap.physicsBody!.contactTestBitMask = ColliderType.bird.rawValue
            gap.physicsBody!.collisionBitMask = ColliderType.gap.rawValue
            movingObjects.addChild(gap)
            
        }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.gap.rawValue{
            
            score += 1
            scoreLabel.text = String(score)
            
            /* define a highscore */
            if score > highscore {
                highscore = score
                highscoreLabel.text = NSString(format: "Highscore: %i", highscore) as String
                let highscoreDefault = UserDefaults.standard
                highscoreDefault.set(highscore, forKey: "highscore")
                highscoreDefault.synchronize()
            }
            
        } else {
            
            if gameOver == false {
                gameOver = true
                self.speed = 0
                
                /* creat a highscore label */
                highscoreLabel.fontName = "04b_19"
                highscoreLabel.fontSize = 24
                highscoreLabel.text = NSString(format: "Best result: %i", highscore) as String
                highscoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 150)
                highscoreLabel.zPosition = 4
                labelContainer.addChild(highscoreLabel)
       
                /* creat a gameover label */
                gameoverLabel.fontName = "04b_19"
                gameoverLabel.fontSize = 24
                gameoverLabel.text = "Game Over! Tipe to play again."
                gameoverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
                gameoverLabel.zPosition = 4
                labelContainer.addChild(gameoverLabel)
                
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
            
            /* interact with tapping on the screen */
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
            bird.physicsBody?.affectedByGravity = true
            
        } else {
        
            score = 0
            scoreLabel.text = "0"
            bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            movingObjects.removeAllChildren()
            makebg()
            self.speed = 1
            gameOver = false
            labelContainer.removeAllChildren()
        }
    }
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
