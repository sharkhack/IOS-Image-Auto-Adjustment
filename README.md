Air Native Extension For IOS Image Auto Adjustment
===============

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for using IOS Image Auto Adjustment on IOS. It has been developed by [Azer BULBUL](https://github.com/sharkhack).

This AIR Native Extension exposes Image Auto Adjustment to Adobe AIR.

- The ANE binary (IOSAutoAdjust.ane) is located in the */AS3/Lib/IOSAutoAdjust/release* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)).


- This ANE included [ios core imagage framework](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP40004346)

- You can also find out about the built-in filters on a system by using the Core Image API. See [Core Image Programming Guide](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html#//apple_ref/doc/uid/TP30001185)

```objective-c

	CIImage *inputImage             = [CIImage imageWithCGImage: inputImageRef];
    
    NSDictionary* d = [[inputImage properties] valueForKey:(__bridge NSString *)kCGImagePropertyOrientation];
    NSArray *adjustments = [inputImage autoAdjustmentFiltersWithOptions:d];
    for (CIFilter *filter in adjustments) {
        [filter setValue:inputImage forKey:kCIInputImageKey];
        inputImage = filter.outputImage;
    }

```

USAGE (*/AS3/Test/IOSAutoAdjustTest*)

```actionscript

package
{
	import com.azer.IOSAutoAdjust.AutoAdjust;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class IOSAutoAdjustTest extends Sprite
	{
		[Embed(source="lenaArea.jpg")]
		private var lena:Class;
		
		public function IOSAutoAdjustTest()
		{
			super();
			
			var bmp:Bitmap = Bitmap(new lena());
			
			AutoAdjust.getInstance().CreateSigContext();
			
			AutoAdjust.getInstance().DoAutoAdjust(bmp.bitmapData);
			
			this.addChild(bmp);
			
		}
	}
}


```

Authors
------

This ANE has been written by [Azer BULBUL](https://github.com/sharkhack) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

