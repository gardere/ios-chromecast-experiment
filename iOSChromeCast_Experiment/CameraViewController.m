//
//  CameraViewController.m
//  iOSChromeCast_Experiment
//
//  Created by Mathieu Gardere on 16/06/2015.
//  Copyright (c) 2015 Gardere.io. All rights reserved.
//

#import "CameraViewController.h"
#import "CamCaptureHttpServer.h"
#import "CamCaptureConnection.h"


@interface CameraViewController() {
    
}

@property (nonatomic, strong) AVCaptureSession* captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* videoPreviewLayer;
@property (nonatomic, strong) UIImage* currentImage;
@property (nonatomic, strong) CamCaptureHttpServer* httpServer;

@end

@implementation CameraViewController

-(void)viewDidAppear:(BOOL)animated {
    [self startCapturing];
    [self startWebServer];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self stopCapturing];
    [self stopWebServer];
}

-(void)startWebServer {
    NSError* error;
    
    self.httpServer = [[CamCaptureHttpServer alloc] init];
    [self.httpServer setConnectionClass:[CamCaptureConnection class]];
    [self.httpServer setType:@"_http._tcp."];
    [self.httpServer setPort:1234];
    [self.httpServer start:&error];
    
    if (error) {
        NSLog(@"Error starting web server: %@", [error description]);
    }
}

-(void)stopWebServer {
    if (self.httpServer) {
        [self.httpServer stop];
    }
}

-(void)stopCapturing {
    [_captureSession stopRunning];
    _captureSession = nil;
}


-(void)startCapturing {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
    
    NSDictionary *newSettings =
    @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    videoDataOutput.videoSettings = newSettings;
    
    // discard if the data output queue is blocked (as we process the still image)
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    [_captureSession addOutput:videoDataOutput];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    self.currentImage = [self imageFromSampleBuffer: sampleBuffer];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newImageCapture" object:self.currentImage];
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    NSLog(@"new image");
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}




@end
