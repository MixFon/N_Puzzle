//
//  Pazzle.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 21.04.2021.
//

import Foundation

class Puzzle {
    
    var fileName: String?
    var heuristic: Heuristic?
    var boardTarget: Board?
    var board: Board?
    var close = [Int: Board]()
    
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
    
    // MARK: Поиск решения, используя алгоритм A*
    private func searchSolutionWithHeap() {
        let heap = Heap()
        var complexityTime = 0
        self.board!.setF(heuristic: self.heuristic!.getHeuristic(coordinats: self.board!.coordinats, coordinatsTarget: self.boardTarget!.coordinats))
        heap.push(board: self.board!)
        while !heap.isEmpty() {
            let board =  heap.pop()
            if board == self.boardTarget! {
                printPath(board: board)
                print("Complexity in time:", complexityTime)
                print("Complexity in size:", self.close.count)
                print("States to solution:", board.g)
                return
            }
            let neighbors = board.getNeighbors(number: 0)
            let children = getChildrens(neighbors: neighbors, board: board)
            for board in children {
                heap.push(board: board)
                complexityTime += 1
            }
            self.close[board.matrix.hashValue] = board
        }
        print("The Pazzle has no solution.")
    }
    
    // MARK: Проверяет существет ли решение головоломки.
    private func checkSolution() throws {
        let summa = getSummInversion(matrix: self.board!.matrix)
        let summaTarget = getSummInversion(matrix: self.boardTarget!.matrix)
        let coordinateZeroBoard = Int(self.board!.coordinats[0]!.0) + summa + 1
        let coordinateZeroBoardTarget = Int(self.boardTarget!.coordinats[0]!.0) + summaTarget + 1
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
    
    // MARK: Возвращает количество инвариантов.
    private func getSummInversion(matrix: [[Int16]]) -> Int {
        var summ = 0
        var arry = [Int16]()
        for row in matrix {
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
    
    private func printPath(board: Board) {
        var next: Board? = board
        while next != nil {
            next?.print()
            next = next?.parent
        }
    }
    
    // MARK: Возвращает список смежных состояний.
    private func getChildrens(neighbors: [Int16], board: Board) -> [Board] {
        var childrens = [Board]()
        for number in neighbors {
            let newBoard = Board(board: board)
            newBoard.swapNumber(number: number)
            let heuristic = self.heuristic!.getHeuristic(coordinats: newBoard.coordinats, coordinatsTarget: self.boardTarget!.coordinats)
            newBoard.setF(heuristic: heuristic)
            if (self.close[newBoard.matrix.hashValue] == nil) {
                childrens.append(newBoard)
            }
        }
        return childrens
    }
    
    // MARK: Проверяет не находится ли номер на своем месте.
    private func isLocal(number: Int16, board: Board) -> Bool {
        let coordinatsNumber = board.getCoordinatsNumber(number: number)
        let coordinatsTarget = self.boardTarget!.getCoordinatsNumber(number: number)
        return coordinatsNumber == coordinatsTarget
    }
    
    // MARK: Создает начальное состояние пазлов на основе считанных данных.
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
    
    // Создает на основе строки массив целочисленных элементов.
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
    
    // MARK: Возвращает строку без комментария.
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
    
    // MARK: Обработка аргументов.
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
    
    // MARK: Вывод сообщения об ошибке в поток ошибок
    private func systemError(massage: String) {
        fputs(massage + "\n", stderr)
        exit(-1)
    }
    
    // MARK: Чтение файла из стандарного потока ввода.
    private func readOutput() -> String {
        var text = String()
        while true {
            guard let line = readLine() else { break }
            text.append("\(line)\n")
        }
        return text
    }
    
    // MARK: Чтение файла из файла.
    private func readFile(fileName: String) throws -> String {
        let manager = FileManager.default
        let currentDirURL = URL(fileURLWithPath: manager.currentDirectoryPath)
        let fileURL = currentDirURL.appendingPathComponent(fileName)
        return try String(contentsOf: fileURL)
    }
}
