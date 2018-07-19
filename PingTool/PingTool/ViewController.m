//
//  ViewController.m
//  PingTool
//
//  Created by huangjian on 2018/7/19.
//  Copyright © 2018年 huangjian. All rights reserved.
//

#import "ViewController.h"
#import "PingTool.h"
@interface ViewController ()<PingToolDelegate>
@property (weak, nonatomic) IBOutlet UILabel *msLabel;
@property (nonatomic,strong)PingTool *pingTool;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PingTool *pingTool=[[PingTool alloc]initWithHost:@"www.baidu.com"];
    pingTool.delegate=self;
    [pingTool startPing];
    self.pingTool=pingTool;
}
-(void)didPingWithStatus:(PingStatus)status delayTime:(NSInteger)delayTime withError:(NSError *)error
{
    if (!error&&status==PingReceiveResponsePacketSuccess) {
        self.msLabel.text=[NSString stringWithFormat:@"%ld ms",delayTime];
    }else if(error)
    {
        if (status==PingReceiveResponsePacketFail) {
            self.msLabel.text=[NSString stringWithFormat:@"%ld ms",delayTime];
        }
    }
}
@end
