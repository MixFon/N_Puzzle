//
//  GameViewController.swift
//  UIN_Pazzle
//
//  Created by Михаил Фокин on 29.04.2021.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    var scene: SCNScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        self.scene = SCNScene(named: "art.scnassets/ship.scn")
        
        guard let scene = self.scene else {
            return
        }
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        //let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        let size = 3
        let len = 4
        let delta = 1
        let plane = SCNNode()
        let square = (len + delta) * size
        plane.geometry = SCNPlane(width: CGFloat(square) , height: CGFloat(square))
        plane.position = SCNVector3(square / 2 - len / 2, square / 2 - len / 2, -1)
        //scene.rootNode.addChildNode(plane)
        addMatrixBox(size: size, len: len, delta: delta)
        
        // animate the 3d object
        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
    }
    
    private func addMatrixBox(size: Int, len: Int, delta: Int) {
        guard let scene = self.scene else { return }
        let board = Board(size: size)
        let square = (len + delta) * size
        for i in 0..<size {
            for j in 0..<size {
                let number = Int(board.matrix[i][j])
                if number == 0 {
                    continue
                }
                let box = getBox(x: i * (len + delta) - square / 2, y: j * (len + delta) - square / 2, len: len, number: number)
                scene.rootNode.addChildNode(box)
            }
        }
    }
    
    private func getBox(x: Int, y: Int, len: Int, number: Int) -> SCNNode {
        let box = SCNNode()
        let len = CGFloat(len)
        box.geometry = SCNBox(width: len, height: len, length: len, chamferRadius: 1)
        //box.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        //box.position = SCNVector3Make(x, y, 0)
        //box.geometry!.firstMaterial!.diffuse.contents = NSString(stringLiteral: "Hello")
        let im = NSImage(named: "\(number)")
        let material = SCNMaterial()
        material.diffuse.contents = im
        material.specular.contents = NSImage(named: "bubble")
        //material.specular.contents = NSColor.white
        material.shininess = 1
        
        box.geometry?.firstMaterial = material
        box.position = SCNVector3(y, -x, 0)
        return box
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            //result.node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 2, y: 2, z: 2, duration: 1)))
            result.node.runAction(SCNAction.repeat(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1), count: 1))
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = NSColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
        }
    }
}
