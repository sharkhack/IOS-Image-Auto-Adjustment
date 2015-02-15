//
//  AutoAdjustment.m
//  AutoAdjustment
//
//  Created by Azer Bulbul on 2/14/15.
//  Copyright (c) 2015 azer. All rights reserved.
//

#import "AutoAdjustment.h"


FREContext IOSAdjustCtx = nil;

@implementation AutoAdjustment

static AutoAdjustment *sharedInstance = nil;

@synthesize cicontext = _cicontext;

+ (AutoAdjustment *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [AutoAdjustment sharedInstance];
}

- (id)copy
{
    return self;
}

-(void)createSigContext
{
    
    _cicontext = [SingletonCIContext context];
}


-(void)onAutoAdjustWithArgv:(FREObject *)argv
{
    FREBitmapData  bitmapData;
    
    FREAcquireBitmapData(argv[0], &bitmapData);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef inputContextRef     = CGBitmapContextCreate (
                                                              bitmapData.bits32,
                                                              bitmapData.width,
                                                              bitmapData.height,
                                                              8,
                                                              bitmapData.lineStride32 * 4,
                                                              colorSpace,
                                                              kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little
                                                              );
    
    CGImageRef inputImageRef        = CGBitmapContextCreateImage(inputContextRef);
    CIImage *inputImage             = [CIImage imageWithCGImage: inputImageRef];
    
    
    NSDictionary* d = [[inputImage properties] valueForKey:(__bridge NSString *)kCGImagePropertyOrientation];
    NSArray *adjustments = [inputImage autoAdjustmentFiltersWithOptions:d];
    for (CIFilter *filter in adjustments) {
        [filter setValue:inputImage forKey:kCIInputImageKey];
        inputImage = filter.outputImage;
    }
    
    
    CGImageRef outRef = [_cicontext createCGImage:inputImage fromRect:inputImage.extent];
    
    CGContextRelease(inputContextRef);
    CGImageRelease(inputImageRef);
    
    
    
    NSUInteger width = CGImageGetWidth(outRef);
    NSUInteger height = CGImageGetHeight(outRef);
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context2 = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context2, CGRectMake(0, 0, width, height), outRef);
    CGContextRelease(context2);
    
    // Pixels are now it rawData in the format RGBA8888
    // Now loop over each pixel to write them into the AS3 BitmapData memory
    int x, y;
    // There may be extra pixels in each row due to the value of lineStride32.
    // We'll skip over those as needed.
    int offset = bitmapData.lineStride32 - bitmapData.width;
    int offset2 = (int)(bytesPerRow - bitmapData.width*4);
    int byteIndex = 0;
    uint32_t *bitmapDataPixels = bitmapData.bits32;
    for (y=0; y<bitmapData.height; y++)
    {
        for (x=0; x<bitmapData.width; x++, bitmapDataPixels++, byteIndex += 4)
        {
            // Values are currently in RGBA7777, so each color value is currently a separate number.
            int red     = (rawData[byteIndex]);
            int green   = (rawData[byteIndex + 1]);
            int blue    = (rawData[byteIndex + 2]);
            int alpha   = (rawData[byteIndex + 3]);
            
            // Combine values into ARGB32
            *bitmapDataPixels = (alpha << 24) | (red << 16) | (green << 8) | blue;
        }
        
        bitmapDataPixels += offset;
        byteIndex += offset2;
    }
    
    // Free the memory we allocated
    free(rawData);
    
    // Tell Flash which region of the BitmapData changes (all of it here)
    FREInvalidateBitmapDataRect(argv[0], 0, 0, bitmapData.width, bitmapData.height);
    
    // Release our control over the BitmapData
    FREReleaseBitmapData(argv[0]);
    
    CGImageRelease(outRef);
}


@end


DEFINE_ANE_FUNCTION(CreateSigContext)
{
    
    [[AutoAdjustment sharedInstance] createSigContext];
    return nil;
}

DEFINE_ANE_FUNCTION(DoAutoAdjust)
{
    
    [[AutoAdjustment sharedInstance] onAutoAdjustWithArgv:argv];
    return nil;
}

void AdjustContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                               uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    
    NSInteger nbFuntionsToLink = 2;
    *numFunctionsToTest = (uint32_t) nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "CreateSigContext";
    func[0].functionData = NULL;
    func[0].function = &CreateSigContext;
    
    func[1].name = (const uint8_t*) "DoAutoAdjust";
    func[1].functionData = NULL;
    func[1].function = &DoAutoAdjust;
    *functionsToSet = func;
    
    IOSAdjustCtx = ctx;
    
}

void AdjustContextFinalizer(FREContext ctx)
{
    IOSAdjustCtx = nil;
    return;
}

void AdjustExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                           FREContextFinalizer* ctxFinalizerToSet)
{
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AdjustContextInitializer;
    *ctxFinalizerToSet = &AdjustContextFinalizer;
}

void AdjustExtFinalizer(void* extData)
{
    return;
}
