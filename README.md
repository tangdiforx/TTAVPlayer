## TTAVPlayer-iOS多模式&富交互视频播放器实现(附源码)


### 0.1 TODO
```
这里用来记录当前项目待办任务，有任何需求请直接提issue，我会跟进。
```
1. 本地视频文件播放支持。
2. CocoaPods集成方式。

### 0.2 更新日志
```
这里用来记录项目更新情况 当前版本号v1.1
```
1. README新增集成方式的介绍。

1. 修复播放器尚未加载完成前拖动Slider会出现的崩溃风险。

2. 新增两个API:

```
//播放器加载完毕前的预处理

(void)beforePlayerLoadPretreatment

//播放器加载完毕之后的处理,这部分逻辑不与播放方法耦合

(void)afterPlayerLoadTreatment
```

### 1.背景

最近开始抓端体验，播放器作为一个基础功能一直为人诟病:交互不友好，如手势调节播放进度，音量，屏幕亮度，以及对网络状态的处理等。同时也不能支持现在业务场景多样化对播放器的需求等等。于是决定在这一期进行“整治”。

首先为了支持业务需求的多样化，视频播放器需要支持四种模式:普通模式，竖屏模式，横屏模式，静音模式。

	普通模式:商品内容，文章内容嵌套播放器，H5桥接播放。
	静音模式:列表自动播放时需要，如手淘微淘列表。
	竖屏模式:浸入式体验播放，常常用于H5桥接播放与静音播放时点击查看详情，如微博，手淘微淘。
	横屏模式:最佳播放体验，具有最丰富的交互操作，如快捷调节音量，播放进度，屏幕亮度。

最终实现效果部分如下:

###### 普通模式-全屏模式

<img src="https://img.alicdn.com/tfs/TB1s3StQpXXXXcAXXXXXXXXXXXX-304-569.gif">

##### 竖屏模式-全屏模式

<img src="https://gw.alicdn.com/tfs/TB12RKpQpXXXXbkXpXXXXXXXXXX-304-569.gif">

### 2.设计概要

对于基础功能，无论是API级别还是Framework级别，我的设计思想都是"保证最小的接入成本同时保证最大的扩展性"。也就是，对于绝大部分的情况，提供简单易用的API让接入方可以非常方便的接入。但是当接入方需要自定义时，我们也要提供强大的自定义能力。

那回归到播放器，在第一小节中提到的四种模式其实已经可以满足绝大部分的场景需求。把这些模式预置进播放器设计中，就已经可以保证尽可能少的接入成本，只要在设计上进行分层，把基础功能和UI部分以及各种模式特有的Feature进行分层，新增自定义模式，只提供播放器View的基础控制接口，如播放，暂停，调整进度，全屏等，然后UI部分部分可以完全交由接入方自定义。


### 3.详细设计

基于第二小节的设计思想，我们可以确定播放器的五种模式:

<img src="https://img.alicdn.com/tfs/TB1YFjHRpXXXXX7aFXXXXXXXXXX-376-125.png">


为了尽量少的代码引入，我们选择基于苹果自带的AVPlayer进行播放器开发。关于AVPlayer，在此不做赘述。它用来负责视频文件的解码，播放，以及一些基础的播放操作。

于是，我们便基于AVPlayer创建出我们的TTAVPlayer。除此之外，为了让用户看到视频以及一些UI控件用以提示和交互，还需要添加TTAVPlayerView。TTAVPlayer负责给TTAVPlayerView提供视频文件的播放，暂停，进度调整等基本操作，以及播放状态的回调，而TTAVPlayerView是用户可见的部分，并直接操作TTAVPlayer。

基于以上的思想，可画出以下的设计图:

<img src="https://img.alicdn.com/tfs/TB1pyYRRpXXXXaFapXXXXXXXXXX-779-392.png">

TTAVPlayer持有一个AVPlayerItem的实例，它提供了我们访问一个视频文件(AVAsset)的接口，如当前播放时间，视频总时间，播放完成，失败的回调等等。在TTAVPlayer这一层，我们基本上可以把所有的播放类的操作进行封装起来，仅仅向外暴露有关视频播放的代理方法，上层只需要去实现这些代理方法就可以得到整个视频播放时需要的信息回调：

<img src="https://img.alicdn.com/tfs/TB1zIctRpXXXXbyXXXXXXXXXXXX-573-189.png">


而TTAVPlayerView则是设计出来面向于真正的上层调用者的。这个调用者可能是预设模式，可能是使用自定义模式的接入方。所以TTAVPlayer提供出来的代理方法对上层调用者应该是透明的，而需要由TTAVPlayer提供出调用者真正想需要的代理接口。这些接口不仅全量包含了TTAVPlayerView的回调，还包括一些跟用户相关的回调，比如播放器全屏的回调，视频被点击的回调，播放暂停的回调，View加载完成的回调等等。

这样的设计保证了TTAVPlayerView代码的纯净性，它与业务代码解耦，只负责了视频播放本身，而不去关心上面的界面渲染以及一些业务操作逻辑。这为自定义模式的扩展性打下了基础。基于此，我们又有了以下设计:

<img src="https://img.alicdn.com/tfs/TB1876PRpXXXXb_apXXXXXXXXXX-953-732.png">

### 4.丰富的Feature

为了提供一个高完成度播放器，我们提供了丰富的Feature:

1. 横屏模式下手势识别，控制快进/快退、音量调节、屏幕亮度调节，向流行App看齐。
1. 检测屏幕方向自动切换横竖屏，并且考虑到很多App并未打开横屏开关，采用“假横屏”的方式来模拟，节省了接入成本。
1. 容错提示页面，温馨提示，让用户不再尴尬；
1. 检测网络切换功能，当网络从WIFI切到数据流量时，自动暂停视频；
1. 静音播放模式，让用户在公共场所看视频不尴尬；

### 5.怎样在项目中使用TTAVPlayer

```
对于不使用Cocoapods的用户:首先你需要了解目前iOS SDK需要支持的四种指令集:X86_84,i386(针对模拟器)，ARMv7,ARM64(针对真机，32位和64位CPU之分)。一个完整的SDK需要支持这四种指令集。
```
1. 首先使用TTAVPlayer Framework的源码，在Xcode的Target处选取两种target:Xcode支持的最新模拟器 && Generic iOS Device。分别进行编译，最后在Product目录里，拿到相应的Framework保存下来。
2. 打开这两个Framework，取出Framework中的静态库文件TTAVPlayer(不带任何后缀名)，然后将这两个静态库文件，使用lipo -create命令合并成一个。
3. 打开任意一个Framework文件，将原本的静态库文件替换成合并后的静态文件。
4. 在编译的主工程的copy resource bundle里，添加对Framework中Resource.bundle的引用。
5. 集成完毕。请注意，TTAVPlayer的最低系统支持版本为iOS 7.0。

```
对于使用Cocoapods的用户，我会尽快添加对pods的支持。已添加到TODO。
```

### 6.Tips


1. 如对代码有不解或者发现Bug，可直接github提issue，我会尽量解掉。
1. Demo请尽量运行在真机上。
3. 需要探讨可直接联系我。


知乎:[直接点击](https://www.zhihu.com/people/tang-di-78)

GitHub:[直接点击](https://github.com/tangdiforx/TTAVPlayer)

简书:[直接点击](http://www.jianshu.com/p/1deb9a590cd6)