package com.azer.IOSAutoAdjust
{
	
	import flash.display.BitmapData;
	import flash.external.ExtensionContext;

	public class AutoAdjust
	{
		private static var _instance : AutoAdjust;
		private static var ext:ExtensionContext = null;
		
		public function AutoAdjust()
		{
			
			if (!_instance)
			{
				if(ext == null){
					ext = ExtensionContext.createExtensionContext("com.azer.iosautoadjust",null);
					
				}
				_instance = this;
			}
			
		}
		
		public static function getInstance() : AutoAdjust
		{
			return _instance ? _instance : new AutoAdjust();
		}
		
		public function CreateSigContext():void
		{
			ext.call( "CreateSigContext");
		}
		
		/**
		 * ios auto adjustment for image
		 * 
		 * @param inputImage for A CIImage object whose display name is Image. 
		 */
		public function DoAutoAdjust(inputImage:BitmapData):void
		{
			ext.call( "DoAutoAdjust",inputImage);
			
		}
		
	}
}