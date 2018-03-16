
## 前言

今天我要介绍的是这个:**图片资源自动化生成小工具**

**为什么要开发这个小工具?**

> 通常 App 开发完后后，都会让设计师做一张1024*1024的图片，然后根据各个设备缩放成不同的大小的图片。
如果能够把这个繁琐的过程用一个小工具来实现，岂不是节省了很多时间？


---

## 正文

 接下来就简单的说明如何实现的，先上张App截图。
![mypic1]({{site.url}}/img/postsimgs/2018-03-01-pic1.png)

 不同平台的AppIcon安装图标
![mypic1]({{site.url}}/img/postsimgs/2018-03-01-pic2.png)
![mypic1]({{site.url}}/img/postsimgs/2018-03-01-pic3.png)
 
 每个App项目下面都会有一个 AppIcon.appiconset 文件夹，文件夹下有一个json文件和png图片，而我这个小工具主要的功能就是生成这个 AppIcon.appiconset
 
 Contents.json 文件如下
![mypic1]({{site.url}}/img/postsimgs/2018-03-01-pic4.png)

 这里的 idiom 表示不同的系统平台 iPhone、iPad、Mac。

### 功能使用
 
 只要将图片直接拖到到红框中，选取路径，选取平台（目前只支持iPhone,iPad,Mac）点击生成，相当方便。
 
### 核心代码
#### imageView的拖放
实现 NSDraggingDestination 协议下的三个方法

```swift
func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperatio
func draggingExited(_ sender: NSDraggingInfo?)
func performDragOperation(_ sender: NSDraggingInfo) -> Bool 
```
`draggingEntered` 拖放文件进入拖放区，返回拖放操作类型

`draggingExited` 返回图片拖放结束

`performDragOperation` 最关键的方法,返回拖放的文件路径

#### 图片裁剪和保存

```swift
func reSize(resize:NSSize,isRoundCorner:Bool = false) -> NSImage{
        let resizeWidth  = resize.width/2;
        let resizeHeight = resize.height/2; // 缩小2倍先、
        let resizedImage = NSImage(size: NSSize(width: resizeWidth, height: resizeHeight))
        let originalSize = self.size
        resizedImage.lockFocus()
        self.draw(in:NSRect(x: 0, y: 0, width: resizeWidth, height: resizeHeight), from: NSRect(x:0,y:0,width:originalSize.width,height:originalSize.height), operation: NSCompositingOperation.sourceOver, fraction: 1.0) // self.draw 生成图片后放大了2倍
        resizedImage.unlockFocus()
        return resizedImage
    }
```

```swift
let imageData  = image.reSize(resize: size).tiffRepresentation
        let outputData:Data = (NSBitmapImageRep(data: imageData!)?.representation(using: NSBitmapImageRep.FileType.png, properties: [:]))!
        let outpNSData = outputData as NSData
        let filePath   = self.appiconsetPathString + "/\(name).png"
        outpNSData.write(toFile: filePath, atomically: true)
```

## 总结
在使用过程中发现任何bug，请直接跟我联系。[源码下载地址]()

以后我都会在每周五晚分享一篇文章，谢谢大家支持。

## 参考

* [自动化小工具](http://www.macdev.io/ebook/autoTools.html)

 



