//
//  CamCaptureHttpServer.m
//  iOSChromeCast_Experiment
//
//  Created by Mathieu Gardere on 17/06/2015.
//  Copyright (c) 2015 Gardere.io. All rights reserved.
//

#import "CamCaptureHttpServer.h"

@implementation CamCaptureHttpServer

static CamCaptureHttpServer* _instance;

-(instancetype)init {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newImageCapture:) name:@"newImageCapture" object:nil];
    
    _instance = [super init];
    return _instance;
}

+(CamCaptureHttpServer *)instance {
    return _instance;
}

-(void)newImageCapture:(NSNotification*)notification {
    self.captureImage = notification.object;
}

@end
