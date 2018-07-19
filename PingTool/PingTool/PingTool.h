//
//  PingTool.h
//  PingTool
//
//  Created by huangjian on 2018/7/19.
//  Copyright © 2018年 huangjian. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,PingStatus) {
    PingStartSuccess = 0,
    PingStartFail = 1,
    PingSendPacketSuccess = 2,
    PingSendPacketFail = 3,
    PingReceiveResponsePacketSuccess = 4,
    PingReceiveResponsePacketFail = 5,
    PingReceiveUnexpectedPacket = 6
};

@protocol PingToolDelegate <NSObject>
@optional
- (void) didPingWithStatus:(PingStatus)status delayTime:(NSInteger)delayTime withError:(NSError*) error;
@end
@interface PingTool : NSObject
@property (nonatomic,weak)id<PingToolDelegate> delegate;

-(instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;

-(void)startPing;
-(void)stopPing;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

@interface PingItem : NSObject
@property(nonatomic, assign) uint16_t sequenceNumber;

@property (nonatomic,strong)NSDate *sendDate;
@end
