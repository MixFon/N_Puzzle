//
//  Pazzle.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 21.04.2021.
//

import Foundation
import CoreFoundation

class Pazzle {
    
    var fileName: String?
    var heuristic: Heuristic?
    var boardTarget: Board?
    var board: Board?
    var open = [Board]()
    var close = [Board]()
    
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
            searchSolution()
        } catch let exception as Exception {
            systemError(massage: exception.massage)
        } catch {
            systemError(massage: "Unknown error.")
        }
    }
    
    // MARK: Поиск решения используя алгоритм A*
    private func searchSolution() {
//        var queue = [Board]()
        var lavel = 0
        self.board!.setF(heuristic: getHeuristic(board: self.board!))
        //var list = LinkedList()
        //list.push(board: self.board!)
        self.open.append(self.board!)
        self.board?.print()
        while !self.open.isEmpty {
        //for _ in 0...2 {
        //while !list.isEmpty() {
            let index = getPriorityBoard(boards:  self.open)
            let board =  self.open[index]
            //let board =  list.pop()
            self.open.remove(at: index)
            if board == self.boardTarget! {
                printPath(board: board)
                board.print()
                print(lavel)
                return
            }
            let neighbors = board.getNeighbors(number: 0)
            let children = getChildrens(neighbors: neighbors, board: board)
            self.open += children
//            for board in children {
//                list.push(board: board)
//            }
            self.close.append(board)
//            for child in children {
//                print(child.f)
//                child.print()
//            }
            //board.print()
            //print(neighbors)
            //let number = getSwapNumber(neighbors: neighbors)
            //swapNumber(number: number)
            //self.board?.print()
            lavel += 1
        }
    }
    
    private func printPath(board: Board) {
        var next: Board? = board
        while next != nil {
            next?.print()
            next = next?.parent
        }
//        while !self.close.isEmpty {
//            let index = getPriorityBoard(boards:  self.close)
//            let board =  self.close[index]
//            self.close.remove(at: index)
//            board.print()
//        }
    }
    
    // MARK: Возвращает список смежных состояний.
    private func getChildrens(neighbors: [Int], board: Board) -> [Board] {
        var childrens = [Board]()
        for number in neighbors {
            var newBoard = Board(board: board)
            newBoard.swapNumber(number: number)
            newBoard.setF(heuristic: getHeuristic(board: newBoard))
            if !self.close.contains(newBoard) {
                childrens.append(newBoard)
            }
        }
        return childrens
    }
    
    // MARK: Возвращает достку с максимальным приоритетом.
    private func getPriorityBoard(boards: [Board]) -> Int {
        var index = 0
        var min = Int.max
        for (i, board) in boards.enumerated() {
            if min > board.f {
                min = board.f
                index = i
            }
        }
        return index
    }
    
    // MARK: Возвращает количество пройдейного пути.
//    private func getCost(cost: Int) -> Int {
//        return cost
//    }
    
//    private func getCost(board: Board) -> Int {
//        let numberCoordinats = board.getCoordinatsNumber(number: 0)
//        let targetCoordinats = self.boardTarget!.getCoordinatsNumber(number: 0)
//        let result = abs(numberCoordinats.0 - targetCoordinats.0) + abs(numberCoordinats.1 - targetCoordinats.1)
//        return result
//    }
    
    // MARK: Возвращает эвристику согласно установленному флагу.
    private func getHeuristic(board: Board) -> Int {
        switch self.heuristic {
        case .manhattan:
            return manhattanDistance(board: board)
        default:
            break
        }
        return Int.max
    }
    
    // MARK: Эвристика манхетонского расстояния.
    private func manhattanDistance(board: Board) -> Int {
        var result = 0
        for row in board.matrix {
            for number in row {
                let numberCoordinats = board.getCoordinatsNumber(number: number)
                let targetCoordinats = self.boardTarget!.getCoordinatsNumber(number: number)
                result += abs(numberCoordinats.0 - targetCoordinats.0) + abs(numberCoordinats.1 - targetCoordinats.1)
            }
        }
        return result
    }
    
    // MARK: Проверяет не находится ли номер на своем месте.
    private func isLocal(number: Int) -> Bool {
        let coordinatsNumber = self.board!.getCoordinatsNumber(number: number)
        let coordinatsTarget = self.boardTarget!.getCoordinatsNumber(number: number)
        return coordinatsNumber == coordinatsTarget
    }
    
    // MARK: Создает начальное состояние пазлов на основе считанных данных.
    private func creationBouard(text: String) throws {
        let lines = text.split() { $0 == "\n" }.map{ String($0) }
        var size: Int?
        var arr = [[Int]]()
        for line in lines {
            let data = getData(line: line)
            let words = try getWords(data: data)
            switch words.count {
            case 0:
                break
            case 1 where size == nil:
                size = words[0]
            case 2... where words.count == size:
                arr.append(words)
            default:
                throw Exception(massage: "Invalid data: \(line)")
            }
        }
        guard let sizeBoard = size else { return }
        if arr.count != sizeBoard {
            throw Exception(massage: "The board size is set incorrectly.")
        }
        let board = try Board(size: sizeBoard, matrix: arr)
        let boardTarget = Board(size: board.size)
        self.board = board
        self.boardTarget = boardTarget
        //self.board?.print()
        //self.boardTarget?.print()
    }
    
    // Создает на основе строки массив целочисленных элементов.
    private func getWords(data: String) throws -> [Int] {
        let words = data.split() { $0 == " "}.map { String($0) }
        if words.isEmpty {
            return [Int]()
        }
        var numbers = [Int]()
        for word in words {
            guard let number = Int(word) else {
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

// MARK: Возвращает число, которое необходимо передвинуть. Номер с минимальной эвристикой.
//    private func getSwapNumber(neighbors: [Int]) -> Int {
//        var index = 0;
//        var min: Int?
//        for (i, number) in neighbors.enumerated() {
//            if number == previous || isLocal(number: number){
//                continue
//            }
//            let heuristic = getHeuristic(number: number)
//            if min == nil {
//                min = heuristic
//                index = i
//            } else {
//                if min! > heuristic && heuristic != 0 {
//                    min = heuristic
//                    index = i
//                }
//            }
//        }
//        return neighbors[index]
//    }
