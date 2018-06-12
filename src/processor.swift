import Foundation
import UIKit

class SegmentProcessor {
    
    let rr = Renderer()
    
    func processSegment(path: RoughPath, current: SegmentData, previous: SegmentData, opt: [String:Any]) -> [Any] {
        let data: [Any] = []
        if current.key == "M" || current.key == "m" {
            return self.move(path: path, current: current, opt: opt)
        }
        else if current.key == "H" || current.key == "h" {
            return self.horizontalLine(path: path, current: current, opt: opt)
        }
        else if current.key == "L" || current.key == "l" {
            return self.line(path: path, current: current, opt: opt)
        }
        else if current.key == "Z" || current.key == "z" {
            return self.close(path: path, current: current, opt: opt)
        }
        else if current.key == "C" || current.key == "c" {
            // return self.curve(path: path, current: current, opt: opt)
        }
        return data
    }
    
    func move(path: RoughPath, current: SegmentData, opt: [String:Any]) -> [Any] {
        var data: [Any] = []
        if current.data.count >= 2 {
            var x = Double(current.data[0])!
            var y = Double(current.data[1])!
            
            let offset = opt["maxRandomnessOffset"] as! Double
            let rough = opt["roughness"] as! Double
            let ro = CGFloat(1.0 * offset)
            
            x = Double(CGFloat(x) + rr.getOffset(min: -ro, max: ro, roughness: rough))
            y = Double(CGFloat(y) + rr.getOffset(min: -ro, max: ro, roughness: rough))
            path.setPosition(x: x, y: y);
            data.append(["move" : [CGFloat(x), CGFloat(y)]])
            
        }
        return data
    }
    
    func horizontalLine(path: RoughPath, current: SegmentData, opt: [String:Any]) -> [Any] {
        var data: [Any] = []
        if current.data.count != 0 {
            let x = CGFloat(truncating: NumberFormatter().number(from: current.data[0])!)
            // change doubleLine parameters to take CGFloats
            let dl = rr.doubleLine(x1: Int(path.getX()), y1: Int(path.getY()), x2: Int(x), y2: Int(path.getY()), opt: opt)
            path.setPosition(x: Double(x), y: path.getY())
            data = data + dl
        }
        return data
    }
    
    func line(path: RoughPath, current: SegmentData, opt: [String:Any]) -> [Any] {
        var data: [Any] = []
        if current.data.count >= 2 {
            let x = Double(current.data[0])!
            let y = Double(current.data[1])!
            // change doubleLine parameters to take CGFloats
            data = data + rr.doubleLine(x1: Int(path.getX()), y1: Int(path.getY()), x2: Int(x), y2: Int(y), opt: opt)
            path.setPosition(x: x, y: y)
        }
        return data
    }
    /*
    func curve(path: RoughPath, current: SegmentData, opt: [String:Any]) -> [Any] {
        var data: [Any] = []
        if current.data.count >= 6 {
            let x1 = CGFloat(truncating: NumberFormatter().number(from: current.data[0])!)
            let y1 = CGFloat(truncating: NumberFormatter().number(from: current.data[1])!)
            let x2 = CGFloat(truncating: NumberFormatter().number(from: current.data[2])!)
            let y2 = CGFloat(truncating: NumberFormatter().number(from: current.data[3])!)
            let x = CGFloat(truncating: NumberFormatter().number(from: current.data[4])!)
            let y = CGFloat(truncating: NumberFormatter().number(from: current.data[5])!)
            let ob = rr.bezierTo(x1: x1, y1: y1, x2: x2, y2: y2, x: x, y: y, p: path, o: opt)
            path.bezierReflectionPoint = [x + (x - x2), y + (y - y2)]
            data = data + ob
        }
        return data
    }
    */
    func close(path: RoughPath, current: SegmentData, opt: [String:Any]) -> [Any] {
        var data: [Any] = []
        let f = path.getFirst()
        if f[0] != -1.0 || f[1] != -1.0  {
            data = data + rr.doubleLine(x1: Int(path.getX()), y1: Int(path.getY()), x2: Int(f[0]), y2: Int(f[1]), opt: opt)
            path.setPosition(x: f[0], y: f[1])
            path.setFirst(v: [-1.0, -1.0])
        }
        return data
    }
}
