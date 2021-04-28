//
//  Heuristic.swift
//  N_Puzzle
//
//  Created by Михаил Фокин on 21.04.2021.
//

import Foundation

enum Heuristic: String {
    case manhattan = "-m"
    case chebyshev = "-ch"
    case euclidean = "-eu"
    
    // MARK: Возвращает эвристику согласно установленному флагу.
    func getHeuristic(coordinats: [Int8: (Int8, Int8)], coordinatsTarget: [Int8: (Int8, Int8)]) -> Int8 {
        switch self {
        case .manhattan:
            return getDistance(coordinats: coordinats, coordinatsTarget: coordinatsTarget, distance: manhattanDistance)
        case .chebyshev:
            return getDistance(coordinats: coordinats, coordinatsTarget: coordinatsTarget, distance: chebyshevDistance)
        default:
            return getDistance(coordinats: coordinats, coordinatsTarget: coordinatsTarget, distance: euclideanDistance)
        }
    }
    
    private func getDistance(coordinats: [Int8: (Int8, Int8)], coordinatsTarget: [Int8: (Int8, Int8)],
                             distance: ((Int8, Int8), (Int8, Int8))-> Int8) -> Int8 {
        var result: Int8 = 0
        for element in coordinats {
            let targetCoordinats = coordinatsTarget[element.key]!
            result += distance(element.value, targetCoordinats)
        }
        return result
    }
    
    // MARK: Эвристика манхетонского расстояния.
    private func manhattanDistance(coordinats: (Int8, Int8), coordinatsTarget: (Int8, Int8)) -> Int8 {
        return abs(coordinats.0 - coordinatsTarget.0) + abs(coordinats.1 - coordinatsTarget.1)
    }
    
    // MARK: Эвристика растояния Чебышева.
    private func chebyshevDistance(coordinats: (Int8, Int8), coordinatsTarget: (Int8, Int8)) -> Int8 {
        return max(abs(coordinats.0 - coordinatsTarget.0), abs(coordinats.1 - coordinatsTarget.1))
    }
    
    // MARK: Эвристика Эвклидова расстояния.
    private func euclideanDistance(coordinats: (Int8, Int8), coordinatsTarget: (Int8, Int8)) -> Int8 {
        let left = pow(Double(coordinats.0 - coordinatsTarget.0), 2.0)
        let right = pow(Double(coordinats.1 - coordinatsTarget.1), 2.0)
        return Int8(sqrt(left + right))
    }
}
