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
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViewArray;

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
    _imageView.image = [self imageCompressFitSizeScale:image targetSize:CGSizeMake(300, 300)];
    for (int i = 0; i < _imageViewArray.count; i ++) {
        int x = i % 3;
        int y = i / 3;
        UIImageView *imageview = _imageViewArray[i];
        imageview.image = [self cutImageWithImage:_imageView.image x:x y:y];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];;
}

// 图片变灰
- (UIImage *) convertToGreyscale:(UIImage *)i {
    
    int kRed = 1;
    int kGreen = 2;
    int kBlue = 4;
    
    int colors = kGreen | kBlue | kRed;
    int m_width = i.size.width;
    int m_height = i.size.height;
    
    uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGColorSpaceRef deviceGray = CGColorSpaceCreateDeviceGray();
    /*
     创建位图上下文。上下文绘制为“width”像素宽，“height”像素高的位图。每个像素的组件数由“空格”指定，也可以指定目标颜色配置文件。像素的每个分量的位数由`bitsPerComponent'指定。每像素的字节数等于“（bitsPerComponent *组件数+ 7）/ 8”。位图的每一行由“bytesPerRow”字节组成，每个像素必须至少为“width * bytes”;另外，“bytesPerRow”必须是每像素字节数的整数倍。 `data'，如果非NULL，则指向一个内存块至少`bytesPerRow * height'字节。如果“data”为NULL，则上下文的数据将自动分配，并在释放上下文时释放。 `bitmapInfo'指定位图是否应包含Alpha通道，以及它是如何生成的，以及组件是浮点还是整数
     
         CGBitmapContextCreate(void * _Nullable data, size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow, CGColorSpaceRef  _Nullable space, uint32_t bitmapInfo)
     */
    CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    //设置差值的质量
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    //抗锯齿
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [i CGImage]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    //malloc 获取内存空间
    // now convert to grayscale
    uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
    for(int y = 0; y < m_height; y++) {
        for(int x = 0; x < m_width; x++) {
            uint32_t rgbPixel=rgbImage[y*m_width+x];
            uint32_t sum=0,count=0;
            if (colors & kRed) {sum += (rgbPixel>>24)&255; count++;}
            if (colors & kGreen) {sum += (rgbPixel>>16)&255; count++;}
            if (colors & kBlue) {sum += (rgbPixel>>8)&255; count++;}
            m_imageData[y*m_width+x]=sum/count;
        }
    }
    free(rgbImage);
    
    // convert from a gray scale image back into a UIImage
    uint8_t *result = (uint8_t *) calloc(m_width * m_height *sizeof(uint32_t), 1);
    
    // process the image back to rgb
    for(int i = 0; i < m_height * m_width; i++) {
        result[i*4]=0;
        int val=m_imageData[i];
        result[i*4+1]=val;
        result[i*4+2]=val;
        result[i*4+3]=val;
    }
    
    // create a UIImage
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(result, m_width, m_height, 8, m_width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    
    free(m_imageData);
    
    // make sure the data will be released by giving it to an autoreleased NSData
    [NSData dataWithBytesNoCopy:result length:m_width * m_height];
    
    return resultUIImage;
}

- (UIImage *)maskImageWithImage:(UIImage *)image {
  /* mask 面罩 必须在DeviceGray 颜色空间中 必须没有alpha通道 并且本身可能不会被掩蔽或掩蔽颜色掩蔽，如果掩码与图像参数指定的图像大小不一样，则将掩码缩放以适应图像。
   
    image 要应用蒙版参数的图像。该图像不能是图像掩码，并且可能没有与其相关联的图像掩码或掩蔽颜色
   
    CGImageCreateWithMask(CGImageRef  _Nullable image, CGImageRef  _Nullable mask)
   
   所得到的图像取决于掩码参数是图像掩码还是图像。如果掩模参数是图像掩码，则图像掩码的源样本用作反α值。也就是说，如果图像掩码中的源样本的值为S，则使用（1-S）的α值将图像中的相应区域与目的地混合。例如，如果S为1，则区域不会被绘制，而如果S为0，则该区域将被完全绘制。
   如果mask参数是一个图像，那么它用作将图像混合到目的地的alpha掩码。掩模的源样本作为α值。如果掩码中的源样本的值为S，则将图像中的对应区域与S的S的目的地混合。例如，如果S为0，则该区域不被绘制，而如果S为1，该地区是完全画
   */
    
    
    UIImage *maskImage = [UIImage imageNamed:@"Mask"];
    CGImageRef cgImage = [image CGImage];
    CGImageRef  mask = maskImage.CGImage;
    CGImageRef maskCgImage = CGImageMaskCreate(CGImageGetWidth(mask),
                                               CGImageGetHeight(mask),
                                               CGImageGetBitsPerComponent(mask),
                                               CGImageGetBitsPerPixel(mask),
                                               CGImageGetBytesPerRow(mask),
                                               CGImageGetDataProvider(mask), NULL, false);
    CGImageRef imageWithAlpha = cgImage;
    // 判断image 是否 有 alpha
    if (CGImageGetAlphaInfo(cgImage) == kCGImageAlphaNone) {
    }
    CGImageRef sourceImage = CGImageCreateWithMask(imageWithAlpha, maskCgImage);
    UIImage *sourceIma = [UIImage imageWithCGImage:sourceImage];
    CGImageRelease(maskCgImage);
    CGImageRelease(sourceImage);
    return sourceIma;
}

- (UIImage*)maskImage:(UIImage*)originImage toPath:(UIBezierPath*)path{
    UIGraphicsBeginImageContextWithOptions(originImage.size, NO, 0);
    [path addClip];
    [originImage drawAtPoint:CGPointZero];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)cutImageWithImage:(UIImage *)image x:(NSInteger)x y:(NSInteger)y {
    /* 使用包含在“image”的subrectangle“rect”中的数据创建一个图像。创建新图像1）通过调用“CGRectIntegral”将“rect”调整为整数边界; 2）将结果与原点（0，0）和大小等于“image”大小的矩形相交; 3）引用所得矩形内的像素，将图像数据的第一像素视为图像的原点。如果生成的矩形为空矩形，则此函数返回NULL。如果W和H分别是图像的宽度和高度，则点（0,0）对应于图像数据的第一像素;点（W-1，0）是图像数据的第一行的最后一个像素; （0，H-1）是图像数据的最后一行的第一个像素;和（W-1，H-1）是图像数据的最后一行的最后一个像素。生成的图像保留对原始图像的引用，因此您可以在调用此功能后释放原始图像
     */
    NSInteger scale = [UIScreen mainScreen].scale;
//    int m_height = image.size.height;
    int m_width = image.size.width;
    CGImageRef refImage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(m_width / 3 * x, 300 / 3 * y, m_width / 3 , 300 / 3));
    image = [UIImage imageWithCGImage:refImage];
    CGImageRelease(refImage);
    return image;
}

//指定宽度按比例缩放
-(UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();  
    return newImage;  
}

- (UIImage *) imageCompressFitSizeScale:(UIImage *)sourceImage targetSize:(CGSize)size{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
            
        }
        else{
            
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}




@end
