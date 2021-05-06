//
//  LeftVC.swift
//  UIN_Pazzle
//
//  Created by Михаил Фокин on 01.05.2021.
//

import Cocoa

class SettingsVC: NSViewController {
    
    @IBOutlet weak var statusSolution: NSTextField!
    @IBOutlet weak var text: NSScrollView!
    @IBOutlet weak var lableDuraction: NSTextField!
    @IBOutlet weak var stepper: NSStepper!
    @IBOutlet weak var indicator: NSProgressIndicator!
    @IBOutlet weak var lableTargetMultiLine: NSTextField!
    @IBOutlet weak var lableTarget: NSTextField!
    @IBOutlet weak var segment: NSSegmentedControl!
    @IBOutlet weak var complexityTime: NSTextField!
    @IBOutlet weak var complexitySize: NSTextField!
    @IBOutlet weak var stateToSolution: NSTextField!
    @IBOutlet weak var lableIteration: NSTextField!
    
    @IBOutlet weak var buttonGenerate: NSButton!
    @IBOutlet weak var buttonReadPuzzle: NSButton!
    @IBOutlet weak var buttonSolvePuzzle: NSButton!
    @IBOutlet weak var buttonSegments: NSSegmentedCell!
    
    
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
    
    // MARK: Нажатие на степер. Изменение времени движения одного кубика.
    @IBAction func buttonStepper(_ sender: NSStepper) {
        guard let gameVC = self.gameVC else { return }
        let duration = sender.doubleValue / 10
        lableDuraction.stringValue = String(duration)
        gameVC.duraction = duration
    }
    
    // MARK: Отображение состояния-решения. Классичекие или улитка. Очищает поле ввода головоломки.
    @IBAction func buttonSegment(_ sender: NSSegmentedControl) {
        guard let gameVC = self.gameVC else { return }
        clearTextView()
        let boardTarget = updateLableTargetMultiply(sender)
        gameVC.board = boardTarget
        gameVC.size = boardTarget.size
        if self.puzzle == nil {
            self.puzzle = Puzzle(type: self.type)
            gameVC.viewDidLoad()
        } else {
            gameVC.animateNewBoard(board: boardTarget)
        }
        self.puzzle?.board = boardTarget
        self.puzzle?.boardTarget = Board(size: self.size, type: self.type)
    }
    
    // MARK: Очищает самое нижнее текстовое поле, в которое вписывается новая доска.
    private func clearTextView() {
        guard let textView : NSTextView = text?.documentView as? NSTextView else { return }
        textView.string.removeAll()
    }
    
    // MARK: Обновление доски целию, согласно действующим настройкам.
    private func updateLableTargetMultiply(_ sender: NSSegmentedControl) -> Board {
        switch sender.indexOfSelectedItem {
        case 0:
            self.type = .snail
        case 1:
            self.type = .classic
        default:
            self.type = .snake
        }
        lableTarget.stringValue = self.type.rawValue
        let boardTarget = Board(size: self.size, type: self.type)
        lableTargetMultiLine.stringValue = boardTarget.valueString()
        return boardTarget
    }
    
    // MARK: Выбор размера головоломки 3 или 4
    @IBAction func buttonMenu(_ sender: NSPopUpButton) {
        guard let gameVC = self.gameVC else { return }
        guard gameVC.movingPazzle == true else { return }
        if self.puzzle == nil {
            self.puzzle = Puzzle(type: self.type)
        }
        switch sender.indexOfSelectedItem {
        case 0:
            self.size = 3
        default:
            self.size = 4
        }
        let board = Board(size: self.size, type: self.type)
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
        clearTextView()
        _ = updateLableTargetMultiply(self.segment)
    }
    
    // MARK: Установка отображения количества итерация при генерации новой головоломки
    @IBAction func buttonStepperIteration(_ sender: NSStepper) {
        self.lableIteration.stringValue = sender.stringValue
    }
    
    // MARK: Установка настроек перед поиском решений
    private func setingsBeforeSolution() {
        self.indicator.isHidden = false
        self.indicator.startAnimation(nil)
        self.gameVC?.movingPazzle = false
        self.buttonSegments.isEnabled = false
        self.buttonGenerate.isEnabled = false
        self.buttonReadPuzzle.isEnabled = false
        self.buttonSolvePuzzle.isEnabled = false
        self.complexityTime.stringValue = String(0)
        self.complexitySize.stringValue = String(0)
        self.stateToSolution.stringValue = String(0)
    }
    
    // MARK: Установка настроек после поиска решений
    private func setingsAfterSolution(solution: (Board, Int, Int)) {
        self.complexityTime.stringValue = String(solution.1)
        self.complexitySize.stringValue = String(solution.2)
        self.stateToSolution.stringValue = String(solution.0.g)
        self.indicator.stopAnimation(nil)
        self.indicator.isHidden = true
        self.gameVC?.movingPazzle = true
        self.buttonSegments.isEnabled = true
        self.buttonGenerate.isEnabled = true
        self.buttonReadPuzzle.isEnabled = true
        self.buttonSolvePuzzle.isEnabled = true
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
        setingsBeforeSolution()
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            let main = DispatchQueue.main
            guard let solution = puzzle.searchSolutionWithHeap() else {
                main.async {
                    self.systemError(massage: "The solution takes a long time.")
                    self.indicator.stopAnimation(nil)
                    self.indicator.isHidden = true
                }
                return
            }
            var boards = [Board]()
            var iter: Board? = solution.0
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
            main.async {
                gameVC.moveAllNumbers(positions: coordinats)
                self.setingsAfterSolution(solution: solution)
            }
        }
    }
    
    // MARK: Генерирует новую головоломку.
    @IBAction func buttonGenerate(_ sender: Any) {
        guard let textView : NSTextView = text?.documentView as? NSTextView else { return }
        guard let iterations = Int(self.lableIteration.stringValue) else { return }
        let board = Board(size: self.size, iterations: iterations, type: self.type)
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
            if board.size < 3 || board.size > 4 {
                throw Exception(massage: "Invalid size.")
            }
            setStatusString(color: .green, status: "Has a solution.")
            if gameVC.board == nil || gameVC.board?.size != board.size {
                gameVC.board = board
                gameVC.size = board.size
                gameVC.viewDidLoad()
            } else {
                gameVC.board = board
                gameVC.size = board.size
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
        alert.alertStyle = .critical
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
