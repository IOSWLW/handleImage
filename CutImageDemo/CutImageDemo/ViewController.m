//
//  ViewController.m
//  CutImageDemo
//
//  Created by LiweiWang on 2017/9/7.
//  Copyright © 2017年 LiweiWang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openPhotoAlbum:(id)sender {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择相册" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [sheet addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSUInteger type = UIImagePickerControllerSourceTypePhotoLibrary;
        [self showImagePickVCWithType:type];
        
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSUInteger type = UIImagePickerControllerSourceTypeCamera;
        if ([self isCameraAvailable]) {
            [self showImagePickVCWithType:type];
        }
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:sheet animated:YES completion:nil];
}

- (BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

//- (BOOL) isFrontCameraAvailable{
//    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
//}
//
//- (BOOL) isRearCameraAvailable{
//    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
//}

- (void)showImagePickVCWithType:(NSInteger )type {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = type;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _imageView.image = [self cutImageWithImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];;
}

- (UIImage *)cutImageWithImage:(UIImage *)image {
    UIImage *maskImage = [UIImage imageNamed:@"Mask1"];
    CGImageRef cgImage = [image CGImage];
    CGImageRef  mask = maskImage.CGImage;
    CGImageRef maskCgImage = CGImageMaskCreate(CGImageGetWidth(mask),
                                               CGImageGetHeight(mask),
                                               CGImageGetBitsPerComponent(mask),
                                               CGImageGetBitsPerPixel(mask),
                                               CGImageGetBytesPerRow(mask),
                                               CGImageGetDataProvider(mask), NULL, false);
    CGImageRef imageWithAlpha = cgImage;
    if (CGImageGetAlphaInfo(cgImage) == kCGImageAlphaNone) {
    }
    CGImageRef sourceImage = CGImageCreateWithMask(maskCgImage, imageWithAlpha);
    CGImageRelease(maskCgImage);
    return [UIImage imageWithCGImage:sourceImage];
}

+(UIImage*)maskImage:(UIImage*)originImage toPath:(UIBezierPath*)path{
    UIGraphicsBeginImageContextWithOptions(originImage.size, NO, 0);
    [path addClip];
    [originImage drawAtPoint:CGPointZero];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
