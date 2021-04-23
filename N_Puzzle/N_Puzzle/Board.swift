//
//  Board.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 21.04.2021.
//

import Foundation

struct Board {
    var size: Int
    var matrix: [[Int]]
    var coordinats = [Int: (Int, Int)]()
    var f: Int
    
    // MARK: Создание доски на основе матрицы и размера
    init(size: Int, matrix: [[Int]]) throws {
        self.size = size
        self.matrix = matrix
        self.f = 0
        try checkBoard()
        getCoordinats()
    }
    
    // MARK: Конструктор копирования.
    init(board: Board) {
        self.size = board.size
        self.matrix = board.matrix
        self.f = board.f
        self.coordinats = board.coordinats
    }
    
    // MARK: Создание доски-решения.
    init(size: Int) {
        self.size = size
        self.matrix = Array(repeating: Array(repeating: 0, count: size), count: size)
        self.f = 0
        fillBoard()
        getCoordinats()
    }
    
    // MARK: Устанавливает значение f
    mutating func setF(cost: Int) {
        self.f = cost
    }
    
    // MARK: Возвращает координаты ячейки с номером.
    func getCoordinatsNumber(number: Int) -> (Int, Int) {
        guard let coordinats = self.coordinats[number] else { return (Int.max, Int.max) }
        return coordinats
    }
    
    // MARK: Возвращает номера соседних ячеек.
    func getNeighbors(number: Int) -> [Int] {
        var result = [Int]()
        guard let coordinats = self.coordinats[number] else {
            return []
        }
        if coordinats.1 - 1 >= 0 {
            result.append(matrix[coordinats.0][coordinats.1 - 1])
        }
        if coordinats.0 - 1 >= 0 {
            result.append(matrix[coordinats.0 - 1][coordinats.1])
        }
        if coordinats.1 + 1 < self.size {
            result.append(matrix[coordinats.0][coordinats.1 + 1])
        }
        if coordinats.0 + 1 < self.size {
            result.append(matrix[coordinats.0 + 1][coordinats.1])
        }
        return result
    }
    
    // MARK: Заполняет доску по спирали.
    private mutating func fillBoard() {
        var filler = 1
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
    
    // MARK: Заполняет внутренюю часть квадрата.
    private mutating func fillSquare(filler: Int) {
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
    
    // MARK: Производит проверку доски. Элементы должны быть уникальны.
    private mutating func checkBoard() throws {
        let elements = Set<Int>(0...(self.size * self.size - 1))
        var elementsBoard = Set<Int>()
        Swift.print(elements)
        for row in matrix {
            for elem in row {
                elementsBoard.insert(elem)
            }
        }
        Swift.print(elementsBoard)
        if elements != elementsBoard {
            throw Exception(massage: "Incorrect numbers on the board.")
        }
    }
    
    // MARK: Печатает доску.
    func print() {
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
    private mutating func getCoordinats() {
        //var coordinats = [Int: (Int, Int)]()
        for (i, row) in self.matrix.enumerated() {
            for (j, element) in row.enumerated() {
                //
                self.coordinats[element] = (i, j)
            }
        }
    }
    
    // MARK: Меняет местами номер и пустую клетку местами.
    mutating func swapNumber(number: Int) {
        let coordinatsNumber = getCoordinatsNumber(number: number)
        let coordinatsZero = getCoordinatsNumber(number: 0)
        self.matrix[coordinatsNumber.0][coordinatsNumber.1] = 0
        self.matrix[coordinatsZero.0][coordinatsZero.1] = number
        self.coordinats[number] = coordinatsZero
        self.coordinats[0] = coordinatsNumber
    }
    
    static func == (left: Board, right: Board) -> Bool {
        for (rowL, rowR) in zip(left.matrix, right.matrix) {
            for (elemL, elemR) in zip(rowL, rowR) {
                if elemL != elemR {
                    return false
                }
            }
        }
        return true
    }
    
    static func != (left: Board, right: Board) -> Bool {
        return !(left == right)
    }
}
