//
//  Pazzle.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 21.04.2021.
//

import Foundation

class Pazzle {
    
    var fileName: String?
    var heuristic: Heuristic?
    
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
        } catch let exception as Exception {
            systemError(massage: exception.massage)
        } catch {
            systemError(massage: "Unknown error.")
        }
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
        board.print()
        print(board.zero)
        for i in 1...10 {
            let board = Board(size: i)
            board.print()
            print(board.zero)
        }
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
