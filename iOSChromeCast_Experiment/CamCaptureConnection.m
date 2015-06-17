//
//  CamCaptureConnection.m
//  iOSChromeCast_Experiment
//
//  Created by Mathieu Gardere on 17/06/2015.
//  Copyright (c) 2015 Gardere.io. All rights reserved.
//

#import "CamCaptureConnection.h"
#import "HTTPDataResponse.h"
#import "CamCaptureHTTPServer.h"

@implementation CamCaptureConnection

-(NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    NSArray* pathComponents = [path componentsSeparatedByString:@"/"];
    
    if ([pathComponents count] < 2) {
        return [[HTTPDataResponse alloc] initWithData:[@"ERROR" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSString *command = [pathComponents objectAtIndex:1];
    
    if ([command isEqualToString:@"PING"]) {
        return [[HTTPDataResponse alloc] initWithData:[@"PONG" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    if ([command isEqualToString:@"PIC"]) {
        NSData *imageData = UIImageJPEGRepresentation([CamCaptureHttpServer instance].captureImage, 0.3);
        
        if (imageData) {
            return [[HTTPDataResponse alloc] initWithData:imageData];
        } else {
            return [[HTTPDataResponse alloc] initWithData:[@"NO_IMAGE" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }

    return [[HTTPDataResponse alloc] initWithData:[@"ERROR_UNKNOWN_COMMAND" dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
