import Foundation
import UIKit

let rr = Renderer()

class Hachure {
    let bottom: Double
    let right: Double
    let left: Double
    let top: Double
    
    let sin: Double
    let cos: Double
    let tan: Double
    let gap: Double
    
    var hGap: Double!
    var pos: Double!
    var deltaX: Double!
    
    var sLeft: Segment!
    var sRight: Segment!
    
    init(_top: Double, _bottom: Double, _left: Double, _right: Double, _gap: Double, _sin: Double, _cos: Double, _tan: Double) {
        self.bottom = _bottom
        self.right = _right
        self.left = _left
        self.top = _top
        self.gap = _gap
        self.sin = _sin
        self.cos = _cos
        self.tan = _tan
        
        if Double(abs(_sin)) < 0.0001 {
            self.pos = _left + _gap
        }
        else if abs(_sin) > 0.9999 {
            self.pos = _top + _gap
        }
        else {
            self.deltaX = (_bottom - _top) * abs(_tan)
            self.pos = _left - abs(self.deltaX)
            self.hGap = abs(_gap / _cos)
            self.sLeft = Segment(_px1: _left, _py1: _bottom, _px2: _left, _py2: _top)
            self.sRight = Segment(_px1: right, _py1: bottom, _px2: right, _py2: top)
        }
    }
    
    func getNextLine() -> [Double] {
        if abs(self.sin) < 0.0001 {
            if self.pos < Double(self.right) {
                let line: [Double] = [self.pos, self.top, self.pos, self.bottom]
                self.pos = self.pos + self.gap
                return line
            }
        }
        else if Double(abs(self.sin)) > 0.9999 {
            if self.pos < self.bottom {
                let line: [Double] = [Double(self.left), self.pos, self.right, self.pos]
                self.pos = self.pos + Double(self.gap)
                return line
            }
        }
        else {
            var xLower = (self.pos - (self.deltaX / 2))
            var xUpper = (self.pos + (self.deltaX / 2))
            var yLower = self.bottom
            var yUpper = self.top
            
            if self.pos < (self.right + self.deltaX) {
                while (((xLower < self.left) && (xUpper < self.left)) || ((xLower > self.right) && (xUpper > self.right))) {
                    self.pos = self.pos + self.hGap
                    xLower = (self.pos - (self.deltaX / 2))
                    xUpper = (self.pos + (self.deltaX / 2))
                    if self.pos > (self.right + self.deltaX) {
                        return []
                    }
                }
                let seg = Segment(_px1: xLower, _py1: yLower, _px2: xUpper, _py2: yUpper)
                if seg.compare(segment: self.sLeft) == 2 {
                    xLower = Double(seg.xi)
                    yLower = seg.yi
                }
                if seg.compare(segment: self.sRight) == 2 {
                    xUpper = Double(seg.xi)
                    yUpper = seg.yi
                }
                if self.tan > 0 {
                    xLower = self.right - (xLower - self.left)
                    xUpper = self.right - (xUpper - self.left)
                }
                let line: [Double] = [xLower, yLower, xUpper, yUpper]
                self.pos = self.pos + self.hGap
                return line
            }
        }
        return []
    }
}

func hachureFill(xCoord: [Double], yCoord: [Double], opt: [String:Any]) -> Drawing {
    var data: [Any] = []
    var left = xCoord[0]
    var right = xCoord[0]
    var top = yCoord[0]
    var bottom = yCoord[0]
    
    for i in 1...(xCoord.count - 1) {
        left = min(left, xCoord[i])
        right = max(right, xCoord[i])
        top = min(top, yCoord[i])
        bottom = max(bottom, yCoord[i])
    }
    
    let strokeWidth = CGFloat(opt["strokeWidth"] as! Double)
    let angle = CGFloat(opt["hachureAngle"] as! Double)
    var gap = CGFloat(opt["hachureGap"] as! Double)
    
    if gap <= 0.0 {
        gap = (strokeWidth * 4.0)
    }
    gap = CGFloat(max(Double(gap), 0.1))
    
    let radPerDeg = CGFloat((Double.pi / 180))
    let hachureAngle = angle.truncatingRemainder(dividingBy: 180.0) * radPerDeg
    let cosAngle = cos(hachureAngle)
    let sinAngle = sin(hachureAngle)
    let tanAngle = tan(hachureAngle)
    
    let rh = Hachure(_top: (top-1), _bottom: (bottom+1), _left: (left-1), _right: (right+1),
                     _gap: Double(gap), _sin: Double(sinAngle), _cos: Double(cosAngle), _tan: Double(tanAngle))
    
    var rectCoords: [Double]
    var empty = false
    while !empty {
        rectCoords = rh.getNextLine()
        if rectCoords.count == 0 {
            empty = true
        }
        else {
            let lines = getIntersectingLines(lC: rectCoords, xC: xCoord, yC: yCoord)
            var i = 0
            while i < lines.count {
                if i < lines.count - 1 {
                    let p1 = lines[i]
                    let p2 = lines[i + 1]
                    let node: [Any] = rr.doubleLine(x1: Int(p1[0]), y1: Int(p1[1]), x2: Int(p2[0]), y2: Int(p2[1]), opt: opt)
                    data = data + node
                }
                i = i + 1
            }
        }
    }
    return Drawing(type: "fillSketch", data: data)
}

