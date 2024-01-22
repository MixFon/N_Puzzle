//
//  Pazzle.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 21.04.2021.
//

import Foundation

final class Puzzle {
    
    private var fileName: String?
    private var heuristic: Heuristic?
    private var boardTarget: Board?
    private var board: Board?
    private var close = Set<Int>()
    
    func run() {
        do {
            let text: String
            try workingArguments()
            if let fileName = self.fileName {
                text = try readFile(fileName: fileName)
            } else {
                text = readOutput()
            }
            try creationBouard(text: text)
            try checkSolution()
            searchSolutionWithHeap()
        } catch let exception as Exception {
            systemError(massage: exception.massage)
        } catch {
            systemError(massage: "Unknown error.")
        }
    }
    
    /// Поиск решения, используя алгоритм A*
    private func searchSolutionWithHeap() {
        let heap = Heap()
        var complexityTime = 0
        self.board!.setF(heuristic: self.heuristic!.getHeuristic(coordinats: self.board!.coordinats, coordinatsTarget: self.boardTarget!.coordinats))
        heap.push(board: self.board!)
        while !heap.isEmpty() {
            let board = heap.pop()
            if board == self.boardTarget! {
                printPath(board: board)
                print("Complexity in time:", complexityTime)
                print("Complexity in size:", self.close.count)
                print("States to solution:", board.g)
                return
            }
			let children = board.getChildrens()
            for board in children {
				if !self.close.contains(board.matrix.hashValue) {
					let heuristic = self.heuristic!.getHeuristic(coordinats: board.coordinats, coordinatsTarget: self.boardTarget!.coordinats)
					board.setF(heuristic: heuristic)
					heap.push(board: board)
					complexityTime += 1
				}
            }
            self.close.insert(board.matrix.hashValue)
        }
        print("The Pazzle has no solution.")
    }
    
    /// Проверяет существет ли решение головоломки.
    private func checkSolution() throws {
		let summa = self.board!.getSummInversion()
		let summaTarget = self.boardTarget!.getSummInversion()
        let coordinateZeroBoard = Int(self.board!.coordinats[0]!.x) + summa + 1
        let coordinateZeroBoardTarget = Int(self.boardTarget!.coordinats[0]!.x) + summaTarget + 1
        if board!.size % 2 == 0 {
            print("Invariants: ", coordinateZeroBoard, coordinateZeroBoardTarget)
            if coordinateZeroBoard % 2 != coordinateZeroBoardTarget % 2 {
                throw Exception(massage: "The Pazzle has no solution.")
            }
        } else {
            print("Invariants: ", summa, summaTarget)
            if summa % 2 != summaTarget % 2 {
                throw Exception(massage: "The Pazzle has no solution.")
            }
        }
    }
    
    private func printPath(board: Board) {
        var next: Board? = board
        while next != nil {
            next?.print()
            next = next?.parent
        }
    }
    
    /// Создает начальное состояние пазлов на основе считанных данных.
    private func creationBouard(text: String) throws {
        let lines = text.split() { $0 == "\n" }.map{ String($0) }
        var size: Int?
        var arr = [[Int16]]()
        for line in lines {
            let data = getData(line: line)
            let words = try getWords(data: data)
            switch words.count {
            case 0:
                break
            case 1 where size == nil:
                size = Int(words[0])
            case 2... where words.count == size:
                arr.append(words)
            default:
                throw Exception(massage: "Invalid data: \(line) in \(lines)")
            }
        }
        guard let sizeBoard = size else {
            throw Exception(massage: "Invalid data.")
        }
        if arr.count != sizeBoard || arr.count <= 2 {
            throw Exception(massage: "The board size is set incorrectly.")
        }
        let board = try Board(size: sizeBoard, matrix: arr)
        let boardTarget = Board(size: board.size)
        self.board = board
        self.boardTarget = boardTarget
    }
    
    /// Создает на основе строки массив целочисленных элементов.
    private func getWords(data: String) throws -> [Int16] {
        let words = data.split() { $0 == " "}.map { String($0) }
        if words.isEmpty {
            return [Int16]()
        }
        var numbers = [Int16]()
        for word in words {
            guard let number = Int16(word) else {
                throw Exception(massage: "Invalid data: \(word)")
            }
            numbers.append(number)
        }
        return numbers
    }
    
    /// Возвращает строку без комментария.
    private func getData(line: String) -> String {
        var data = String()
        for char in line {
            if char == "#" {
                return data
            } else {
                data.append(char)
            }
        }
        return data
    }
    
    /// Обработка аргументов.
    private func workingArguments() throws {
        for argument in CommandLine.arguments[1...] {
            guard let firstCaracter = argument.first else { continue }
            if firstCaracter == "-" {
                switch argument {
                case "-m":
                    self.heuristic = .manhattan
                case "-ch":
                    self.heuristic = .chebyshev
                case "-eu":
                    self.heuristic = .euclidean
                case "-s":
                    self.heuristic = .simple
                default:
                    throw Exception(massage: "Invalid agument: \(argument)")
                }
            } else {
                if self.fileName == nil {
                    self.fileName = argument
                } else {
                    throw Exception(massage: "Invalid agument: \(argument)")
                }
            }
        }
        if self.heuristic == nil {
            self.heuristic = .manhattan
        }
    }
    
    /// Вывод сообщения об ошибке в поток ошибок
    private func systemError(massage: String) {
        fputs(massage + "\n", stderr)
        exit(-1)
    }
    
    /// Чтение файла из стандарного потока ввода.
    private func readOutput() -> String {
        var text = String()
        while let line = readLine() {
            text.append("\(line)\n")
        }
        return text
    }
    
    /// Чтение файла из файла.
    private func readFile(fileName: String) throws -> String {
        let manager = FileManager.default
        let currentDirURL = URL(fileURLWithPath: manager.currentDirectoryPath)
        let fileURL = currentDirURL.appendingPathComponent(fileName)
        return try String(contentsOf: fileURL)
    }
}
