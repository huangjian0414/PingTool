//
//  PingTool.m
//  PingTool
//
//  Created by huangjian on 2018/7/19.
//  Copyright © 2018年 huangjian. All rights reserved.
//

#import "PingTool.h"
#import "SimplePing.h"
@interface PingTool ()<SimplePingDelegate>
@property (nonatomic,strong)NSTimer *timer;
@property(nonatomic, strong) SimplePing* simplePing;
@property (nonatomic,strong)NSMutableArray<PingItem *>* itemArray;
@end
@implementation PingTool
-(NSMutableArray<PingItem *> *)itemArray
{
    if (!_itemArray) {
        _itemArray=[NSMutableArray array];
    }
    return _itemArray;
}
-(instancetype)initWithHost:(NSString *)host
{
    if (self=[super init]) {
        self.simplePing=[[SimplePing alloc]initWithHostName:host];
        self.simplePing.delegate=self;
        self.simplePing.addressStyle=SimplePingAddressStyleAny;
    }
    return self;
}
-(void)startPing
{
    [self.simplePing start];
}
-(void)stopPing
{
    [self removeTimer];
    [self.simplePing stop];
}
-(void)sendPing
{
    [self.simplePing sendPingWithData:nil];
}
#pragma mark - Ping Delegate
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    NSLog(@"pingStart成功------");
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didPingWithStatus:delayTime:withError:)]) {
        [self.delegate didPingWithStatus:PingStartSuccess delayTime:0 withError:nil];
    }
    [self startTimer];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    NSLog(@"pingStart失败------%@", error);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didPingWithStatus:delayTime:withError:)]) {
        [self.delegate didPingWithStatus:PingStartFail delayTime:0 withError:error];
    }
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    NSLog(@"发包成功---%hu",sequenceNumber);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didPingWithStatus:delayTime:withError:)]) {
        [self.delegate didPingWithStatus:PingSendPacketSuccess delayTime:0 withError:nil];
    }
    PingItem *pingItem=[[PingItem alloc]init];
    pingItem.sequenceNumber=sequenceNumber;
    pingItem.sendDate=[NSDate date];
    [self.itemArray addObject:pingItem];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.itemArray containsObject:pingItem]) {
            NSLog(@"超时------%hu",pingItem.sequenceNumber);
            [self.itemArray removeObject:pingItem];
            if (self.delegate&&[self.delegate respondsToSelector:@selector(didPingWithStatus:delayTime:withError:)]) {
                [self.delegate didPingWithStatus:PingReceiveResponsePacketFail delayTime:999 withError:[NSError errorWithDomain:@"Response TimeOut" code:10003 userInfo:@{NSLocalizedDescriptionKey:@"timeout"}]];
            }
        }
    });
    
}
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    NSLog(@"发包失败---%@", error);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didPingWithStatus:delayTime:withError:)]) {
        [self.delegate didPingWithStatus:PingSendPacketFail delayTime:0 withError:error];
    }
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    NSLog(@"收到数据%hu",sequenceNumber);
    [self.itemArray enumerateObjectsUsingBlock:^(PingItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.sequenceNumber == sequenceNumber) {
            NSInteger delayTime = [[NSDate date]timeIntervalSinceDate:obj.sendDate] * 1000;
            [self.itemArray removeObject:obj];
            if (self.delegate&&[self.delegate respondsToSelector:@selector(didPingWithStatus:delayTime:withError:)]) {
                [self.delegate didPingWithStatus:PingReceiveResponsePacketSuccess delayTime:delayTime withError:nil];
            }
        }
    }];
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    NSLog(@"收到未知数据");
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didPingWithStatus:delayTime:withError:)]) {
        [self.delegate didPingWithStatus:PingReceiveUnexpectedPacket delayTime:0 withError:nil];
    }
}
#pragma mark - TIMER

-(NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        
    }
    return _timer;
}

-(void)removeTimer {
    if (_timer) {
        [_timer invalidate];
        _timer=nil;
    }
}

-(void)startTimer {
    [self.timer setFireDate:[NSDate distantPast]];
}
@end

@implementation PingItem

@end
