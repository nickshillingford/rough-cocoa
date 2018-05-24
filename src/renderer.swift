import Foundation
import UIKit

class Renderer {
    func line(x1: Int, y1: Int, x2: Int, y2: Int, opt: [String:Any]) -> Drawing {
        let data = self.doubleLine(x1: x1, y1: y1, x2: x2, y2: y2, opt: opt)
        return Drawing(type: "path", data: data)
    }
    
    func linearPath(points: [[Any]], close: Bool, opt: [String:Any]) -> Drawing {
        let len = points.count
        var result: Drawing!
        if len > 2 {
            var data: [Any] = []
            for i in 0...(len - 2) {
                data = data + self.doubleLine(x1: points[i][0] as! Int,
                                              y1: points[i][1] as! Int,
                                              x2: points[i + 1][0] as! Int,
                                              y2: points[i + 1][1] as! Int,
                                              opt: opt)
            }
            if close {
                data = data + self.doubleLine(x1: points[len - 1][0] as! Int,
                                              y1: points[len - 1][1] as! Int,
                                              x2: points[0][0] as! Int,
                                              y2: points[0][1] as! Int,
                                              opt: opt)
            }
            result = Drawing(type: "path", data: data)
        }
        else if len == 2 {
            return self.line(x1: points[0][0] as! Int, y1: points[0][1] as! Int, x2: points[1][0] as! Int, y2: points[1][1] as! Int, opt: opt)
        }
        return result
    }
    
    func polygon(points: [[Any]], opt: [String:Any]) -> Drawing {
        return self.linearPath(points: points, close: true, opt: opt)
    }
    
    func rectangle(x: Int, y: Int, width: Int, height: Int, opt: [String:Any]) -> Drawing {
        let points = [[x, y], [(x + width), y], [(x + width), (y + height)], [x, (y + height)]]
        return self.polygon(points: points, opt: opt)
    }
    
    func ellipse(x: Int, y: Int, width: Int, height: Int, opt: [String:Any]) -> Drawing {
        let curveStepCount = CGFloat(opt["curveStepCount"] as! Double)
        let increment = ((CGFloat.pi * 2.0) / curveStepCount)
        let rough = opt["roughness"] as! Double
        
        var rx = CGFloat(abs(width / 2))
        var ry = CGFloat(abs(height / 2))
        
        rx = rx + self.getOffset(min: (-rx * 0.05), max: (rx * 0.05), roughness: rough)
        ry = ry + self.getOffset(min: (-ry * 0.05), max: (ry * 0.05), roughness: rough)
        
        let offset1 = self.getOffset(min: 0.4, max: 1.0, roughness: rough)
        let offset2 = self.getOffset(min: 0.1, max: offset1, roughness: rough)
        
        let o1 = self._ellipse(inc: increment, cx: CGFloat(x), cy: CGFloat(y), rx: rx, ry: ry, os: 1.0, ol: (increment * offset2), opt: opt)
        let o2 = self._ellipse(inc: increment, cx: CGFloat(x), cy: CGFloat(y), rx: rx, ry: ry, os: 1.5, ol: 0.0, opt: opt)
        return Drawing(type: "path", data: (o1 + o2))
    }
    
    func getOffset(min: CGFloat, max: CGFloat, roughness: Double) -> CGFloat {
        let rand = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        return CGFloat(CGFloat(roughness) * ((rand * (max - min)) + min))
    }
    
    func doubleLine(x1: Int, y1: Int, x2: Int, y2: Int, opt: [String:Any]) -> [Any] {
        let l1 = self._line(x1: x1, y1: y1, x2: x2, y2: y2, opt: opt, move: true, overlay: false)
        let l2 = self._line(x1: x1, y1: y1, x2: x2, y2: y2, opt: opt, move: true, overlay: true)
        return l1 + l2
    }
    
