//
//  Board.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 21.04.2021.
//

import Foundation

class Board: Equatable {
    var size: Int
    var matrix: [[Int16]]
    var coordinats = [Int16: (Int8, Int8)]()
    var f: Int
    var g: Int
    var parent: Board?
    
    // MARK: Создание доски на основе матрицы и размера
    init(size: Int, matrix: [[Int16]]) throws {
        self.size = size
        self.matrix = matrix
        self.f = 0
        self.g = 0
        try checkBoard()
        getCoordinats()
    }
    
    // MARK: Создание доски-решения указанного типа
    init(size: Int, type: TypePuzzle) {
        self.size = size
        self.matrix = Array(repeating: Array(repeating: 0, count: size), count: size)
        self.f = 0
        self.g = 0
        switch type {
        case .classic:
            fillBoardClassic()
        case .snail:
            fillBoardSnail()
        default:
            fillBoardSnake()
        }
        getCoordinats()
    }
    
    // MARK: Геренация новой доски сделавшей заданное количества итераций от первоначального состояния.
    convenience init(size: Int, iterations: Int, type: TypePuzzle) {
        self.init(size: size, type: type)
        var previeos: Int16 = 0
        for _ in 0...iterations {
            while true {
                let neighbors = getNeighbors(number: 0)
                guard let randomElement = neighbors.randomElement() else { break }
                if previeos != randomElement {
                    swapNumber(numberFrom: randomElement, numberTo: 0)
                    previeos = randomElement
                    break
                }
            }
        }
    }
    
    // MARK: Конструктор копирования.
    init(board: Board) {
        self.size = board.size
        self.matrix = board.matrix
        self.f = board.f
        self.g = board.g + 1
        self.parent = board
        self.coordinats = board.coordinats
    }
    
    // MARK: Возвращет головоломку в виде строки
    func valueString() -> String {
        var result = " \(self.size)\n"
        for row in self.matrix {
            for element in row {
                result += String(format: "%03.2d", element)
            }
            result.append("\n")
        }
        return result
    }
    
    // MARK: Устанавливает значение f
    func setF(heuristic: Int) {
        self.f = self.g + heuristic
    }
    
    // MARK: Возвращает координаты ячейки с номером.
    func getCoordinatsNumber(number: Int16) -> (Int8, Int8) {
        guard let coordinats = self.coordinats[number] else { return (Int8.max, Int8.max) }
        return coordinats
    }
    
    // MARK: Возвращает номера соседних ячеек с number.
    func getNeighbors(number: Int16) -> [Int16] {
        var result = [Int16]()
        guard let coordinats = self.coordinats[number] else {
            return []
        }
        if coordinats.1 - 1 >= 0 {
            result.append(matrix[Int(coordinats.0)][Int(coordinats.1) - 1])
        }
        if coordinats.0 - 1 >= 0 {
            result.append(matrix[Int(coordinats.0) - 1][Int(coordinats.1)])
        }
        if coordinats.1 + 1 < self.size {
            result.append(matrix[Int(coordinats.0)][Int(coordinats.1) + 1])
        }
        if coordinats.0 + 1 < self.size {
            result.append(matrix[Int(coordinats.0) + 1][Int(coordinats.1)])
        }
        return result
    }
    
    // MARK: Заполняет доску классическим способом Classic.
    private func fillBoardClassic() {
        var iter:Int16 = 1
        for i in 0..<self.size {
            for j in 0..<self.size {
                self.matrix[i][j] = iter
                iter += 1
            }
        }
        self.matrix[self.size - 1][self.size - 1] = 0
    }
    
    // MARK: Заполняет доску в виде змейки Snake.
    private func fillBoardSnake() {
        fillBoardClassic()
        for i in 0..<self.size {
            if i % 2 != 0 {
                self.matrix[i].reverse()
            }
        }
    }
    
    // MARK: Заполняет доску по спирали Snail.
    private func fillBoardSnail() {
        var filler: Int16 = 1
        for i in 0..<self.size {
            self.matrix[0][i] = filler
            filler += 1
        }
        for i in 1..<self.size {
            self.matrix[i][self.size - 1] = filler
            filler += 1
        }
        var y = self.size - 2
        while y >= 0 {
            self.matrix[self.size - 1][y] = filler
            filler += 1
            y -= 1
        }
        var x = self.size - 2
        while x > 0 {
            self.matrix[x][0] = filler
            filler += 1
            x -= 1
        }
        fillSquare(filler: filler)
    }
    
    // MARK: Заполняет внутренюю часть квадрата для Snail.
    private func fillSquare(filler: Int16) {
        var filler = filler
        let end = self.size * self.size
        var x = 1
        var y = 1
        while filler < end {
            while self.matrix[x][y + 1] == 0 {
                self.matrix[x][y] = filler
                y += 1
                filler += 1
            }
            while self.matrix[x + 1][y] == 0 {
                self.matrix[x][y] = filler
                x += 1
                filler += 1
            }
            while self.matrix[x - 1][y] == 0 {
                self.matrix[x][y] = filler
                x -= 1
                filler += 1
            }
            while self.matrix[x][y - 1] == 0 {
                self.matrix[x][y] = filler
                y -= 1
                filler += 1
            }
        }
    }
    
    // MARK: Производит проверку доски на уникальность элементов.
    private func checkBoard() throws {
        let elements = Set<Int>(0...(self.size * self.size - 1))
        var elementsBoard = Set<Int>()
        for row in matrix {
            for elem in row {
                elementsBoard.insert(Int(elem))
            }
        }
        if elements != elementsBoard {
            throw Exception(massage: "Incorrect numbers on the board.")
        }
    }
    
    // MARK: Печатает доску.
    func print() {
        Swift.print("State: ", self.g)
        Swift.print("Weight:", self.f)
        for row in matrix {
            var line = String()
            for col in row {
                line.append(String(format: "%02d ", col))
            }
            Swift.print(line)
        }
        Swift.print()
    }
    
    // MARK: Возврат словаря с координатами ячеек. Используется с для матрицы содержащей ответ.
    private func getCoordinats() {
        for (i, row) in self.matrix.enumerated() {
            for (j, element) in row.enumerated() {
                self.coordinats[element] = (Int8(i), Int8(j))
            }
        }
    }
    
    // MARK: Меняет местами номер и пустую клетку местами. form - от куда, to - в какие место.
    func swapNumber(numberFrom: Int16, numberTo: Int16) {
        let coordinatsFrom = getCoordinatsNumber(number: numberFrom)
        let coordinatsTo = getCoordinatsNumber(number: numberTo)
        self.matrix[Int(coordinatsFrom.0)][Int(coordinatsFrom.1)] = numberTo
        self.matrix[Int(coordinatsTo.0)][Int(coordinatsTo.1)] = numberFrom
        self.coordinats[numberFrom] = coordinatsTo
        self.coordinats[numberTo] = coordinatsFrom
    }
    
    static func == (left: Board, right: Board) -> Bool {
        return left.matrix == right.matrix
    }
    
    static func != (left: Board, right: Board) -> Bool {
        return !(left == right)
    }
}
