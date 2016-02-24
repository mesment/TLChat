//
//  TLScanerViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/2/24.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLScanerViewController.h"
#import <AVFoundation/AVFoundation.h>

static const float kLineMinY = 185;
static const float kLineMaxY = 385;
static const float kReaderViewWidth = 200;
static const float kReaderViewHeight = 200;

@interface TLScanerViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UILabel *introudctionLabel;
@property (nonatomic, strong) UIView *scannerView;
@property (nonatomic, strong) UIImageView *scannerLine;

@property (nonatomic, strong) UIView *bgTopView;
@property (nonatomic, strong) UIView *bgBtmView;
@property (nonatomic, strong) UIView *bgLeftView;
@property (nonatomic, strong) UIView *bgRightView;

@property (nonatomic, strong) AVCaptureSession *scannerSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic, strong) NSTimer *lineTimer;

@end

@implementation TLScanerViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"二维码/条码"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.bgTopView];
    [self.view addSubview:self.bgLeftView];
    [self.view addSubview:self.bgRightView];
    [self.view addSubview:self.bgBtmView];
    
    [self.view addSubview:self.introudctionLabel];
    [self.view addSubview:self.scannerView];
    [self.scannerView addSubview:self.scannerLine];
    [self.view.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    
    [self.introudctionLabel setText:@"将二维码/条码放入框内，即可自动扫描"];
    
    [self p_addMasonry];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.scannerSession == nil) {
        [UIAlertView alertWithCallBackBlock:^(NSInteger buttonIndex) {
//            [self.navigationController popViewControllerAnimated:YES];
        } title:@"错误" message:@"相机初始化失败" cancelButtonName:@"确定" otherButtonTitles: nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self p_startCodeReading];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.scannerSession isRunning]) {
        [self p_stopCodeReading];
    }
    if ([self.lineTimer isValid]) {
        [self.lineTimer invalidate];
    }
}

- (CGRect)getReaderViewBoundsWithSize:(CGSize)asize
{
    return CGRectMake(kLineMinY / HEIGHT_SCREEN, ((WIDTH_SCREEN - asize.width) / 2.0) / WIDTH_SCREEN, asize.height / HEIGHT_SCREEN, asize.width / WIDTH_SCREEN);
}

#pragma mark - Delegate -
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        [self p_stopCodeReading];
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        if (self.SYQRCodeSuncessBlock) {
            self.SYQRCodeSuncessBlock(self, obj.stringValue);
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:obj.stringValue delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    else {
        if (self.SYQRCodeFailBlock) {
            self.SYQRCodeFailBlock(self);
        }
    }
}

#pragma mark - Event Response -
- (void)updateScannerLineStatus
{
    if (self.scannerLine.y + self.scannerLine.height >= self.scannerView.height) {
        self.scannerLine.y = 0;
    }
    else {
        self.scannerLine.y ++;
    }
}

#pragma mark - Private Methods -
- (void)p_startCodeReading
{
    if ([_lineTimer isValid]) {
        [_lineTimer invalidate];
    }
    _lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60 target:self selector:@selector(updateScannerLineStatus) userInfo:nil repeats:YES];
    [self.scannerSession startRunning];
}