    func solidFill(xCoord: [Double], yCoord: [Double], opt: [String:Any]) -> Drawing {
        let offset = opt["maxRandomnessOffset"] as! Double
        var data: [Any] = []
        let len = xCoord.count
        if len > 2 {
            var x = self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: offset)
            var y = self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: offset)
            data.append(["move" : [(CGFloat(xCoord[0]) + x), (CGFloat(yCoord[0]) + y)]])
            for i in 1...(len - 1) {
                x = self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: offset)
                y = self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: offset)
                data.append(["lineTo" : [(CGFloat(xCoord[i]) + x), (CGFloat(yCoord[i]) + y)]])
            }
        }
        return Drawing(type: "fillPath", data: data)
    }
 
    func affine(x: CGFloat, y: CGFloat, cx: CGFloat, cy: CGFloat, sin: CGFloat, cos: CGFloat, asp: CGFloat) -> [CGFloat] {
        let a = (-cx * cos - cy * sin + cx)
        let b = (asp * (cx * sin - cy * cos) + cy)
        let e = (-asp * sin)
        let f = (asp * cos)
        let result = [(a + cos * x + sin * y), (b + e * x + f * y)]
        return result
    }
    
    func _line(x1: Int, y1: Int, x2: Int, y2: Int, opt: [String:Any], move: Bool, overlay: Bool) -> [Any] {
        var data: [[String : [CGFloat]]] = []
        
        var offset = opt["maxRandomnessOffset"] as! Double
        let bowing = opt["bowing"] as! Double
        let rough = opt["roughness"] as! Double
        
        let powerX = pow((Double(x1 - x2)), 2)
        let powerY = pow((Double(y1 - y2)), 2)
        let lengthSq = powerX + powerY
        
        if (offset * offset * 100) > lengthSq {
            offset = sqrt(lengthSq / 10)
        }
        
        let rand = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let diverge = CGFloat(0.2 + rand * 0.2)
        let halfOffset = CGFloat((offset / 2))
        
        var midDispX = CGFloat((bowing * offset * Double(y2 - y1) / 200.0))
        var midDispY = CGFloat((bowing * offset * Double(x1 - x2) / 200.0))
        
        midDispX = self.getOffset(min: -midDispX, max: midDispX, roughness: rough)
        midDispY = self.getOffset(min: -midDispY, max: midDispY, roughness: rough)
        
        var x = CGFloat(x1)
        var y = CGFloat(y1)
        
        var d1 = midDispX + CGFloat(x1) + CGFloat(x2 - x1) * diverge
        var d2 = midDispY + CGFloat(y1) + CGFloat(y2 - y1) * diverge
        var d3 = midDispX + CGFloat(x1) + 2.0 * CGFloat(x2 - x1) * diverge
        var d4 = midDispY + CGFloat(y1) + 2.0 * CGFloat(y2 - y1) * diverge
        var d5 = CGFloat(x2)
        var d6 = CGFloat(y2)
        
        if move {
            if overlay {
                x += self.getOffset(min: -halfOffset, max: halfOffset, roughness: rough)
                y += self.getOffset(min: -halfOffset, max: halfOffset, roughness: rough)
            }
            else {
                x += self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: rough)
                y += self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: rough)
            }
            data.append(["move" : [x, y]])
        }
        
        if overlay {
            d1 += self.getOffset(min: -halfOffset, max: halfOffset, roughness: rough)
            d2 += self.getOffset(min: -halfOffset, max: halfOffset, roughness: rough)
            d3 += self.getOffset(min: -halfOffset, max: halfOffset, roughness: rough)
            d4 += self.getOffset(min: -halfOffset, max: halfOffset, roughness: rough)
            d5 += self.getOffset(min: -halfOffset, max: halfOffset, roughness: rough)
            d6 += self.getOffset(min: -halfOffset, max: halfOffset, roughness: rough)
        }
        else {
            d1 += self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: rough)
            d2 += self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: rough)
            d3 += self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: rough)
            d4 += self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: rough)
            d5 += self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: rough)
            d6 += self.getOffset(min: CGFloat(-offset), max: CGFloat(offset), roughness: rough)
        }
        data.append(["bcurveTo" : [d1, d2, d3, d4, d5, d6]])
        return data
    }
    
    func _curve(points: [[CGFloat]], close: [CGFloat], opt: [String:Any]) -> [Any] {
        var data: [Any] = []
        let len = points.count
        if len > 3 {
            let s = CGFloat(1.0 - (opt["curveTightness"] as! Double))
            var b: [[CGFloat]] = [[], [], [], []]
            data.append(["move" : [points[1][0], points[1][1]]])
            var i = 1
            while (i + 2) < len {
                let cachedVertArray = points[i]
                
                let b_1 = (s * points[i + 1][0])
                let b_2 = (s * points[i - 1][0])
                let b_3 = ((b_1 - b_2) / 6)
                let b_4 = (s * points[i + 1][1])
                let b_5 = (s * points[i - 1][1])
                let b_6 = ((b_4 - b_5) / 6)
                let b_7 = (s * points[i][0])
                let b_8 = (s * points[i + 2][0])
                let b_9 = ((b_7 - b_8) / 6)
                let b_10 = (s * points[i][1])
                let b_11 = (s * points[i + 2][1])
                let b_12 = ((b_10 - b_11) / 6)
                
                b[0] = [cachedVertArray[0], cachedVertArray[1]]
                b[1] = [cachedVertArray[0] + b_3, cachedVertArray[1] + b_6]
                b[2] = [points[i + 1][0] + b_9, points[i + 1][1] + b_12]
                b[3] = [points[i + 1][0], points[i + 1][1]]
                
                data.append(["bcurveTo" : [b[1][0], b[1][1], b[2][0], b[2][1], b[3][0], b[3][1]]])
                i = i + 1
            }
            if close.count == 2 {
                let offset = CGFloat(opt["maxRandomnessOffset"] as! Double)
                let rough = opt["roughness"] as! Double
                let o1 = self.getOffset(min: -offset, max: offset, roughness: rough)
                let o2 = self.getOffset(min: -offset, max: offset, roughness: rough)
                data.append(["lineTo" : [(close[0] + o1), (close[1] + o2)]])
            }
            else if len == 3 {
                data.append(["move" : [points[1][0], points[1][1]]])
                data.append(["bcurveTo" : [points[1][0], points[1][1], points[2][0], points[2][1], points[2][0], points[2][1]]])
            }
            else if len == 2 {
                let c = self.doubleLine(x1: Int(points[0][0]), y1: Int(points[0][1]), x2: Int(points[1][0]), y2: Int(points[1][1]), opt: opt)
                data = data + c
            }
        }
        return data
    }
    
    func _ellipse(inc: CGFloat, cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat, os: CGFloat, ol: CGFloat, opt: [String:Any]) -> [Any] {
        let rough = opt["roughness"] as! Double
        let offset = self.getOffset(min: -0.5, max: 0.5, roughness: rough)
        let cgPI = (CGFloat.pi / 2)
        
        let radOffset = (offset - cgPI)
        var points: [[CGFloat]] = []
        
        var cosine = cx + 0.9 * rx * cos(radOffset - inc)
        var sine = cy + 0.9 * ry * sin(radOffset - inc)
       
        points.append([self.getOffset(min: -os, max: os, roughness: rough) + cosine,
                       self.getOffset(min: -os, max: os, roughness: rough) + sine])
       
        let len = CGFloat.pi * 2 + radOffset - 0.01
        var angle = radOffset
        while angle < len {
            points.append([self.getOffset(min: -os, max: os, roughness: rough) + cx + rx * cos(angle),
                           self.getOffset(min: -os, max: os, roughness: rough) + cy + ry * sin(angle)])
            angle = angle + inc
        }
        
        cosine = cos(radOffset + CGFloat.pi * 2 + ol * 0.5)
        sine = sin(radOffset + CGFloat.pi * 2 + ol * 0.5)
        
        points.append([self.getOffset(min: -os, max: os, roughness: rough) + cx + rx * cosine,
                       self.getOffset(min: -os, max: os, roughness: rough) + cy + ry * sine])
        
        cosine = rx * cos(radOffset + ol)
        sine = ry * sin(radOffset + ol)
        
        var offsetCos = self.getOffset(min: -os, max: os, roughness: rough)
        var offsetSin = self.getOffset(min: -os, max: os, roughness: rough)
        
        points.append([offsetCos + cx + 0.98 * cosine, offsetSin + cy + 0.98 * sine])
        
        offsetCos = self.getOffset(min: -os, max: os, roughness: rough)
        offsetSin = self.getOffset(min: -os, max: os, roughness: rough)
        
        points.append([offsetCos + cx + 0.9 * rx * cos(radOffset + ol * 0.5),
                       offsetSin + cy + 0.9 * ry * sin(radOffset + ol * 0.5)])
        return self._curve(points: points, close: [CGFloat(0.0)], opt: opt)
    }
    
    func _arc(i: CGFloat, cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat, st: CGFloat, sp: CGFloat, os: CGFloat, o:[String:Any]) -> [Any] {
        let rough = o["roughness"] as! Double
        let offset = self.getOffset(min: -0.1, max: 0.1, roughness: rough)
        let radOffset = (st + offset)
        var points: [[CGFloat]] = []
        
        var offset1 = self.getOffset(min: -os, max: os, roughness: rough)
        var offset2 = self.getOffset(min: -os, max: os, roughness: rough)
        let cosine = cos(radOffset - i)
        let sine = sin(radOffset - i)
        
        points.append([offset1 + cx + 0.9 * rx * cosine,
                       offset2 + cy + 0.9 * ry * sine])
        
        var angle = radOffset
        while angle <= sp {
            offset1 = self.getOffset(min: -os, max: os, roughness: rough)
            offset2 = self.getOffset(min: -os, max: os, roughness: rough)
            points.append([offset1 + cx + rx * cos(angle),
                           offset2 + cy + ry * sin(angle)])
            angle += i
        }
        points.append([cx + rx * cos(sp),
                       cy + ry * sin(sp)])
        points.append([cx + rx * cos(sp),
                       cy + ry * sin(sp)])
        return self._curve(points: points, close: [CGFloat(0.0)], opt: o)
    }
}

class Drawing {
    let type: String
    let data: [Any]
    
    init(type: String, data: [Any]) {
        self.type = type
        self.data = data
    }
}
