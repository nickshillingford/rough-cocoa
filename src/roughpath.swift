import Foundation
import UIKit

class RoughPath {
    let path: String!
    let parsed: ParsedPath!
    var bezierReflectionPoint: [CGFloat]!
    var quadReflectionPoint: [CGFloat]!
    var linearPoints: [[CGFloat]]!
    var position: [Double]!
    var first: [Double]!
    var hasLP: Bool!
    
    init(path: String) {
        self.path = path
        self.parsed = ParsedPath(path: path)
        self.linearPoints = [[0, 0]]
        self.position = [0.0, 0.0]
        self.first = [-1.0, -1.0]
        self.hasLP = false
        self.bezierReflectionPoint = []
        self.quadReflectionPoint = []
    }
    
    func getSegments() -> [SegmentData] {
        return self.parsed.segments
    }
    
    func getLinearPoints() -> [[CGFloat]] {
        if self.hasLP == false {
            let len = self.parsed.segments.count - 1
            var i = 0
            while i < len {
                let point = self.parsed.segments[i].point!
                if i == 0 {
                    self.linearPoints[i] = point
                }
                else {
                    self.linearPoints.append(point)
                }
                i = i + 1
            }
            self.hasLP = true
        }
        return self.linearPoints
    }
    
    func getFirst() -> [Double] {
        return self.first
    }
    
    func setFirst(v: [Double]) {
        self.first = v
    }
    
    func setPosition(x: Double, y: Double) {
        self.position = [x, y]
        if self.first == [-1.0, -1.0] {
            self.first = [x, y]
        }
    }
    
    func getPosition() -> [Double] {
        return self.position
    }
    
    func getX() -> Double {
        return self.position[0]
    }
    
    func getY() -> Double {
        return self.position[1]
    }
}
