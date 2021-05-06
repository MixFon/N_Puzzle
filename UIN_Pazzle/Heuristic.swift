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
    case simple = "-s"
    
    // MARK: Возвращает эвристику согласно установленному флагу.
    func getHeuristic(coordinats: [Int16: (Int8, Int8)], coordinatsTarget: [Int16: (Int8, Int8)]) -> Int {
        switch self {
        case .manhattan:
            return getDistance(coordinats: coordinats, coordinatsTarget: coordinatsTarget, distance: manhattanDistance)
        case .chebyshev:
            return getDistance(coordinats: coordinats, coordinatsTarget: coordinatsTarget, distance: chebyshevDistance)
        case .euclidean:
            return getDistance(coordinats: coordinats, coordinatsTarget: coordinatsTarget, distance: euclideanDistance)
        default:
            return getDistance(coordinats: coordinats, coordinatsTarget: coordinatsTarget, distance: simpleDintance)
        }
    }
    
    // MARK: Вычисляет эвристику на основе переданной функции-формулы.
    private func getDistance(coordinats: [Int16: (Int8, Int8)], coordinatsTarget: [Int16: (Int8, Int8)],
                             distance: ((Int8, Int8), (Int8, Int8))-> Int) -> Int {
        var result = 0
        for element in coordinats {
            let targetCoordinats = coordinatsTarget[element.key]!
            result += distance(element.value, targetCoordinats)
        }
        return result
    }
    
    // MARK: Эвристика манхетонского расстояния.
    private func manhattanDistance(coordinats: (Int8, Int8), coordinatsTarget: (Int8, Int8)) -> Int {
        return Int(abs(coordinats.0 - coordinatsTarget.0) + abs(coordinats.1 - coordinatsTarget.1))
    }
    
    // MARK: Эвристика расстояния Чебышева.
    private func chebyshevDistance(coordinats: (Int8, Int8), coordinatsTarget: (Int8, Int8)) -> Int {
        return Int(max(abs(coordinats.0 - coordinatsTarget.0), abs(coordinats.1 - coordinatsTarget.1)))
    }
    
    // MARK: Эвристика Эвклидова расстояния.
    private func euclideanDistance(coordinats: (Int8, Int8), coordinatsTarget: (Int8, Int8)) -> Int {
        let left = pow(Double(coordinats.0 - coordinatsTarget.0), 2.0)
        let right = pow(Double(coordinats.1 - coordinatsTarget.1), 2.0)
        return Int(sqrt(left + right))
    }
    
    // MARK: Эвристика высчитывающая количество элементов не на своих местах.
    private func simpleDintance(coordinats: (Int8, Int8), coordinatsTarget: (Int8, Int8)) -> Int {
        return coordinats == coordinatsTarget ? 0 : 1
    }
}
