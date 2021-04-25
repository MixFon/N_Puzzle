//
//  LinkedList.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 25.04.2021.
//

import Foundation

struct LinkedList {
    var head: Node?
    
    // MARK: Добавляет новый эдемент в отсортированный по возрастанию список.
    mutating func push(board: Board) {
        let node = Node(board: board)
        if self.head == nil {
            self.head = node
            return 
        }
        if node.board.f < self.head!.board.f {
            node.next = self.head?.next
            self.head = node
            return
        }
        var prev = self.head
        var iter = self.head?.next
        while iter != nil {
            if iter!.board.f > node.board.f {
                node.next = iter
                prev?.next = node
                return
            }
            prev = iter
            iter = iter?.next
        }
        prev?.next = node
    }
    
    // MARK: Печатает список.
    func printList() {
        var iter = self.head
        while iter != nil {
            iter?.board.print()
            iter = iter?.next
        }
    }
    
    // MARK: Возвращает верхний элемент списка.
    mutating func pop() -> Board {
        let board = self.head!.board
        self.head = self.head?.next
        return board
    }
    
    func isEmpty() -> Bool {
        return self.head == nil
    }
}
