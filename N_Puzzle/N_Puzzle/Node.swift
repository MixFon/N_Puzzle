//
//  LinkedList.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 25.04.2021.
//

import Foundation

class Node {
    let board: Board
    var next: Node?
    
    init(board: Board) {
        self.board = board
    }
}
