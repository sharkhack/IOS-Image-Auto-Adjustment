//
//  AutoAdjustment.h
//  AutoAdjustment
//
//  Created by Azer Bulbul on 2/14/15.
//  Copyright (c) 2015 azer. All rights reserved.
//

#ifdef __OBJC__
#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
#endif

#import "FlashRuntimeExtensions.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import "SingletonCIContext.h"

@interface AutoAdjustment : NSObject
+ (AutoAdjustment *)sharedInstance;

@property (nonatomic, readonly) CIContext *cicontext;

-(void)createSigContext;

-(void)onAutoAdjustWithArgv:(FREObject*)argv;

@end


DEFINE_ANE_FUNCTION(CreateSigContext);
DEFINE_ANE_FUNCTION(DoAutoAdjust);


void AdjustContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                               uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

void AdjustContextFinalizer(FREContext ctx);

void AdjustExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                           FREContextFinalizer* ctxFinalizerToSet);

void AdjustExtFinalizer(void* extData);