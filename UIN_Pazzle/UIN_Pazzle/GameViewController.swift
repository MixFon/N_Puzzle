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
    var board: Board?
    var size: Int?
    var len: Int?
    var delta: Int?
    var duraction: TimeInterval?
    //var nodes: [SCNNode]?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.len = 4
        self.delta = 3
        self.duraction = 0.5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        self.scene = SCNScene(named: "art.scnassets/ship.scn")
        guard let scene = self.scene else { return }
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 7, y: -7, z: 25)
        
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
        //let ship = scene.rootNode.childNode(withName: "box", recursively: true)!
        if self.size == nil {
            self.size = 1
        }
        self.len = 4
        self.delta = 1
        guard let size = self.size else { return }
        guard let len = self.len else { return }
        guard let delta = self.delta else { return }
        
        //self.board = Board(size: size)
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
        guard let board = self.board else { return }
        //let square = (len + delta) * size
        for i in 0..<size {
            for j in 0..<size {
                let number = Int(board.matrix[i][j])
                if number == 0 { continue }
                let box = getBox(x: i * (len + delta), y: j * (len + delta), len: len, number: number)
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
            //result.node.runAction(SCNAction.repeat(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1), count: 1))
            
            let position = result.node.position
            let coordinate = (Int(position.x), Int(position.y))
            //print(position)
            var actions = [SCNAction]()
            if moveNumber(actions: &actions, position: coordinate) {
                let sequence = SCNAction.sequence(actions)
                SCNNode().runAction(sequence)
                return
            }
        
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
    
    // MARK: Перемещает все кубики поочереди на пустое место.
    func moveAllNumbers(positions: [(Int, Int)]) {
        var actions = [SCNAction]()
        for position in positions {
            _ = moveNumber(actions: &actions, position: position)
        }
        let sequence = SCNAction.sequence(actions)
        SCNNode().runAction(sequence)
    }
    
    // MARK: Перемещает кубик в заданную координату. (На пустое место)
    func moveNumber( actions: inout [SCNAction], position: (Int, Int) ) -> Bool {
        guard let len = self.len else { return false }
        guard let delta = self.delta else { return false }
        guard let board = self.board else { return false }
        guard let duration = self.duraction else { return false }
        if let number = board.isNeighbors(nodePositiont: position, wight: len + delta) {
            guard let positionZero = board.coordinats[0] else { return false }
            let y = -CGFloat(positionZero.0) * CGFloat(len + delta)
            let x = CGFloat(positionZero.1) * CGFloat(len + delta)
            if let node = getNode(number: number) {
//                let action = SCNAction.customAction(duration: 1) { (nodeA, elapsedTime) in
//                    node.position = SCNVector3(x: x, y: y, z: 0)
//                }
                let action = SCNAction.customAction(duration: duration, action: {(nodeA, elapsedTime) in
                    //node.position = SCNVector3(x: x, y: y, z: 0)
                    node.runAction(SCNAction.move(to: SCNVector3(x: x, y: y, z: 0), duration: duration))
                    //SCNAction.move(to: SCNVector3(x: x, y: y, z: 0), duration: 0.5)
                })
                actions.append(action)
                //print(actions.count)
                //node.runAction(SCNAction.move(to: SCNVector3(x: x, y: y, z: 0), duration: 0.5))
                board.swapNumber(numberFrom: number, numberTo: 0)
                node.runAction(SCNAction.sequence(actions))
                return true
            }
        }
        return false
    }
    
    // Возвращет узел с указанным номером.
    private func getNode(number: Int16) -> SCNNode? {
        guard let nodes = self.scene?.rootNode.childNodes else { return nil }
        for node in nodes {
            if let im = node.geometry?.firstMaterial?.diffuse.contents as? NSImage {
                if im.name() == "\(number)" {
                    return node
                }
            }
        }
        return nil
    }
    
    func animateNewBoard(board: Board) {
        guard let len = self.len else { return }
        guard let delta = self.delta else { return }
        guard let duration = self.duraction else { return }
        for (number, coordinate) in board.coordinats {
            let y = -CGFloat(coordinate.0) * CGFloat(len + delta)
            let x = CGFloat(coordinate.1) * CGFloat(len + delta)
            if let node = getNode(number: number) {
                node.runAction(SCNAction.move(to: SCNVector3(x: x, y: y, z: 0), duration: duration))
            }
        }
        self.board = board
        self.size = board.size
    }
    
}

extension Board {
    func isNeighbors(nodePositiont: (Int, Int), wight: Int) -> Int16? {
        let neighbors = getNeighbors(number: 0)
        for neighbor in neighbors {
            guard let position = self.coordinats[Int16(neighbor)] else { return nil }
            let y = -position.0 * Int8(wight)
            let x = position.1 * Int8(wight)
            if nodePositiont.0 == x && nodePositiont.1 == y {
                return neighbor
            }
        }
        return nil
    }
}

extension SCNVector3 {
    static func ==(left: SCNVector3, right: SCNVector3) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z
    }
}