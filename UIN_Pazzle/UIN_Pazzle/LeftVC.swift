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
    @IBOutlet weak var lableDuraction: NSTextField!
    @IBOutlet weak var stepper: NSStepper!
    @IBOutlet weak var indicator: NSProgressIndicator!
    @IBOutlet weak var lableTargetMultiLine: NSTextField!
    @IBOutlet weak var lableTarget: NSTextField!
    @IBOutlet weak var segment: NSSegmentedControl!
    
    weak var gameVC: GameViewController?
    var puzzle: Puzzle?
    var type: TypePuzzle
    var size: Int
    
    required init?(coder: NSCoder) {
        self.size = 3
        self.type = .snail
        super.init(coder: coder)
    }
    
    // MARK: Нажатие кнопки для считывания головоломки из текстового поля.
    @IBAction func buttonReadPuzzle(_ sender: Any) {
        readPuzzle()
    }
    
    // MARK: Нажатие на степер.
    @IBAction func buttonStepper(_ sender: NSStepper) {
        guard let gameVC = self.gameVC else { return }
        let duration = sender.doubleValue / 10
        lableDuraction.stringValue = String(duration)
        gameVC.duraction = duration
    }
    
    // MARK: Отображение состояния-решения. Классичекие или улитка.
    @IBAction func buttonSegment(_ sender: NSSegmentedControl) {
        guard let gameVC = self.gameVC else { return }
        guard let textView : NSTextView = text?.documentView as? NSTextView else { return }
        textView.string.removeAll()
        let boardTarget = updateLableTargetMultiply(sender)
        if self.puzzle == nil {
            self.puzzle = Puzzle(type: self.type)
        }
        self.puzzle?.board = boardTarget
        self.puzzle?.boardTarget = Board(size: self.size, type: self.type)
        gameVC.animateNewBoard(board: boardTarget)
    }
    
    // MARK: Обновление доски целию, согласно действующим настройкам.
    private func updateLableTargetMultiply(_ sender: NSSegmentedControl) -> Board {
        switch sender.indexOfSelectedItem {
        case 0:
            self.type = .snail
        default:
            self.type = .classic
        }
        lableTarget.stringValue = self.type.rawValue
        let boardTarget = Board(size: self.size, type: self.type)
        lableTargetMultiLine.stringValue = boardTarget.valueString()
        return boardTarget
    }
    
    // MARK: Выбор размера головоломки 3 или 4
    @IBAction func buttonMenu(_ sender: NSPopUpButton) {
        guard let gameVC = self.gameVC else { return }
        if self.puzzle == nil {
            self.puzzle = Puzzle(type: self.type)
        }
        switch sender.indexOfSelectedItem {
        case 0:
            self.size = 3
        default:
            self.size = 4
        }
        let board = Board(size: self.size,type: self.type)
        setStatusString(color: .green, status: "This is the solution.")
        if gameVC.board == nil || gameVC.board?.size != board.size {
            gameVC.board = board
            gameVC.size = board.size
            gameVC.viewDidLoad()
        } else {
            gameVC.animateNewBoard(board: board)
        }
        self.puzzle?.board = board
        self.puzzle?.boardTarget = Board(size: self.size,type: self.type)
        _ = updateLableTargetMultiply(self.segment)
    }
    
    // MARK: Решить головоломку, на основании текущего состояния доски.
    @IBAction func buttorSolvePuzzle(_ sender: NSButton) {
        guard let gameVC = self.gameVC else { return }
        guard let puzzle = self.puzzle else { return }
        guard puzzle.board != nil else { return }
        guard puzzle.isSolution() else {
            setStatusString(color: .red, status: "Has no solution.")
            return
        }
        self.indicator.isHidden = false
        self.indicator.startAnimation(nil)
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            guard let solution = puzzle.searchSolutionWithHeap() else {
                self.systemError(massage: "The solution takes a long time.")
                return
            }
            var boards = [Board]()
            var iter: Board? = solution
            while iter != nil {
                boards.insert(iter!, at: 0)
                iter = iter?.parent
            }
            //boards.forEach( { $0.print() } )
            var coordinats = [(Int, Int)]()
            for board in boards[1...] {
                let coordinatZero = board.getCoordinatsNumber(number: 0)
                coordinats.append((Int(coordinatZero.1 * 5), Int(coordinatZero.0 * (-5))))
            }
            let main = DispatchQueue.main
            main.async {
                self.indicator.stopAnimation(nil)
                self.indicator.isHidden = true
                gameVC.moveAllNumbers(positions: coordinats)
            }
        }
    }
    
    // MARK: Генерирует новую головоломку.
    @IBAction func buttonGenerate(_ sender: Any) {
        guard let textView : NSTextView = text?.documentView as? NSTextView else { return }
        let board = Board(size: self.size, iterations: 110, type: self.type)
        textView.string = board.valueString()
        readPuzzle()
    }
    
    // MARK: Считывание новой головоломки из текстового поля. И Обновление представление.
    private func readPuzzle() {
        guard let gameVC = self.gameVC else { return }
        do {
            guard let textView : NSTextView = text?.documentView as? NSTextView else { return }
            let text = textView.string
            if text.isEmpty {
                throw Exception(massage: "Empty data.")
            }
            let puzzle = try Puzzle(text: text, type: self.type)
            guard let board = puzzle.board else { return }
            if board.size > 4 || board.size < 3 {
                throw Exception(massage: "Invalid size.")
            }
            setStatusString(color: .green, status: "Has a solution.")
            if gameVC.board == nil || gameVC.board?.size != board.size {
                gameVC.board = board
                gameVC.size = board.size
                gameVC.viewDidLoad()
            } else {
                gameVC.animateNewBoard(board: board)
            }
            self.size = board.size
            self.puzzle = puzzle
            _ = updateLableTargetMultiply(self.segment)
        } catch let exception as Exception {
            systemError(massage: exception.massage)
        } catch {
            systemError(massage: "Unknown error.")
        }
    }
    
    // MARK: Устанавливает строку состояния нужного цвета.
    private func setStatusString(color: NSColor, status: String) {
        statusSolution.textColor = color
        statusSolution.stringValue = status
    }
    
    
    // MARK: Вывод сообщения об ошибке в поток ошибок
    private func systemError(massage: String) {
        //statusSolution.isHidden = false
        //setStatusString(color: .red, status: massage)
        let alert = NSAlert()
        alert.messageText = massage
        //alert.alertStyle =
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lableDuraction.stringValue = String(stepper.doubleValue / 10)
        self.type = .snail
        self.segment.selectedSegment = 0
        _ = updateLableTargetMultiply(self.segment)
    }
    
}
