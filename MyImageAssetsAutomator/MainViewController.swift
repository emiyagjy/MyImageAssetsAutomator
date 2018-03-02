//
//  MainViewController.swift
//  MyImageAssetsAutomator
//
//  Created by GujyHy on 2018/2/23.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    @IBOutlet var platformSelection: NSComboBox!
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var dropImageView: DropImageView!
    @IBOutlet var pathField: NSTextField!
    
    var images:[Any]!
    var contents:[String:Any]! // 存储json格式
    var platformData:NSArray!  // 存储各个平台的数据
    
    // 默认本地首页
    var encodingPathString:String{
        get {
//            return NSHomeDirectory()    // "/Users/gujyhy/Desktop"
            return self.pathField.stringValue
        }
    }
    // 文件夹路径
    var appiconsetPathString:String {
        get {
            return self.encodingPathString + "/AppIcon.appiconset"
        }
    }
    var appiconsetPath:URL {
        get {
            return URL(fileURLWithPath: self.appiconsetPathString)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 读取默认地址
        if UserDefaults.standard.object(forKey: "savePath") == nil {
            self.pathField.stringValue = NSHomeDirectory()
        }else{
            self.pathField.stringValue = UserDefaults.standard.object(forKey: "savePath") as! String
        }
        // 设置头部标题
        self.titleLabel.stringValue = "将图片拖动到红框内（拖动图片最好是1024x1024）"
        self.titleLabel.font = NSFont.systemFont(ofSize: 20)
        self.titleLabel.alignment = NSTextAlignment.center
        
        // 图片
        self.dropImageView.delegate = self
        self.dropImageView.wantsLayer = true
        self.dropImageView.layer?.borderColor = NSColor.red.cgColor
        self.dropImageView.layer?.borderWidth = 0.5
        self.dropImageView.layer?.cornerRadius = self.dropImageView.frame.size.width * CORNER_RADIUS_PERCENT
        // 默认选择iPhone平台
        self.platformSelection.selectItem(at: 0)
        
    }
    
    // MARK:1、读取各个平台配置数据（plist）
    // MARK:2、把读取的数据各自进行解析
    // MARK:3、生成图片（核心）
    // MARK:4、生成json文件
    
    // 图片导出
    func generateIconWithImage(_ image:NSImage) {
        
        self.images   = [Any]()
        self.contents = [String:Any]()
        // 创建文件夹
        do {
            print(self.appiconsetPath)
            try FileManager.default.createDirectory(at:self.appiconsetPath , withIntermediateDirectories: true, attributes: nil)
        }catch {
            print(error.localizedDescription)
        }
        
        // 1、读取各个平台的配置数据（plist）
        let plistPath   = Bundle.main.path(forResource: "SizeFile", ofType: "plist")
        self.platformData   = NSArray(contentsOfFile: plistPath!)
        // 2、把读取的数据各自进行解析
        let info:[String:Any] = ["author":"xcode","version ":1] as [String : Any]
        self.contents["info"] = info
        
        // iPhone
        if self.platformSelection.indexOfSelectedItem == 0 {
            self.outputImageForiPhone(image)
        }
        // iPad
        else if self.platformSelection.indexOfSelectedItem == 1 {
            self.outputImageForiPad(image)
        }
        // mac
        else {
            self.outputImageForMac(image)
            //可以不用判断，想想如何用进一步优化
        }
        
        // 把images添加到字典
        self.contents["images"] = self.images
      
        // 4、生成json文件
        do {
            let jsonData   = try JSONSerialization.data(withJSONObject: self.contents, options: .prettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            let fileName   = self.appiconsetPathString + "/Contents.json"
            try jsonString.write(toFile: fileName, atomically: false, encoding:String.Encoding.nonLossyASCII.rawValue)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    // 导出iPhone图片
    func outputImageForiPhone(_ image:NSImage) {
        let iPhoneSizeDict = self.platformData![0] as! NSDictionary
        let iPoneSizeKeys  = iPhoneSizeDict.allKeys
        // 3、生成输出图片
        self.outputImage(image,
                         infoDict: iPhoneSizeDict,
                         allKeys: iPoneSizeKeys,
                         idiom: "iphone")
    }
      // 导出iPad图片
    func outputImageForiPad(_ image:NSImage) {
        let sizeDict = self.platformData![1] as! NSDictionary
        let sizeKeys  = sizeDict.allKeys
        // 3、生成输出图片
        self.outputImage(image,
                         infoDict: sizeDict,
                         allKeys: sizeKeys,
                         idiom: "ipad")
    }
    
    // 导出Mac图片
    func outputImageForMac(_ image:NSImage) {
        let sizeDict = self.platformData![2] as! NSDictionary
        let sizeKeys  = sizeDict.allKeys
        // 3、生成输出图片
        self.outputImage(image,
                         infoDict: sizeDict,
                         allKeys: sizeKeys,
                         idiom: "mac")
    }
    
    
    // 核心代码
    func outputImage(_ image:NSImage,
                     infoDict:NSDictionary,
                     allKeys:[Any],
                     idiom:String) {
        
        for sizeKey in allKeys {
//            print(sizeKey)
            let iconInfoDict   = infoDict[sizeKey] as! NSDictionary
            let iconSizeString = iconInfoDict["Dimensions"] as! String
            let iconSize       = NSSizeFromString(iconSizeString)
            let iconSizeName   = iconInfoDict["Size"] as! String
            let iconName       = iconInfoDict["Name"] as! String
           
            self.outputImage(image,
                             size: iconSize,
                             sizeName:iconSizeName,
                             name: iconName,
                             idiom: idiom)
        }
        // 打开路径
        NSWorkspace.shared.open(URL(fileURLWithPath: self.encodingPathString))
 
    }
    func outputImage(_ image:NSImage,
                     size:NSSize,
                     sizeName:String,
                     name:String,
                     idiom:String) {
        // 图片写入文件夹
        let imageData  = image.reSize(resize: size).tiffRepresentation
        let outputData:Data = (NSBitmapImageRep(data: imageData!)?.representation(using: NSBitmapImageRep.FileType.png, properties: [:]))!
        let outpNSData = outputData as NSData
        let filePath   = self.appiconsetPathString + "/\(name).png"
        outpNSData.write(toFile: filePath, atomically: true)
      
        // 写入json数据
        var dict:[String:String] = [String:String]()
        dict["size"] = sizeName
        if (idiom == "ipad" || idiom == "iphone") && sizeName == "1024x1024" {
            dict["idiom"] = "ios-marketing"
        }else{
            dict["idiom"] =  idiom
        }
        dict["filename"] = "\(name).png"
        let range = name.range(of: "@")
        if range == nil{
            dict["scale"] = "1x"
        }else{
            let value =  (name as NSString).substring(from: ((range?.lowerBound.encodedOffset)! + 1))
            dict["scale"] = value
        }
        self.images.append(dict)
    }
    
    // MARK: Events
    @IBAction func generateAction(_ sender: Any) {
        
        // 判断图片
        if self.dropImageView.image == nil {
            let alert = NSAlert()
            alert.messageText = "请将图片拖入到红框中"
            alert.addButton(withTitle: "好的")
            alert.alertStyle = NSAlert.Style.warning
            alert.beginSheetModal(for: self.view.window!, completionHandler: { (result) in
                if result  == NSApplication.ModalResponse.OK {
                    print("好的")
                }
            })
        }else {
            self.generateIconWithImage(self.dropImageView.image!)
        }
    }

    @IBAction func selectButtonAction(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles       = true
        openPanel.canChooseDirectories = true
        openPanel.directoryURL         = URL(fileURLWithPath: NSHomeDirectory())
        openPanel.allowsMultipleSelection  = true
        openPanel.beginSheetModal(for: self.view.window!, completionHandler: { (result) in
            if (result == NSApplication.ModalResponse.OK) {
                self.pathField.stringValue = (openPanel.urls.first?.path)!
            }
            UserDefaults.standard.set((openPanel.urls.first?.path)!, forKey: "savePath")
            UserDefaults.standard.synchronize()
        })
    }
}

extension MainViewController:DropImageViewDelegate {
    func didFinishDragWithFile(_ file:String) {
        let image = NSImage(contentsOfFile: file)
        self.dropImageView.image = image
    }
}
