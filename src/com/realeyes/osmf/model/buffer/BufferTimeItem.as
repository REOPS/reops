package com.realeyes.osmf.model.buffer
{
	import flash.utils.getTimer;
	
	public class BufferTimeItem
	{
		public var videoTime:Number;
		public var bufferTime:Number;
		public var timeStamp:Number;
		
		public function BufferTimeItem( videoTime:Number, bufferTime:Number)
		{
			this.videoTime = videoTime;
			this.bufferTime = bufferTime;
			this.timeStamp = getTimer();
		}
		
		
	}
}
	
	