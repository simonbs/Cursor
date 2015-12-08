//: Playground - noun: a place where people can play

import Foundation
import CoreGraphics
import UIKit

extension CGFloat {
    func degreesToRadians() -> CGFloat {
        return self * CGFloat(M_PI) / 180
    }
    
    func radiansToDegrees() -> CGFloat {
        return self * 180 / CGFloat(M_PI)
    }
}

extension Int: SequenceType {
    public func generate() -> RangeGenerator<Int> {
        return (0..<self).generate()
    }
}

func performTestsUsingSetups(setups: [Setup]) -> TestResult {
    return setups.map(performTestUsingSetup).reduce(TestResult(totalCount: 0, acceptanceCount: 0), combine: +)
}

func performTestUsingSetup(setup: Setup) -> TestResult {
    var totalCount: Int = 0
    var acceptanceCount: Int = 0
//    drawSetup(setup, position: setup.position, userColor: .blueColor())
//    usleep(UInt32(0.1 * Double(1000000)))
    for _ in 0...99 {
        let offsettedPoint = offsetPoint(setup.position.toPoint(), withAmount: setup.offset, roomSize: setup.roomSize)
        let orientedOffsettedPoint = OrientedPoint(point: offsettedPoint, orientation: setup.position.orientation)
        let availableDevices = devicesInLineOfSightFromOrientedPoint(orientedOffsettedPoint, devices: setup.devices)
        let isDevicesInLineOfSight = availableDevices.contains(setup.focusedDevice)
        if isDevicesInLineOfSight {
            acceptanceCount += 1
        }
        totalCount += 1
//        drawSetup(setup, position: orientedOffsettedPoint, userColor: isDevicesInLineOfSight ? .greenColor() : .redColor())
//        usleep(UInt32(0.1 * Double(1000000)))
    }
    
    return TestResult(totalCount: totalCount, acceptanceCount: acceptanceCount)
}

func offsetPoint(point: CGPoint, withAmount amount: CGFloat, roomSize: CGSize) -> CGPoint {
    // Find amount we wish to offset x
    let preferredXOffset = randomNumberBetween(-amount, amount)
    // Adjust the preferred x offset so it fits within the bounds of the room
    let offsettedX = min(roomSize.width, max(0, point.x + preferredXOffset))
    // Find out how much we actually ended up offsetting x after adjusting it to fit within the bounds
    let trueXOffset = abs(point.x - offsettedX)
    // Calculate the offset of y and randomly decide if its negative or not
    let yOffset = randomlyFlipOperationalSign(sqrt(pow(amount, 2) - pow(trueXOffset, 2)))
    // Offset the y value
    var offsettedY = point.y + yOffset
    
    // We could not adjust in the chosen direction, choose the opposite instead
    if offsettedY < 0 || offsettedY > roomSize.height {
        offsettedY = point.y - yOffset
    }
    
    // Sanity check, should not be needed
    guard offsettedX >= 0 && offsettedX <= roomSize.width && offsettedY >= 0 && offsettedY <= roomSize.height else {
        return offsetPoint(point, withAmount: amount, roomSize: roomSize)
    }
    
    return CGPointMake(offsettedX, offsettedY)
}

func randomBool() -> Bool {
    return randomNumberBetween(0, 1) < 0.5
}

func randomlyFlipOperationalSign(value: CGFloat) -> CGFloat {
    return randomBool() ? value : -value
}

func randomNumberBetween(firstNum: CGFloat, _ secondNum: CGFloat) -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}

func devicesInLineOfSightFromOrientedPoint(orientedPoint: OrientedPoint, devices: [Device], visibilityAngle: CGFloat = 30) -> [Device] {
    return devices.filter { d in
        let normalizedDegrees = angleBetween(orientedPoint.toPoint(), point: d.coordinate)
        
        var minDegrees = orientedPoint.orientation - visibilityAngle / 2
        var maxDegrees = orientedPoint.orientation + visibilityAngle / 2
        
        minDegrees += minDegrees < 0 ? 360 : 0
        maxDegrees += maxDegrees < 0 ? 360 : 0
        
        minDegrees -= minDegrees > 360 ? 360 : 0
        maxDegrees -= maxDegrees > 360 ? 360 : 0
        
        if minDegrees < maxDegrees {
            return normalizedDegrees >= minDegrees && normalizedDegrees <= maxDegrees
        } else {
            return normalizedDegrees >= minDegrees || normalizedDegrees <= maxDegrees
        }
    }
}

