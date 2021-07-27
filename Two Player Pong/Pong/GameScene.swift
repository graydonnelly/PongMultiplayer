//
//  GameScene.swift
//  Pong
//
//  Created by Isi Donnelly on 11/12/19.
//  Copyright © 2019 Go Deep Games. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
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
    var startingVelocities = [Int]()
    var starting = Bool()
    var pointNumber = 0
    let net = Network()
    
    var x = 0
    
    
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
        
        mainPaddle.name = "main"
        
        //setup contact
        physicsWorld.contactDelegate = self
        //ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
        mainPaddle.physicsBody!.contactTestBitMask = mainPaddle.physicsBody!.collisionBitMask
        
        self.ball.physicsBody?.isDynamic = true
        
        //setup border
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        }
        
    
    
    func startGame() {
        
        self.pointNumber = 0
        self.ready.text = "Waiting For Opponent..."
        self.ready.fontSize = 65
        
        while self.inGame == false{
            
            var data = DataToSend()
            data.looking_for_game = true
            let resp = net.send(data: data)
            //print("RESPONSE:", resp)
            if resp.in_game!{
                self.startingVelocities = resp.initial_velocities!
                self.starting = resp.starting!
                self.inGame = true
                self.ready.text = "Ready"
            }
            
        }
        
        
        if self.starting{ball.position = CGPoint(x:0, y:300)}
        if !self.starting{ball.position = CGPoint(x:0, y:-300)}
            
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2){
            self.ready.text = ""
            self.ready.fontSize = 100
            let velocity: Int! = self.startingVelocities[self.pointNumber]
            if self.starting{self.ball.physicsBody?.applyImpulse(CGVector(dx: velocity, dy: -20))}
            if !self.starting{self.ball.physicsBody?.applyImpulse(CGVector(dx: velocity, dy: 20))}
            self.score = [0,0]
            self.playerTwoScore.text = "0"
            self.playerOneScore.text = "0"
        }
    }
    
    func moveBall(dx: CGFloat, dy: CGFloat){
        ball.physicsBody!.velocity.dx = dx
        ball.physicsBody!.velocity.dy = dy
    }
    
    func addScore(playerWhoWon: SKSpriteNode){
        
        ready.text = "Ready"
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        moveBall(dx:100,dy:100)
        self.pointNumber += 1
        
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
            self.inGame = false
            ball.position = CGPoint(x:500, y:0)
            logo.texture = SKTexture(imageNamed: "Logo")
            pong.text = "Player 2 Wins!"
            ready.text = "Tap to Begin"
            return
        }

        if score[0] == 5{
            self.inGame = false
            ball.position = CGPoint(x:500, y:0)
            logo.texture = SKTexture(imageNamed: "Logo")
            pong.text = "Player 1 Wins!"
            ready.text = "Tap to Begin"
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2){
        
            self.ready.text = ""
                        
            if playerWhoWon == self.mainPaddle{
                let velocity: Int! = self.startingVelocities[self.pointNumber]
                let negVelocity: Int! = 0 - velocity
                self.ball.physicsBody?.applyImpulse(CGVector(dx: negVelocity, dy: -20))
            }
                
            if playerWhoWon == self.enemyPaddle{
                let velocity: Int! = self.startingVelocities[self.pointNumber]
                self.ball.physicsBody?.applyImpulse(CGVector(dx: velocity, dy: 20))
            }
        
        }
        
    }
    
    
    //when the user first taps the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !self.inGame{
            pong.text = ""
            logo.texture = SKTexture(imageNamed: "Nothing")
            playerOneScore.text = "0"
            playerTwoScore.text = "0"
            startGame()
        }
        
        for touch in touches {
            
            if self.inGame{
                //move the paddle to the location
                let location = touch.location(in: self)
                mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0))
            }
            
        }
        
    }
    
    //when the user moves their touch
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            if self.inGame{
                let location = touch.location(in: self)
                mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0))
            }
        
    }
    
    }
    
    //called when there is contact
    func didEnd(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.node == mainPaddle || secondBody.node == mainPaddle{
            var data = DataToSend()
            data.ball_position_x = Float(ball.position.x)
            data.ball_position_y = Float(ball.position.y)
            data.ball_velocity_x = Float(ball.physicsBody!.velocity.dx)
            data.ball_velocity_y = Float(ball.physicsBody!.velocity.dy)
            data.should_update_ball = true
            net.send(data: data)
            
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
        
        if self.inGame{
            
            var data = DataToSend()
            data.paddle_position = Float(mainPaddle.position.x)
            let resp = net.send(data: data)
            if resp.enemy_paddle_position != nil{
                enemyPaddle.run(SKAction.moveTo(x: CGFloat(resp.enemy_paddle_position!), duration: 0))
            }
            if resp.should_update_ball == true{
                ball.position.x = CGFloat(resp.ball_position_x!)
                ball.position.y = CGFloat(resp.ball_position_y!)
                ball.physicsBody!.velocity.dx = CGFloat(resp.ball_velocity_x!)
                ball.physicsBody!.velocity.dy = CGFloat(resp.ball_velocity_y!)
                
                //self.ball.physicsBody?.velocity = CGVector(dx: CGFloat(resp.ball_velocity_x!), dy: CGFloat(resp.ball_velocity_y!))
                
                ball.position = CGPoint(x:0,y:0)
                moveBall(dx: 100, dy: 100)
                
                print(x)
                x += 1
                
            }
            
            
        }
    }
    
}
