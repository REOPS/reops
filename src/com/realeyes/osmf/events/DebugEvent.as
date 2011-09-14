package com.realeyes.osmf.events
{
	import flash.events.Event;
	
	public class DebugEvent extends Event
	{
		
		
		public static const DEBUG:String = "debug";
		
		public var message:String;
		
		public function DebugEvent(type:String, msg:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			message = msg;
		}
	}
}