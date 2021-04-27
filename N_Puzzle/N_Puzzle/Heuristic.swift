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
            return manhattanDistance(coordinats: coordinats, coordinatsTarget: coordinatsTarget)
        case .chebyshev:
            return chebyshevDistance(coordinats: coordinats, coordinatsTarget: coordinatsTarget)
        default:
            return euclideanDistance(coordinats: coordinats, coordinatsTarget: coordinatsTarget)
        }
    }
    
    // MARK: Эвристика манхетонского расстояния.
    private func manhattanDistance(coordinats: [Int8: (Int8, Int8)], coordinatsTarget: [Int8: (Int8, Int8)]) -> Int8 {
        var result: Int8 = 0
        for element in coordinats {
            let targetCoordinats = coordinatsTarget[element.key]!
            result += abs(element.value.0 - targetCoordinats.0) + abs(element.value.1 - targetCoordinats.1)
        }
        return result
    }
    
    // MARK: Эвристика растояния Чебышева.
    private func chebyshevDistance(coordinats: [Int8: (Int8, Int8)], coordinatsTarget: [Int8: (Int8, Int8)]) -> Int8 {
        var result: Int8 = 0
        for element in coordinats {
            let targetCoordinats = coordinatsTarget[element.key]!
            result +=  max(abs(element.value.0 - targetCoordinats.0), abs(element.value.1 - targetCoordinats.1))
        }
        return result
    }
    
    // MARK: Эвристика Эвклидова расстояния.
    private func euclideanDistance(coordinats: [Int8: (Int8, Int8)], coordinatsTarget: [Int8: (Int8, Int8)]) -> Int8 {
        var result = 0.0
        for element in coordinats {
            let targetCoordinats = coordinatsTarget[element.key]!
            let left = pow(Double(element.value.0 - targetCoordinats.0), 2.0)
            let right = pow(Double(element.value.1 - targetCoordinats.1), 2.0)
            result += sqrt(left + right)
        }
        return Int8(result)
    }
}