- (void)p_stopCodeReading
{
    if (_lineTimer) {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
    [self.scannerSession stopRunning];
}

- (void)p_addMasonry
{
    [self.scannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.centerY.mas_equalTo(self.view).mas_offset(-60);
        make.width.and.height.mas_equalTo(200);
    }];
    [self.bgTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.scannerView.mas_top);
    }];
    [self.bgBtmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.scannerView.mas_bottom);
    }];
    [self.bgLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.scannerView.mas_left);
        make.top.mas_equalTo(self.bgTopView.mas_bottom);
        make.bottom.mas_equalTo(self.bgBtmView.mas_top);
    }];
    [self.bgRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.scannerView.mas_right);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.bgTopView.mas_bottom);
        make.bottom.mas_equalTo(self.bgBtmView.mas_top);
    }];
    
    [self.introudctionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.width.mas_equalTo(self.view);
        make.top.mas_equalTo(self.scannerView.mas_bottom).mas_offset(30);
    }];
    
    [self.scannerLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.mas_equalTo(self.scannerView);
        make.top.mas_equalTo(self.scannerView);
    }];
    
    UIImageView *topLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanner_top_left"]];
    [self.view addSubview:topLeftView];
    [topLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.mas_equalTo(_scannerView);
    }];
    UIImageView *topRightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanner_top_right"]];
    [self.view addSubview:topRightView];
    [topRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.mas_equalTo(_scannerView);
    }];
    UIImageView *btmLeftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanner_bottom_left"]];
    [self.view addSubview:btmLeftView];
    [btmLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.mas_equalTo(_scannerView);
    }];
    UIImageView *btmRightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanner_bottom_right"]];
    [self.view addSubview:btmRightView];
    [btmRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.mas_equalTo(_scannerView);
    }];
}

#pragma mark - Getter -
- (AVCaptureSession *)scannerSession
{
    if (_scannerSession == nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (error) {    // 没有摄像头
            return nil;
        }

        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [output setRectOfInterest:[self getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)]];

        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [session setSessionPreset:AVCaptureSessionPreset1920x1080];
        }
        else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [session setSessionPreset:AVCaptureSessionPreset1280x720];
        }
        else {
            [session setSessionPreset:AVCaptureSessionPresetPhoto];
        }
        
        if ([session canAddInput:input]) {
            [session addInput:input];
        }
        if ([session canAddOutput:output]) {
            [session addOutput:output];
        }
        [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        
        _scannerSession = session;
    }
    return _scannerSession;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer
{
    if (_videoPreviewLayer == nil) {
        _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.scannerSession];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_videoPreviewLayer setFrame:self.view.layer.bounds];
    }
    return _videoPreviewLayer;
}

- (UILabel *)introudctionLabel
{
    if (_introudctionLabel == nil) {
        _introudctionLabel = [[UILabel alloc] init];
        [_introudctionLabel setBackgroundColor:[UIColor clearColor]];
        [_introudctionLabel setTextAlignment:NSTextAlignmentCenter];
        [_introudctionLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_introudctionLabel setTextColor:[UIColor whiteColor]];
    }
    return _introudctionLabel;
}

- (UIImageView *)scannerLine
{
    if (_scannerLine == nil) {
        _scannerLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanner_line"]];
    }
    return _scannerLine;
}

- (UIView *)scannerView
{
    if (_scannerView == nil) {
        _scannerView = [[UIView alloc] init];
        [_scannerView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_scannerView.layer setBorderWidth:0.5f];
    }
    return _scannerView;
}

- (UIView *)bgTopView
{
    if (_bgTopView == nil) {
        _bgTopView = [[UIView alloc] init];
        [_bgTopView setBackgroundColor:[UIColor blackColor]];
        [_bgTopView setAlpha:0.5];
    }
    return _bgTopView;
}

- (UIView *)bgBtmView
{
    if (_bgBtmView == nil) {
        _bgBtmView = [[UIView alloc] init];
        [_bgBtmView setBackgroundColor:[UIColor blackColor]];
        [_bgBtmView setAlpha:0.5];
    }
    return _bgBtmView;
}

- (UIView *)bgLeftView
{
    if (_bgLeftView == nil) {
        _bgLeftView = [[UIView alloc] init];
        [_bgLeftView setBackgroundColor:[UIColor blackColor]];
        [_bgLeftView setAlpha:0.5];
    }
    return _bgLeftView;
}

- (UIView *)bgRightView
{
    if (_bgRightView == nil) {
        _bgRightView = [[UIView alloc] init];
        [_bgRightView setBackgroundColor:[UIColor blackColor]];
        [_bgRightView setAlpha:0.5];
    }
    return _bgRightView;
}

@end