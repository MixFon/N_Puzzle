//
//  Heap.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 25.04.2021.
//

import Foundation

class Heap {
    var elements: [Board]
    
    init() {
        self.elements = [Board]()
    }
    
    // MARK: Проверка на пустоту.
    func isEmpty() -> Bool {
        return self.elements.isEmpty
    }
    
    // MARK: Добавление нового элемента.
    func push(board: Board) {
        self.elements.append(board)
        let indexEnd = self.elements.index(before: self.elements.endIndex)
        balancingUp(index: indexEnd)
    }
    
    // MARK: Балансировка кучи вверх от дочернего узла к родителю.
    private func balancingUp(index: Int) {
        if index == 0 { return }
        let parent = getParent(index: index)
        if self.elements[parent].f > self.elements[index].f {
            self.elements.swapAt(parent, index)
        } else {
            return
        }
        balancingUp(index: parent)
    }
    
    // MARK: Балансировка кучи вниз от родительского к дочерним.
    private func balancingDown(parent: Int) {
        if let leftIndex = getIndexLeft(index: parent) {
            if self.elements[parent].f > self.elements[leftIndex].f {
                self.elements.swapAt(parent, leftIndex)
                balancingDown(parent: leftIndex)
            }
        }
        if let rightIndex = getIndexRight(index: parent) {
            if self.elements[parent].f > self.elements[rightIndex].f {
                self.elements.swapAt(parent, rightIndex)
                balancingDown(parent: rightIndex)
            }
        }
    }
    
    // MARK: Возвращает элемент в наивысшим приоритетом. Первый элемени пирамиды. (с минимальным значением f)
    func pop() -> Board {
        let board = self.elements.first!
        balancingHeap()
        return board
    }
    
    // MARK: Вывод кучи.
    func printHeap() {
        self.elements.forEach( { print($0.f, terminator: " ") } )
        print()
    }
    
    // MARK: Балансирока. Меняет местми верхний и последний. Удаляет последний. Меняет местами узлы.
    private func balancingHeap() {
        let endIndex = self.elements.index(before: self.elements.endIndex)
        let startIndex = self.elements.startIndex
        self.elements.swapAt(startIndex, endIndex)
        self.elements.remove(at: endIndex)
        balancingDown(parent: startIndex)
    }
    
    // MARK: Возвращает индекс родителя.
    private func getParent(index: Int) -> Int {
        return (index - 1) / 2
    }
    
    // MARK: Возвращает индекс левого потомка.
    private func getIndexLeft(index: Int) -> Int? {
        let result = index * 2 + 1
        if result >= self.elements.count { return nil }
        return index * 2 + 1
    }
 
    // MARK: Возвращает индекс правого потомка.
    private func getIndexRight(index: Int) -> Int? {
        let result = index * 2 + 2
        if result >= self.elements.count { return nil }
        return result
    }
}
