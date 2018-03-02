//
//  DropImageView.swift
//  MyImageAssetsAutomator
//
//  Created by GujyHy on 2018/2/23.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import Cocoa

let CORNER_RADIUS_PERCENT:CGFloat = 0.125

@objc protocol DropImageViewDelegate {
    @objc optional func didFinishDragWithFile(_ file:String)
}


class DropImageView: NSImageView {

    var isShowCorner:Bool = true
    var delegate:DropImageViewDelegate?
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    // 拖放文件进入拖放区，返回拖放操作类型
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        print("drag operation entered");
        
        let pboard = sender.draggingPasteboard()
//        let sourceDragMask:NSDragOperation = sender.draggingSourceOperationMask()
        
        if (pboard.types?.contains(NSPasteboard.PasteboardType("NSFilenamesPboardType")))! {
            return NSDragOperation.link
        }
        return NSDragOperation(rawValue: 0)
    }
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.copy
    }
    // 拖放结束的处理
    override func draggingExited(_ sender: NSDraggingInfo?) {
        print("drag operation finished");
    }
    // 最关键的方法,返回拖放的文件路径
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pBoard = sender.draggingPasteboard()
        var data:Data?
        if (pBoard.types?.contains(NSPasteboard.PasteboardType("NSFilenamesPboardType")))! {
            data = pBoard.data(forType: .fileURL)
            
            let files:NSArray = pBoard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as! NSArray
            if files.count > 0 {
                let filepath:String = files.lastObject as! String
                
                if let newDelegate = self.delegate {
                    newDelegate.didFinishDragWithFile!(filepath)
                }
//                print(filepath)
            }else{
                print("drag 图片为空")
            }
            
        }
        return true
    }
    
//    func dropAreaFadeOut() {
//        self.alphaValue = 0.2
//    }
//    func dropAreaFadeIn() {
//        self.alphaValue = 1.0
//    }
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
////        // 绘制
//        NSGraphicsContext.current?.restoreGraphicsState()
//        let width  = dirtyRect.size.width
//        let height = dirtyRect.size.height
//        // 圆角 or 直角
//        let bpath = isShowCorner == true ? NSBezierPath(roundedRect: dirtyRect, xRadius: width * CORNER_RADIUS_PERCENT , yRadius: height * CORNER_RADIUS_PERCENT) : NSBezierPath(rect: dirtyRect)
//        bpath.addClip()
//        NSColor.red.setStroke()
//        bpath.stroke()
//        NSGraphicsContext.current?.saveGraphicsState()
//    }
    

    
}
