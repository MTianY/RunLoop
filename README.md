# Runloop

## 一. 什么是 RunLoop?

运行循环, 在程序运行的过程中循环的做一些事情.

## 二.应用范畴

- 定时器
- PerformSelector
- GCD Async Main Queue
- 事件响应
- 手势识别
- 界面刷新
- 网络请求
- AutoreleasePool

## 三.作用

- 保持程序的持续运行
- 处理 App 中的各种事件(如触摸事件、定时器事件等)
- 节省 CPU 资源, 提高程序性能;该做事时做事,该休息时休息.

## 四.获取 RunLoop 对象

`NSRunLoop` 和 `CFRunLoopRef` 都代表着 `RunLoop` 对象.且 `NSRunLoop` 是基于 `CFRunLoopRef` 的一层 OC 包装. `CFRunLoopRef` 是开源的.

[下载源码网址](https://opensource.apple.com/tarballs/CF)

- `Foundation` 框架
    - `NSRunLoop` 

- `Core Foundation` 框架
    - `CFRunLoopRef`

获取当前的 runloop

```objc
NSRunLoop *curRunLoop = [NSRunLoop currentRunLoop];

CFRunLoopRef curRunLoop2 = CFRunLoopGetCurrent();
```

## 五 RunLoop 与线程

- 每条线程都有`唯一的一个`与之对应的`RunLoop`对象.
- `RunLoop`保存在一个全局的`Dictionary`里, 线程是 `key`. `RunLoop`是`Value`.
- 线程刚创建时并没有`RunLoop`对象,`RunLoop`会在第一次获取它时创建.
- `RunLoop`会在线程结束时销毁.
- 主线程的`RunLoop`已经自动获取(创建),子线程默认没有开启`RunLoop`.               

## 六 RunLoop 相关的类

`Core Foundation` 中关于 `RunLoop` 的5个类:

- `CFRunLoopRef`
- `CFRunLoopModeRef`
- `CFRunLoopSourceRef`
- `CFRunLoopTimerRef`
- `CFRunLoopObserverRef`

### CFRunLoopRef 底层

```C++
typedef struct __CFRunLoop *CFRunLoopRef;
struct __CFRunLoop {
    pthread_t _pthread;
    CFMutableSetRef _commonModes;
    CFMutableSetRef _commonModeItems;
    CFRunLoopModeRef _currentMode;
    CFMutableSetRef _modes;
};
```

### CFRunLoopModeRef 代表 RunLoop 的运行模式

```C++
typedef struct __CFRunLoopMode *CFRunLoopModeRef;
struct __CFRunLoopMode {
    CFStringRef _name;
    CFMutableSetRef _sources0;
    CFMutableSetRef _sources1;
    CFMutableArrayRef _observers;
    CFMutableArrayRef _timers;
};
```

一个`RunLoop`中有几种`mode`.而每个 `mode` 中都包含上面结构体中的元素.且其中`只有一个mode`可以成为`currentMode`. 

- `sources0`
- `sources1`
- `observers`
- `timers`
 
![](media/15406448910475/15406526801849.jpg)


`RunLoop`启动时只能选择其中一个`Mode`,作为`currentMode`.

如果需要切换`Mode`,只能退出当前`Loop`,再重新选择一个`Mode`进入.

- 不同组的 `sources0 / sources1 / Timer/ observers` 能分隔开来,互不影响.

如果`Mode`里没有任何 `sources0 / sources1 / Timer / observers`. `RunLoop`会立马退出.

#### 常见的两种 Mode

- `KCFRunLoopDefaultMode (NSDefaultRunLoopMode)`
    - App 的默认 `Mode`,通常主线程是在这个`Mode`下运行.
     
- `UITrackingRunLoopMode`
    - 界面跟踪 `Mode`, 用于 `scrollView` 追踪触摸滑动,保证界面滑动时不受其他 `Mode` 影响.

#### source0

1. `source0` 表示`触摸事件`的处理. 
2. `performSelector:onThread:`

执行 `touchesBegan:withEvent:` 方法.发现函数调用栈从1直接到13了.

![](media/15406448910475/15406538821007.jpg)

调试区域输入`bt`.得到所有调用函数

```lldb
(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
  * frame #0: 0x000000010df00704 RunLoopDemo1`-[ViewController touchesBegan:withEvent:](self=0x00007fd109601f50, _cmd="touchesBegan:withEvent:", touches=1 element, event=0x000060000303a520) at ViewController.m:23
    frame #1: 0x0000000111edcf01 UIKitCore`forwardTouchMethod + 353
    frame #2: 0x0000000111edcd8f UIKitCore`-[UIResponder touchesBegan:withEvent:] + 49
    frame #3: 0x000000011230b08f UIKitCore`-[UIWindow _sendTouchesForEvent:] + 2052
    frame #4: 0x000000011230ca30 UIKitCore`-[UIWindow sendEvent:] + 4080
    frame #5: 0x0000000111b12e10 UIKitCore`-[UIApplication sendEvent:] + 352
    frame #6: 0x0000000111a4b0d0 UIKitCore`__dispatchPreprocessedEventFromEventQueue + 3024
    frame #7: 0x0000000111a4dcf2 UIKitCore`__handleEventQueueInternal + 5948
    frame #8: 0x000000010f1e3b31 CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 17
    frame #9: 0x000000010f1e33a3 CoreFoundation`__CFRunLoopDoSources0 + 243
    frame #10: 0x000000010f1dda4f CoreFoundation`__CFRunLoopRun + 1263
    frame #11: 0x000000010f1dd221 CoreFoundation`CFRunLoopRunSpecific + 625
    frame #12: 0x00000001179351dd GraphicsServices`GSEventRunModal + 62
    frame #13: 0x0000000111af7115 UIKitCore`UIApplicationMain + 140
    frame #14: 0x000000010df007b0 RunLoopDemo1`main(argc=1, argv=0x00007ffee1cff020) at main.m:14
    frame #15: 0x0000000110be6551 libdyld.dylib`start + 1
```

发现这里有调用 `source0`.


#### source1

1. 基于 `Port` 的线程间通信
2. 系统事件捕捉

#### Timers

1. `NSTimer`
2. `performSelector:withObject:afterDelay`

#### Observers

1. 用来监听 `RunLoop`的状态
2. `UI`刷新(beforeWaiting 睡觉之前)
3. Autorelease pool (beforeWaiting 睡觉之前)


