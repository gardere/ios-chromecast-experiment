//
//  CameraViewController.h
//  iOSChromeCast_Experiment
//
//  Created by Mathieu Gardere on 16/06/2015.
//  Copyright (c) 2015 Gardere.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPreview;

@end
