//
//  ViewController.swift
//  Basketball
//
//  Created by Andriy Trubchanin on 10/16/18.
//  Copyright © 2018 onlinico. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var backboardNode: SCNNode?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene()
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        addBackboard()
        registerGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: -
    func addBackboard()
    {
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else { return }
        self.backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false)
        guard let backboardNode = backboardNode else { return }
        
        backboardNode.position = SCNVector3(x: 0, y: 1, z: -5)
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])    // to make hole in the hoop
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        backboardNode.physicsBody = physicsBody

        sceneView.scene.rootNode.addChildNode(backboardNode)
        
        //horizontalAction(node: backboardNode)
        //roundAction(node: backboardNode)
    }
    
    func horizontalAction(node: SCNNode) {
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 3)
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 3)
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
    
    func roundAction(node: SCNNode) {
        let upLeft = SCNAction.move(by: SCNVector3(x: 1, y: 1, z: 0), duration: 2)
        let downLeft = SCNAction.move(by: SCNVector3(x: 1, y: -1, z: 0), duration: 2)
        let downRight = SCNAction.move(by: SCNVector3(x: -1, y: -1, z: 0), duration: 2)
        let upRight = SCNAction.move(by: SCNVector3(x: -1, y: 1, z: 0), duration: 2)

        let actionSequence = SCNAction.sequence([upLeft, downLeft, downRight, upRight])
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
    
    func registerGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView,
        let cameraPoint = sceneView.pointOfView
            else { return }
        
        let cameraTransform = cameraPoint.transform
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        let cameraPosition = SCNVector3(x: cameraLocation.x + cameraOrientation.x, y: cameraLocation.y + cameraOrientation.y, z: cameraLocation.z + cameraOrientation.z)
        
        let ball = SCNSphere(radius: 0.15)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "basketballSkin")
        ball.materials = [material]
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = cameraPosition
        
        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        ballNode.physicsBody = physicsBody
        
        let forceVector: Float = 7
        ballNode.physicsBody?.applyForce(SCNVector3(x: cameraOrientation.x * forceVector, y: (cameraOrientation.y + 0.5) * forceVector, z: cameraOrientation.z * forceVector), asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(ballNode)
    }
    
    @IBAction func horizontalAction(_ sender: UIButton) {
        if let backboardNode = backboardNode {
            horizontalAction(node: backboardNode)
        }
    }
    
    @IBAction func stopActions(_ sender: UIButton) {
        backboardNode?.removeAllActions()
    }
    
    @IBAction func roundAction(_ sender: UIButton) {
        if let backboardNode = backboardNode {
            roundAction(node: backboardNode)
        }
    }
    
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate
{
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
