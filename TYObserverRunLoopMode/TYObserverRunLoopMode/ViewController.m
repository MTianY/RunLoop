//
//  ViewController.m
//  TYObserverRunLoopMode
//
//  Created by 马天野 on 2018/10/28.
//  Copyright © 2018 Maty. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    /**
     观察者

    allocator#> 为新对象分配内存的分配器, 传 NULL 或 kCFAllocatorDefault description#>
    activities#> 标识运行循环的活动阶段的标志集，在此期间调用观察者 description#>
    repeats#> 观察者是否循环调用 description#>
    order#> 运行循环观察器的处理顺序 description#>
    observer  RunLoop 中的观察者
    activity RunLoop 当前状态
    return 观察者
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        
        
        
        switch (activity) {
                
            case kCFRunLoopEntry: {
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                CFRelease(mode);
                NSLog(@"即将进入 RunLoop --%@",mode);
            }
                
                break;
                
//            case kCFRunLoopBeforeTimers: {
//                NSLog(@"即将处理 Timer");
//            }
//
//                break;
//
//            case kCFRunLoopBeforeSources: {
//                NSLog(@"即将处理 Source");
//            }
//
//                break;
//
//            case kCFRunLoopBeforeWaiting: {
//                NSLog(@"即将进入休眠");
//            }
//
//                break;
//
//            case kCFRunLoopAfterWaiting: {
//                NSLog(@"刚从休眠中唤醒");
//            }
//
//                break;
                
            case kCFRunLoopExit: {
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                CFRelease(mode);
                NSLog(@"退出 RunLoop---%@",mode);
            }
                
                break;
                
                
                
            default:
                break;
        }
        
    });
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s",__func__);
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"点击定时器--%s",__func__);
    }];
    
    
    
}




@end