func angleBetween(position: CGPoint, point: CGPoint) -> CGFloat {
    let radians = atan2(point.x - position.x, point.y - position.y)
    let degrees = radians.radiansToDegrees()
    let normalizedDegrees = degrees < 0 ? degrees + 360 : degrees
    return normalizedDegrees
}

func drawSetup(setup: Setup, position: OrientedPoint, userColor: UIColor = .purpleColor()) -> UIImage {
    let meterToPixels: CGFloat = 150
    let rect = CGRectMake(0, 0, setup.roomSize.width * meterToPixels, setup.roomSize.height * meterToPixels)

    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
    CGContextFillRect(context, rect)
    
    // Configure style for text in a device
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .ByWordWrapping
    paragraphStyle.alignment = .Center
    let titleAttr = [
        NSForegroundColorAttributeName: UIColor.blackColor(),
        NSFontAttributeName: UIFont.systemFontOfSize(10),
        NSParagraphStyleAttributeName: paragraphStyle
    ]
    
    // Draw devices
    setup.devices.forEach { device in
        let deviceRadius: CGFloat = 0.35 // In meters
        let deviceRect = CGRectMake(
            device.coordinate.x * meterToPixels - (deviceRadius * meterToPixels) / 2,
            rect.height - device.coordinate.y * meterToPixels - (deviceRadius * meterToPixels) / 2, // Inverted y axis
            deviceRadius * meterToPixels,
            deviceRadius * meterToPixels)
        let text = device.name as NSString

        let maxSize = CGSizeMake(deviceRadius * meterToPixels, deviceRadius * meterToPixels)
        let size = text.boundingRectWithSize(maxSize, options: [ .UsesLineFragmentOrigin, .UsesFontLeading ], attributes: titleAttr, context: nil)
        let textRect = CGRectMake(deviceRect.minX + (maxSize.width - size.width) / 2, deviceRect.minY + (maxSize.height - size.height) / 2, size.width, size.height)
        CGContextSetFillColorWithColor(context, UIColor.orangeColor().CGColor)
        CGContextFillEllipseInRect(context, deviceRect)
        text.drawInRect(textRect, withAttributes: titleAttr)
    }
    
    // Draw user position
    let positionRadius: CGFloat = 0.35 // In meters
    let positionRect = CGRectMake(
        position.x * meterToPixels - (positionRadius * meterToPixels) / 2,
        rect.height - position.y * meterToPixels - (positionRadius * meterToPixels) / 2, // Inverted y axis
        positionRadius * meterToPixels,
        positionRadius * meterToPixels)
    CGContextSetFillColorWithColor(context, userColor.CGColor)
    CGContextFillEllipseInRect(context, positionRect)
    
    // Draw visibility indicator
    CGContextSaveGState(context)
    CGContextTranslateCTM(context, position.x * meterToPixels, rect.size.height - position.y * meterToPixels)
    CGContextRotateCTM(context, position.orientation * CGFloat(M_PI) / 180)
    let path = CGPathCreateMutable()
    CGPathMoveToPoint(path, nil, 0, 0)
    CGPathAddLineToPoint(path, nil, 0, -max(rect.width, rect.height) * 2)
    CGContextSetLineWidth(context, positionRadius * meterToPixels)
    CGContextSetStrokeColorWithColor(context, userColor.colorWithAlphaComponent(0.4).CGColor)
    CGContextAddPath(context, path)
    CGContextStrokePath(context)
    CGContextRestoreGState(context)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

func createSetupWithPosition(point: CGPoint, focusedDeviceId: Int) -> Setup {
    let devices = createDevices()
    guard let focusedDevice = devices.filter({ $0.id == focusedDeviceId }).first else {
        fatalError("No device with id \(focusedDeviceId) found.")
    }
    
    let orientation = angleBetween(point, point: focusedDevice.coordinate)
    let roomSize = CGSizeMake(6.9, 5.37)
    guard point.x >= 0 && point.x <= roomSize.width else {
        fatalError("Setup could not be created. Illegal value for x \(point.x) does not fit within 0 - \(roomSize.width)")
    }
    
    guard point.y >= 0 && point.y <= roomSize.height else {
        fatalError("Setup could not be created. Illegal value for y \(point.y) does not fit within 0 - \(roomSize.height)")
    }
    
    return Setup(
        position: OrientedPoint(point: point, orientation: orientation),
        devices: createDevices(),
        focusedDevice: focusedDevice,
        roomSize: CGSizeMake(6.9, 5.37),
        offset: 2.92)
}

func createDevices() -> [Device] {
    return [
        Device(id: 1, name: "Device 1", coordinate: CGPoint(x: 6.5, y: 3.4)),
        Device(id: 2, name: "Device 2", coordinate: CGPoint(x: 3.5, y: 3.4)),
        Device(id: 3, name: "Device 3", coordinate: CGPoint(x: 4, y: 1.8)),
        Device(id: 4, name: "Device 4", coordinate: CGPoint(x: 2.5, y: 1.8)),
        Device(id: 5, name: "Device 5", coordinate: CGPoint(x: 0.5, y: 0.5)),
        Device(id: 6, name: "Device 6", coordinate: CGPoint(x: 2.5, y: 3.2))
    ]
}

struct Device: Hashable {
    let id: Int
    let name: String
    let coordinate: CGPoint
    var hashValue: Int { return id }
}

func ==(lhs: Device, rhs: Device) -> Bool {
    return lhs.id == rhs.id
}

struct Setup {
    let position: OrientedPoint
    let devices: [Device]
    let focusedDevice: Device
    let roomSize: CGSize
    let offset: CGFloat
}

struct OrientedPoint {
    let x: CGFloat
    let y: CGFloat
    let orientation: CGFloat
    
    init(point: CGPoint, orientation: CGFloat) {
        self.x = point.x
        self.y = point.y
        self.orientation = orientation
    }
}

extension OrientedPoint {
    func toPoint() -> CGPoint {
        return CGPointMake(x, y)
    }
}

struct TestResult {
    let totalCount: Int
    let acceptanceCount: Int
    var acceptanceRate: Float {
        return Float(acceptanceCount) / Float(totalCount)
    }
    
    init(totalCount: Int, acceptanceCount: Int) {
        self.totalCount = totalCount
        self.acceptanceCount = acceptanceCount
    }
    
    init() {
        self.totalCount = 0
        self.acceptanceCount = 0
    }
}

func +(lhs: TestResult, rhs: TestResult) -> TestResult {
    return TestResult(totalCount: lhs.totalCount + rhs.totalCount, acceptanceCount: lhs.acceptanceCount + rhs.acceptanceCount)
}

let setups = [
    createSetupWithPosition(CGPoint(x: 2, y: 2), focusedDeviceId: 1),
    createSetupWithPosition(CGPoint(x: 3.4, y: 4.9), focusedDeviceId: 1),
    createSetupWithPosition(CGPoint(x: 1.1, y: 3.6), focusedDeviceId: 1),
    createSetupWithPosition(CGPoint(x: 0.5, y: 0.5), focusedDeviceId: 2),
    createSetupWithPosition(CGPoint(x: 1.1, y: 3.3), focusedDeviceId: 2),
    createSetupWithPosition(CGPoint(x: 5.5, y: 5.2), focusedDeviceId: 2),
    createSetupWithPosition(CGPoint(x: 3, y: 2.9), focusedDeviceId: 3),
    createSetupWithPosition(CGPoint(x: 1, y: 2), focusedDeviceId: 3),
    createSetupWithPosition(CGPoint(x: 2.5, y: 2.3), focusedDeviceId: 3),
    createSetupWithPosition(CGPoint(x: 4.4, y: 3.4), focusedDeviceId: 4),
    createSetupWithPosition(CGPoint(x: 6, y: 1.2), focusedDeviceId: 4),
    createSetupWithPosition(CGPoint(x: 5.8, y: 2.7), focusedDeviceId: 4),
    createSetupWithPosition(CGPoint(x: 4.6, y: 1.4), focusedDeviceId: 5),
    createSetupWithPosition(CGPoint(x: 2.3, y: 5.2), focusedDeviceId: 5),
    createSetupWithPosition(CGPoint(x: 0.3, y: 0.1), focusedDeviceId: 5),
    createSetupWithPosition(CGPoint(x: 6.2, y: 4.4), focusedDeviceId: 6),
    createSetupWithPosition(CGPoint(x: 5.1, y: 2.7), focusedDeviceId: 6),
    createSetupWithPosition(CGPoint(x: 3.2, y: 5.1), focusedDeviceId: 6)
]

let result = 10.map({ _ in performTestsUsingSetups(setups) }).reduce(TestResult(), combine: +)
print("\(result.acceptanceRate * 100)% of the tests resulted in acceptance.")
