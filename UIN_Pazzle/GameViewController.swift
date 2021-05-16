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
    var movingPazzle: Bool?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.len = 4
        self.delta = 3
        self.duraction = 0.2
        self.movingPazzle = true
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
        
        // Настройти размеров для кубиков
        if self.size == nil {
            self.size = 1
        }
        self.len = 4
        self.delta = 1
        guard let size = self.size else { return }
        guard let len = self.len else { return }
        guard let delta = self.delta else { return }
        
        // Добавление матрицы объектов
        addMatrixBox(size: size, len: len, delta: delta)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        //scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
    }
    
    // MARK: Добавление матрицы кубиков на сцену.
    private func addMatrixBox(size: Int, len: Int, delta: Int) {
        guard let scene = self.scene else { return }
        guard let board = self.board else { return }
        let letBox = len + delta
        for i in 0..<size {
            for j in 0..<size {
                let number = Int(board.matrix[i][j])
                if number == 0 { continue }
                let box = getBox(x: i * letBox, y: j * letBox, len: len, number: number)
                scene.rootNode.addChildNode(box)
            }
        }
    }
    
    // MARK: Создание одного кубика с заданными настройками и позицией.
    private func getBox(x: Int, y: Int, len: Int, number: Int) -> SCNNode {
        let box = SCNNode()
        let len = CGFloat(len)
        box.geometry = SCNBox(width: len, height: len, length: len, chamferRadius: 1)
        let im = NSImage(named: "\(number)")
        
        let material = SCNMaterial()
        material.diffuse.contents = im
        material.specular.contents = NSImage(named: "bubble")
        
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
            
            // взятие позиции кубика, на который кликнули.
            let position = result.node.position
            let coordinate = (Int(position.x), Int(position.y))
            var actions = [SCNAction]()
            
            // если можно двигать - двигаем кубик
            if self.movingPazzle == true && moveNumber(actions: &actions, position: coordinate) {
                if let node = self.scene?.rootNode.childNodes.first {
                    let sequence = SCNAction.sequence(actions)
                    node.runAction(sequence)
                }
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
        if let node = self.scene?.rootNode.childNodes.first {
            let sequence = SCNAction.sequence(actions)
            node.runAction(sequence)
        }
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
                let action = SCNAction.customAction(duration: duration, action: {(nodeA, elapsedTime) in
                    node.runAction(SCNAction.move(to: SCNVector3(x: x, y: y, z: 0), duration: duration))
                })
                actions.append(action)
                board.swapNumber(numberFrom: number, numberTo: 0)
                return true
            }
        }
        return false
    }
    
    //MARK: Возвращет узел из списка rootNode.childNodes с указанным номером. Номер соответствует имени картинки.
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
    
    // MARK: Все кубики возвращаются на места-цели согласно boardTarget
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
    
    // MARK: Возвращает соседний номер соответствующий заданной позиции в пространстве.
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
