//
//  Board.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 21.04.2021.
//

import Foundation

struct BoardPoint: Equatable {
	let x: Int8
	let y: Int8
}

final class Board: Equatable {
	var size: Int
	var matrix: [[Int16]]
	var coordinats = [Int16: BoardPoint]()
	var f: Int
	var g: Int
	var parent: Board?
    
    /// Создание доски на основе матрицы и размера
    init(size: Int, matrix: [[Int16]]) throws {
        self.size = size
        self.matrix = matrix
        self.f = 0
        self.g = 0
        try checkMatrix()
        setCoordinats()
    }
    
    /// Создание доски-решения.
    init(size: Int) {
        self.size = size
        self.matrix = Array(repeating: Array(repeating: 0, count: size), count: size)
        self.f = 0
        self.g = 0
        fillBoardInSpiral()
        setCoordinats()
    }
    
    /// Конструктор копирования.
    init(board: Board) {
        self.size = board.size
        self.matrix = board.matrix
        self.f = board.f
        self.g = board.g + 1
        self.parent = board
        self.coordinats = board.coordinats
    }
    
    /// Устанавливает значение f
    func setF(heuristic: Int) {
        if self.size == 3 {
            self.f = self.g + heuristic
        } else {
            self.f = heuristic
        }
    }
    
    /// Возвращает координаты ячейки с номером.
    func getCoordinatsNumber(number: Int16) -> BoardPoint? {
        return self.coordinats[number]
    }
    
    /// Возвращает номера соседних ячеек с нулевой.
    private func getNeighbors() -> [Int16] {
        var result = [Int16]()
        guard let coordinats = self.coordinats[0] else { return [] }
        if coordinats.y - 1 >= 0 {
            result.append(matrix[Int(coordinats.x)][Int(coordinats.y) - 1])
        }
        if coordinats.x - 1 >= 0 {
            result.append(matrix[Int(coordinats.x) - 1][Int(coordinats.y)])
        }
        if coordinats.y + 1 < self.size {
            result.append(matrix[Int(coordinats.x)][Int(coordinats.y) + 1])
        }
        if coordinats.x + 1 < self.size {
            result.append(matrix[Int(coordinats.x) + 1][Int(coordinats.y)])
        }
        return result
    }
	
	/// Возвращает список смежных состояний. Состояний, в которые можно перейти
	func getChildrens() -> [Board] {
		let neighbors = getNeighbors()
		var childrens = [Board]()
		for number in neighbors {
			let newBoard = Board(board: self)
			newBoard.swapNumber(number: number)
			childrens.append(newBoard)
		}
		return childrens
	}
    
    /// Заполняет доску по спирали.
    private func fillBoardInSpiral() {
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
    
    /// Заполняет внутренюю часть квадрата.
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
	
	/// Возвращает количество инвариантов.
	func getSummInversion() -> Int {
		var summ = 0
		var arry = [Int16]()
		for row in self.matrix {
			for elem in row {
				if elem != 0 {
					arry.append(elem)
				}
			}
		}
		for (i, elem) in arry.enumerated() {
			for elemIter in arry[(i+1)...] {
				if elem > elemIter {
					summ += 1
				}
			}
		}
		return summ
	}
    
    /// Производит проверку доски. Элементы должны быть уникальны.
    private func checkMatrix() throws {
        let elements = Set<Int>(0..<(self.size * self.size))
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
    
    /// Печатает доску.
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
    
    /// Возврат словаря с координатами ячеек. Используется с для матрицы содержащей ответ.
    private func setCoordinats() {
        for (i, row) in self.matrix.enumerated() {
            for (j, element) in row.enumerated() {
                self.coordinats[element] = BoardPoint(x: Int8(i), y: Int8(j))
            }
        }
    }
    
    /// Меняет местами номер и пустую клетку местами.
    func swapNumber(number: Int16) {
		guard let coordinatsNumber = getCoordinatsNumber(number: number) else { return }
		guard let coordinatsZero = getCoordinatsNumber(number: 0) else { return }
        self.matrix[Int(coordinatsNumber.x)][Int(coordinatsNumber.y)] = 0
        self.matrix[Int(coordinatsZero.x)][Int(coordinatsZero.y)] = number
        self.coordinats[number] = coordinatsZero
        self.coordinats[0] = coordinatsNumber
    }
    
    static func == (left: Board, right: Board) -> Bool {
        return left.matrix == right.matrix
    }
    
    static func != (left: Board, right: Board) -> Bool {
        return !(left == right)
    }
}
