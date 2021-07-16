//
//  GameScene.swift
//  Pong
//
//  Created by Isi Donnelly on 11/12/19.
//  Copyright © 2019 Go Deep Games. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //initial variable setup
    var ball = SKSpriteNode()
    var enemyPaddle = SKSpriteNode()
    var mainPaddle = SKSpriteNode()
    var playerOneScore = SKLabelNode()
    var playerTwoScore = SKLabelNode()
    var ready = SKLabelNode()
    var score = [Int]()
    var inGame = false
    var logo = SKSpriteNode()
    var pong = SKLabelNode()
    let net = Network()
    
    override func didMove(to view: SKView) {
        
        //assign sprite nodes
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        enemyPaddle = self.childNode(withName: "enemyPaddle") as! SKSpriteNode
        mainPaddle = self.childNode(withName: "mainPaddle") as! SKSpriteNode
        playerOneScore = self.childNode(withName: "playerOneScore") as! SKLabelNode
        playerTwoScore = self.childNode(withName: "playerTwoScore") as! SKLabelNode
        ready = self.childNode(withName: "Ready") as! SKLabelNode
        logo = self.childNode(withName: "Logo") as! SKSpriteNode
        pong = self.childNode(withName: "Pong") as! SKLabelNode
        
        //setup border
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        }
        
    
    
    func startGame() {
        
        self.ready.text = "Waiting For Opponent..."
        self.ready.fontSize = 65
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1){
            while self.inGame == false{
                let resp = self.net.send(data: "ready")
                if resp == "game starting" {self.inGame = true}
            }
        }
        ball.position = CGPoint(x:0, y:-300)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2){
            self.ready.text = ""
            self.ready.fontSize = 100
            let velocity: Int! = Int(arc4random_uniform(35)+5)
            self.ball.physicsBody?.applyImpulse(CGVector(dx: velocity, dy: 20))
            self.score = [0,0]
            self.playerTwoScore.text = "0"
            self.playerOneScore.text = "0"
        }
    }
    
    
    func addScore(playerWhoWon: SKSpriteNode){
        ready.text = "Ready"
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        
        if playerWhoWon == mainPaddle{
            ball.position = CGPoint(x:0, y:300)
            score[0] += 1
            playerOneScore.text = "\(self.score[0])"
        }
        
        if playerWhoWon == enemyPaddle{
            ball.position = CGPoint(x:0, y:-300)
            score[1] += 1
            playerTwoScore.text = "\(self.score[1])"
        }
        
        if score[1] == 5{
            inGame = false
            ball.position = CGPoint(x:500, y:0)
            logo.texture = SKTexture(imageNamed: "Logo")
            pong.text = "Player 2 Wins!"
            ready.text = "Tap to Begin"
            return
        }
        
        if score[0] == 5{
            inGame = false
            ball.position = CGPoint(x:500, y:0)
            logo.texture = SKTexture(imageNamed: "Logo")
            pong.text = "Player 1 Wins!"
            ready.text = "Tap to Begin"
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2){
            self.ready.text = ""
                    
            if playerWhoWon == self.mainPaddle{
                let velocity: Int! = Int(arc4random_uniform(35)+5)
                let negVelocity: Int! = 0 - velocity
                self.ball.physicsBody?.applyImpulse(CGVector(dx: negVelocity, dy: -20))
            }
            
            if playerWhoWon == self.enemyPaddle{
                let velocity: Int! = Int(arc4random_uniform(35)+5)
                self.ball.physicsBody?.applyImpulse(CGVector(dx: velocity, dy: 20))
            }
        }
        
        
    }
    
    
    //when the user first taps the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            //move the paddle to the location
            let location = touch.location(in: self)
            mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0))
        }
        
    }
    
    //when the user moves their touch
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            if inGame == false{
                pong.text = ""
                logo.texture = SKTexture(imageNamed: "Nothing")
                playerOneScore.text = "0"
                playerTwoScore.text = "0"
                startGame()
            }
            
            let location = touch.location(in: self)
            mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0))
      
    }
    
    }
    
    //called every frame
    override func update(_ currentTime: TimeInterval) {
        if ball.position.y < -640{
            addScore(playerWhoWon: enemyPaddle)
        }
        else if ball.position.y > 640{
            addScore(playerWhoWon: mainPaddle)
        }
        
        if inGame == true{
            
            let location = String(Int(Float(mainPaddle.position.x)))
            let data = net.send(data: location)
            
            guard let enemyLocation = NumberFormatter().number(from: data) else {return}
            
            enemyPaddle.run(SKAction.moveTo(x: CGFloat(enemyLocation), duration: 0))
            
            
            
        }
    }
    
}
