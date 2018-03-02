//
//  NSImage.swift
//  MyImageAssetsAutomator
//
//  Created by GujyHy on 2018/2/23.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import Cocoa

extension NSImage {

    func reSize(resize:NSSize,isRoundCorner:Bool = false) -> NSImage{
        
        let resizeWidth  = resize.width/2;
        let resizeHeight = resize.height/2; // 缩小2倍先、
        let resizedImage = NSImage(size: NSSize(width: resizeWidth, height: resizeHeight))
        let originalSize = self.size
        resizedImage.lockFocus()
        
        // 切成圆角
        if isRoundCorner == true {
            let xRad  = resizeWidth * CORNER_RADIUS_PERCENT
            let yRad  = resizeHeight * CORNER_RADIUS_PERCENT
            let imageFrame = NSRect(x: 0, y: 0, width: resizeWidth, height: resizeHeight)
            let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: xRad, yRadius: yRad)
            clipPath.windingRule = NSBezierPath.WindingRule.evenOddWindingRule
            clipPath.addClip()
        }
        self.draw(in:NSRect(x: 0, y: 0, width: resizeWidth, height: resizeHeight), from: NSRect(x:0,y:0,width:originalSize.width,height:originalSize.height), operation: NSCompositingOperation.sourceOver, fraction: 1.0) // self.draw 生成图片后放大了2倍
        resizedImage.unlockFocus()
        return resizedImage
    }
    
    
//    func roundCorner(image:NSImage,width:CGFloat = 192,height:CGFloat = 192) ->NSImage {
//
//        let resizeWidth  = width/2;
//        let resizeHeight = height/2; // 缩小2倍先、
//
//        let resizedImage = NSImage(size: NSSize(width: resizeWidth, height: resizeHeight))
//        let originalSize = self.size
//        resizedImage.lockFocus()
//
//        // 切成圆角
//        let xRad  = resizeWidth * CORNER_RADIUS_PERCENT
//        let yRad  = resizeHeight * CORNER_RADIUS_PERCENT
//        let imageFrame = NSRect(x: 0, y: 0, width: resizeWidth, height: resizeHeight)
//        let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: xRad, yRadius: yRad)
//        clipPath.windingRule = NSBezierPath.WindingRule.evenOddWindingRule
//        clipPath.addClip()
//
//        self.draw(in:NSRect(x: 0, y: 0, width: resizeWidth, height: resizeHeight), from: NSRect(x:0,y:0,width:originalSize.width,height:originalSize.height), operation: NSCompositingOperation.sourceOver, fraction: 1.0) // self.draw 生成图片后放大了2倍
//        resizedImage.unlockFocus()
//        return resizedImage
//
//    }
    
    
    
}
