//
//  ViewController.m
//  TYThreadControl
//
//  Created by 马天野 on 2018/10/28.
//  Copyright © 2018 Maty. All rights reserved.
//

#import "ViewController.h"
#import "TYThread.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    TYThread *thread = [[TYThread alloc] initWithTarget:self selector:@selector(controlThread) object:nil];
    [thread start];
}

// 该方法作用: 保住线程 TYThread 的命.
- (void)controlThread {
    
    NSLog(@"%s == %@",__func__, [NSThread currentThread]);
    
    // 添加 Source, 防止 RunLoop 退出
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSRunLoopCommonModes];
    
    // 获取 RunLoop(获取就会创建好了)
    // 没有 source/Timer/Observer, RunLoop 会立马退出
    [[NSRunLoop currentRunLoop] run];
    
    NSLog(@"===== end =====");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   
    [self test];
    
}

#pragma mark - 处理事情的方法
- (void)test {
    NSLog(@"开始点击屏幕");
}


@end
