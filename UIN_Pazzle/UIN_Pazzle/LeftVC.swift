//
//  LeftVC.swift
//  UIN_Pazzle
//
//  Created by Михаил Фокин on 01.05.2021.
//

import Cocoa

class LeftVC: NSViewController {
    
    @IBOutlet weak var statusSolution: NSTextField!
    @IBOutlet weak var text: NSScrollView!
    
    weak var gameVC: GameViewController?
    var board: Board?
    var size = 3
    
    @IBAction func buttonChengeNumber(_ sender: NSButton) {
        guard let gameVC = self.gameVC else { return }
        do {
            guard let textView : NSTextView = text?.documentView as? NSTextView else { return }
            let text = textView.string
            if text.isEmpty {
                throw Exception(massage: "Empty data.")
            }
            let puzzle = Pazzle()
            try puzzle.run(text: text)
            guard let board = puzzle.board else { return }
            if board.size > 4 || board.size < 3 {
                throw Exception(massage: "Invalid size.")
            }
            statusSolution.textColor = .green
            statusSolution.stringValue = "Has a solution."
            //self.board = board
            if gameVC.board == nil || gameVC.board?.size != board.size {
                gameVC.board = board
                gameVC.size = board.size
                gameVC.viewDidLoad()
            } else {
                gameVC.animateNewBoard(board: board)
            }
            
        } catch let exception as Exception {
            systemError(massage: exception.massage)
        } catch {
            systemError(massage: "Unknown error.")
        }
    }
    
    @IBAction func buttonMenu(_ sender: NSPopUpButton) {
        guard let gameVC = self.gameVC else { return }
        
        switch sender.indexOfSelectedItem {
        case 0:
            self.size = 3
        default:
            self.size = 4
        }
        let board = Board(size: self.size)
        if gameVC.board == nil || gameVC.board?.size != board.size {
            gameVC.board = board
            gameVC.size = board.size
            gameVC.viewDidLoad()
        } else {
            gameVC.animateNewBoard(board: board)
        }
    }
    
    // MARK: Вывод сообщения об ошибке в поток ошибок
    private func systemError(massage: String) {
        statusSolution.isHidden = false
        statusSolution.textColor = .red
        statusSolution.stringValue = massage
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let gameVC = self.gameVC else { return }
        gameVC.board = Board(size: self.size)
        gameVC.viewDidLoad()
    }
    
}
