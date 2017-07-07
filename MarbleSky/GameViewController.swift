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
    
    var scnView: SCNView!
    
    var scnScene: SCNScene!
    
    let CollisionCategoryBall = 1
    let CollisionCategoryStone = 2
    let CollisionCategoryPillar = 4
    let CollisionCategoryCrate = 8
    let CollisionCategoryPearl = 16
    
    var ballNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNodes()
        setupSounds()
    }
    
    func setupScene() {
        scnView = self.view as! SCNView
        scnView.delegate = self
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        
        scnScene = SCNScene(named: "art.scnassets/game.scn")
        scnView.scene = scnScene
        
        scnScene.physicsWorld.contactDelegate = self
    }
    
    func setupNodes() {
        ballNode = scnScene.rootNode.childNode(withName: "ball", recursively: true)!
        ballNode.physicsBody?.contactTestBitMask = CollisionCategoryPillar | CollisionCategoryCrate | CollisionCategoryPearl
    }
    
    func setupSounds() {
        
    }
    
    override var shouldAutorotate: Bool { return false }
    
    override var prefersStatusBarHidden: Bool { return true }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
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
