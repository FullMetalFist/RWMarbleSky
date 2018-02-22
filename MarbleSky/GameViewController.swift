//
//  GameViewController.swift
//  MarbleSky
//
//  Created by Michael Vilabrera on 6/28/17.
//  Copyright © 2017 Michael Vilabrera. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var game = GameHelper.sharedInstance
    var motion = CoreMotionHelper()
    var motionForce = SCNVector3(x: 0, y: 0, z: 0)
    
    var scnView: SCNView!
    
    var scnScene: SCNScene!
    
    let CollisionCategoryBall = 1
    let CollisionCategoryStone = 2
    let CollisionCategoryPillar = 4
    let CollisionCategoryCrate = 8
    let CollisionCategoryPearl = 16
    
    var ballNode: SCNNode!
    
    var cameraNode: SCNNode!
    
    var cameraFollowNode: SCNNode!
    var lightFollowNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNodes()
        setupSounds()
        
        resetGame()
    }
    
    func setupScene() {
        scnView = self.view as! SCNView
        scnView.delegate = self
        //scnView.allowsCameraControl = true
        //scnView.showsStatistics = true
        
        scnScene = SCNScene(named: "art.scnassets/game.scn")
        scnView.scene = scnScene
        
        scnScene.physicsWorld.contactDelegate = self
    }
    
    func setupNodes() {
        ballNode = scnScene.rootNode.childNode(withName: "ball", recursively: true)!
        ballNode.physicsBody?.contactTestBitMask = CollisionCategoryPillar | CollisionCategoryCrate | CollisionCategoryPearl
        
        cameraNode = scnScene.rootNode.childNode(withName: "camera", recursively: true)!
        let constraint = SCNLookAtConstraint(target: ballNode)
        cameraNode.constraints = [constraint]
        
        constraint.isGimbalLockEnabled = true
        
        cameraFollowNode = scnScene.rootNode.childNode(withName: "follow_camera", recursively: true)!
        cameraNode.addChildNode(game.hudNode)
        lightFollowNode = scnScene.rootNode.childNode(withName: "follow_light", recursively: true)!
    }
    
    func setupSounds() {
        game.loadSound(name: "GameOver", fileNamed: "GameOver.wav")
        game.loadSound(name: "Powerup", fileNamed: "Powerup.wav")
        game.loadSound(name: "Reset", fileNamed: "Reset.wav")
        game.loadSound(name: "Bump", fileNamed: "Bump.wav")
    }
    
    override var shouldAutorotate: Bool { return false }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    func playGame() {
        game.state = GameStateType.playing
        cameraFollowNode.eulerAngles.y = 0
        cameraFollowNode.position = SCNVector3Zero
    }
    
    func resetGame() {
        game.state = GameStateType.tapToPlay
        game.playSound(node: ballNode, name: "Reset")
        ballNode.physicsBody!.velocity = SCNVector3Zero
        ballNode.position = SCNVector3(x: 0, y: 10, z: 0)
        cameraFollowNode.position = ballNode.position
        lightFollowNode.position = ballNode.position
        scnView.isPlaying = true
        game.reset()
    }
    
    func testForGameOver() {
        if ballNode.presentation.position.y < -5 {
            game.state = GameStateType.gameOver
            game.playSound(node: ballNode, name: "GameOver")
            ballNode.runAction(SCNAction.waitForDurationThenRunBlock(duration: 5, block: { (node: SCNNode!) in
                self.resetGame()
            }))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.state == GameStateType.tapToPlay {
            playGame()
        }
    }
    
    func updateMotionControl() {
        if game.state == GameStateType.playing {
            motion.getAccelerometerData(interval: 0.1, closure: { (x, y, z) in
                self.motionForce = SCNVector3(Float(x) * 0.05, 0, Float(y + 0.8) * -0.05)
            })
            ballNode.physicsBody!.velocity += motionForce
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updateMotionControl()
    }
}

extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode: SCNNode!
        if contact.nodeA.name == "ball" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        if contactNode.physicsBody?.categoryBitMask == CollisionCategoryPearl {
            contactNode.isHidden = true
            contactNode.runAction(SCNAction.waitForDurationThenRunBlock(duration: 30, block: { (node: SCNNode!) -> Void in
                node.isHidden = false
            }))
        }
        
        if contactNode.physicsBody?.categoryBitMask == CollisionCategoryPillar || contactNode.physicsBody?.categoryBitMask == CollisionCategoryCrate {
            
        }
    }
}
