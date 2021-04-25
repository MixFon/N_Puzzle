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
        var child = self.elements.endIndex
        var parent = getParent(index: child)
        while self.elements[parent].f < self.elements[child].f {
            self.elements.swapAt(parent, child)
            child = parent
            parent = getParent(index: child)
        }
    }
    
    // MARK: Возвращает элемент в наивысшим приоритетом. Приоритетом является f
    func pop() -> Board {
        let board = self.elements.first!
        self.elements.swapAt(self.elements.startIndex, self.elements.endIndex)
        self.elements.remove(at: self.elements.endIndex)
        var parent = self.elements.startIndex
        var child = 
        
        return board
    }
    
    // MARK: Возвращает индекс родителя.
    private func getParent(index: Int) -> Int {
        return (index - 1) / 2
    }
    
    // MARK: Возвращает индекс левого потомка.
    private func getLeft(index: Int) -> Int {
        return index * 2 + 1
    }
 
    // MARK: Возвращает индекс правого потомка.
    private func getRight(index: Int) -> Int {
        return index * 2 + 2
    }
    
    
}
