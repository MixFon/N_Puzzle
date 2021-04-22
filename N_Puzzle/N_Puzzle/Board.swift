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
    var zero: (Int, Int)
    
    // MARK: Создание доски на основе матрицы и размера
    init(size: Int, matrix: [[Int]]) throws {
        self.size = size
        self.matrix = matrix
        self.zero = (0, 0)
        try checkBoard()
    }
    
    // MARK: Создание доски-решения.
    init(size: Int) {
        self.size = size
        self.matrix = Array(repeating: Array(repeating: 0, count: size), count: size)
        self.zero = (0, 0)
        fillBoard()
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
        self.zero = (x, y)
    }
    
    // MARK: Производит проверку доски. Элементы должны быть уникальны.
    private mutating func checkBoard() throws {
        let elements = Set<Int>(0...(self.size * self.size - 1))
        var elementsBoard = Set<Int>()
        Swift.print(elements)
        for (i, row) in matrix.enumerated() {
            for (j, elem) in row.enumerated() {
                elementsBoard.insert(elem)
                if elem == 0 {
                    self.zero = (i, j)
                }
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
    }
    
    // MARK: Возврат словаря с координатами ячеек. Используется с для матрицы содержащей ответ.
    func getCoordinats() -> [Int: (Int, Int)] {
        var coordinats = [Int: (Int, Int)]()
        for (i, row) in self.matrix.enumerated() {
            for (j, element) in row.enumerated() {
                coordinats[element] = (i, j)
            }
        }
        return coordinats
    }
}
