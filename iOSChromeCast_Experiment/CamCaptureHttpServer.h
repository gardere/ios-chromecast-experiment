//
//  CamCaptureHttpServer.h
//  iOSChromeCast_Experiment
//
//  Created by Mathieu Gardere on 17/06/2015.
//  Copyright (c) 2015 Gardere.io. All rights reserved.
//

#import "HTTPServer.h"
#import <UIKit/UIKit.h>

@interface CamCaptureHttpServer : HTTPServer

@property (nonatomic, weak) UIImage* captureImage;

+(CamCaptureHttpServer*)instance;

@end
