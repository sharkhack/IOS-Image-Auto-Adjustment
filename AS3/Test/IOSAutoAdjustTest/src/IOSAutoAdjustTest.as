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