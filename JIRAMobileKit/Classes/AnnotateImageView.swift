//
//  AnnotateImageView.swift
//  Pods
//
//  Created by Will Powell on 30/08/2017.
//
//


import UIKit

let π = CGFloat(Double.pi)

class AnnoateImageView: UIImageView {
    
    fileprivate let defaultLineWidth:CGFloat = 3
    
    public var drawColor: UIColor = UIColor.black
    
    private let tiltThreshold = π/6  // 30º
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        image?.draw(in: bounds)
        
        var touches = [UITouch]()
        
        if #available(iOS 9.0, *) {
            if let coalescedTouches = event?.coalescedTouches(for: touch) {
                touches = coalescedTouches
            } else {
                touches.append(touch)
            }
        } else {
            // Fallback on earlier versions
        }
        
        print(touches.count)
        for touch in touches {
            drawStroke(context, touch: touch)
        }
        
        // Update image
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    fileprivate func drawStroke(_ context: CGContext?, touch: UITouch) {
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        
        var lineWidth:CGFloat
        // Calculate line width for drawing stroke
        if #available(iOS 9.1, *) {
            if touch.altitudeAngle < tiltThreshold {
                lineWidth = lineWidthForShading(context: context, touch: touch)
            } else {
                lineWidth = lineWidthForDrawing(context, touch: touch)
            }
        } else {
            lineWidth = lineWidthForDrawing(context, touch: touch)
        }
        
        // Set color
        drawColor.setStroke()
        
        // Configure line
        context?.setLineWidth(lineWidth)
        context?.setLineCap(.round)
        
        
        // Set up the points
        context?.move(to: CGPoint(x: previousLocation.x, y: previousLocation.y))
        context?.addLine(to: CGPoint(x: location.x, y: location.y))
        // Draw the stroke
        context?.strokePath()
        
    }
    
    fileprivate func lineWidthForDrawing(_ context: CGContext?, touch: UITouch) -> CGFloat {
        
        let lineWidth = defaultLineWidth
        
        return lineWidth
    }
    
    private func lineWidthForShading(context: CGContext?, touch: UITouch) -> CGFloat {
        
        // 1
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        
        // 2 - vector1 is the pencil direction
        if #available(iOS 9.1, *) {
            let vector1 = touch.azimuthUnitVector(in: self)
            
            // 3 - vector2 is the stroke direction
            let vector2 = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)
            
            // 4 - Angle difference between the two vectors
            var angle = abs(atan2(vector2.y, vector2.x) - atan2(vector1.dy, vector1.dx))
            
            // 5
            if angle > π {
                angle = 2 * π - angle
            }
            if angle > π / 2 {
                angle = π - angle
            }
            
            // 6
            let minAngle: CGFloat = 0
            let maxAngle = π / 2
            let normalizedAngle = (angle - minAngle) / (maxAngle - minAngle)
            
            // 7
            let maxLineWidth: CGFloat = 60
            
            let minForce: CGFloat = 0.0
            let maxForce: CGFloat = 5
            
            let normalizedAlpha = (touch.force - minForce) / (maxForce - minForce)
            
            context!.setAlpha(normalizedAlpha)
            let lineWidth = maxLineWidth * normalizedAngle
            return lineWidth
        } else {
            return 3
        }
    }
    
    func clearCanvas(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0
            }, completion: { finished in
                self.alpha = 1
                self.image = nil
            })
        } else {
            image = nil
        }
    }
}