func hachureFillEllipse(cx: Int, cy: Int, width: Int, height: Int, opt: [String:Any]) -> Drawing {
    var data: [Any] = []
    let rough = opt["roughness"] as! Double
    let radPerDeg = (CGFloat.pi / 180.0)
    
    let strokeWidth = CGFloat(opt["strokeWidth"] as! Double)
    var fillWeight = CGFloat(opt["fillWeight"] as! Double)
    var gap = CGFloat(opt["hachureGap"] as! Double)
    let angle = CGFloat(opt["hachureAngle"] as! Double)
    
    let hachureAngle = angle.truncatingRemainder(dividingBy: 180.0) * radPerDeg
    let tanAngle = tan(hachureAngle)
    var rx = CGFloat(abs(width / 2))
    var ry = CGFloat(abs(height / 2))
    let aspectRatio = (ry / rx)
    let hyp = sqrt(aspectRatio * tanAngle * aspectRatio * tanAngle + 1)
    let sinPrime = (aspectRatio * tanAngle / hyp)
    let cosPrime = (1 / hyp)
    
    rx += rr.getOffset(min: (-rx * 0.05), max: (rx * 0.05), roughness: rough)
    ry += rr.getOffset(min: (-ry * 0.05), max: (ry * 0.05), roughness: rough)
    
    if gap <= 0.0 {
        gap = (strokeWidth * 4.0)
    }
    if fillWeight < 0.0 {
        fillWeight = (strokeWidth / 2.0)
    }
    
    let gapPrime = gap / ((rx * ry / sqrt((ry * cosPrime) * (ry * cosPrime) + (rx * sinPrime) * (rx * sinPrime))) / rx)
    let e1 = (rx * rx)
    let e2 = (CGFloat(cx) - rx + gapPrime)
    var halfLen = sqrt(e1 - e2 * e2)
    var xPos = CGFloat(cx) - rx + gapPrime
    while xPos < CGFloat(cx) + rx {
        let s = (rx * rx) - (CGFloat(cx) - xPos) * (CGFloat(cx) - xPos)
        halfLen = sqrt(s)
        let p1 = rr.affine(x: xPos, y: (CGFloat(cy) - halfLen), cx: CGFloat(cx), cy: CGFloat(cy), sin: sinPrime, cos: cosPrime, asp: aspectRatio)
        let p2 = rr.affine(x: xPos, y: (CGFloat(cy) + halfLen), cx: CGFloat(cx), cy: CGFloat(cy), sin: sinPrime, cos: cosPrime, asp: aspectRatio)
        data = data + rr.doubleLine(x1: Int(p1[0]), y1: Int(p1[1]), x2: Int(p2[0]), y2: Int(p2[1]), opt: opt)
        xPos += gapPrime
    }
    return Drawing(type: "fillSketch", data: data)
}

func getIntersectingLines(lC: [Double], xC: [Double], yC: [Double]) -> [[Double]] {
    var intersections: [[Double]] = []
    let s1 = Segment(_px1: lC[0], _py1: lC[1], _px2: lC[2], _py2: lC[3])
    for i in 0...(xC.count - 1) {
        let s2 = Segment(_px1: xC[i], _py1: yC[i], _px2: xC[(i + 1) % xC.count], _py2: yC[(i + 1) % xC.count])
        if s1.compare(segment: s2) == 2 {
            intersections.append([Double(s1.xi), Double(s1.yi)])
        }
    }
    return intersections
}
