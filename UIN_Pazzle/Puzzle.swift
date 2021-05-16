//
//  Pazzle.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 21.04.2021.
//

import Foundation

class Puzzle {
    
    var heuristic: Heuristic?
    var boardTarget: Board?
    var board: Board?
    var close: Set<Int>
    //var open: Set<Int>
    var type: TypePuzzle
    
    init(type: TypePuzzle) {
        self.heuristic = .manhattan
        self.type = type
        self.close = Set<Int>()
        //self.open = Set<Int>()
    }
    
    convenience init(text: String, type: TypePuzzle) throws {
        self.init(type: type)
        try creationBouard(text: text)
        try checkSolution()
    }
    
    // MARK: Поиск решения, используя алгоритм A*. Стоит ограничение на 2*10^6 проссмотренных узлов.
    func searchSolutionWithHeap() -> (Board, Int, Int)? {
        let heap = Heap()
        var complexityTime = 0
        self.board!.setF(heuristic: self.heuristic!.getHeuristic(coordinats: self.board!.coordinats, coordinatsTarget: self.boardTarget!.coordinats))
        heap.push(board: self.board!)
        while !heap.isEmpty() {
            let board = heap.pop()
            //self.open.remove(board.matrix.hashValue)
//            if board == self.boardTarget! {
//                //print(board.path)
//                return (board, complexityTime, self.close.count)
//            }
            let neighbors = board.getNeighbors(number: 0)
            let children = getChildrens(neighbors: neighbors, board: board)
            for board in children {
                if board == self.boardTarget! {
                    //print(board.path)
                    return (board, complexityTime, self.close.count)
                }
                heap.push(board: board)
//                if !self.open.contains(board.matrix.hashValue) {
//                    self.open.insert(board.matrix.hashValue)
//                    heap.push(board: board)
//                    complexityTime += 1
//                //}
                //} else {
//                    for (i, elem) in heap.elements.enumerated() {
//                        if elem.matrix.hashValue == board.matrix.hashValue {
//                            if elem.f > board.f {
//                                heap.elements[i] = board
//                                heap.balancingUp(index: i)
//                                heap.balancingDown(parent: i)
//                                print("3")
//                            }
//                            break
//                        }
//                    }
//                }
                complexityTime += 1
            }
//            if let index = self.open.firstIndex(of: board.matrix.hashValue) {
//                self.open.remove(at: index)
//            }
            self.close.insert(board.matrix.hashValue)
        }
        print("The Pazzle has no solution.")
        return nil
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
                throw Exception(massage: "Has no solution.")
            }
        } else {
            print("Invariants: ", summa, summaTarget)
            if summa % 2 != summaTarget % 2 {
                throw Exception(massage: "Has no solution.")
            }
        }
    }
    
    // MARK: Проверяет есть ли решение головоломки.
    func isSolution() -> Bool {
        do {
            try checkSolution()
        } catch {
            return false
        }
        return true
    }
    
    // MARK: Возврящет сумму инверсий. Инверсия - пара чисел, в которее число стоит перед большим.
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
    
    // MARK: Выводит полный путь решения головоломки.
//    private func printPath(board: Board) {
//        var next: Board? = board
//        while next != nil {
//            next?.print()
//            next = next?.parent
//        }
//    }
    
    // MARK: Возвращает список смежных состояний.
    private func getChildrens(neighbors: [Int16], board: Board) -> [Board] {
        var childrens = [Board]()
        for number in neighbors {
            let newBoard = Board(board: board)
            newBoard.addDirection(numberFrom: number, numberTo: 0)
            newBoard.swapNumber(numberFrom: number, numberTo: 0)
            let heuristic = self.heuristic!.getHeuristic(coordinats: newBoard.coordinats, coordinatsTarget: self.boardTarget!.coordinats)
            newBoard.setF(heuristic: heuristic)
            if !self.close.contains(newBoard.matrix.hashValue) {
                childrens.append(newBoard)
            }
        }
        return childrens
    }
    
    // MARK: Проверяет находится ли номер на своем месте (относительно решения)
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
                throw Exception(massage: "Invalid data: \(line)")
            }
        }
        guard let sizeBoard = size else {
            throw Exception(massage: "Invalid data.")
        }
        if arr.count != sizeBoard || arr.count <= 0 || sizeBoard < 3 {
            throw Exception(massage: "The board size is set incorrectly.")
        }
        let board = try Board(size: sizeBoard, matrix: arr)
        let boardTarget = Board(size: board.size, type: self.type)
        self.board = board
        self.boardTarget = boardTarget
    }
    
    // MARK: Создает на основе строки чисел массив целочисленных элементов.
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
}
