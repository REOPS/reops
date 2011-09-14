package com.realeyes.osmf.controls
{
	import flash.display.Stage;
	import flash.events.Event;

	public class StageVideoIndicator extends SkinElementBase implements ISkinElementBase
	{
		public static const UNAVAILABLE:String = "unavailable";
		public static const AVAILABLE:String = "available";
		public static const RENDERED:String = "rendered";
		public static const DECODED:String = "decoded";
		public static const BOTH:String = "both";
		
		public static var instances:Vector.<StageVideoIndicator>;
		public static var currentStatus:String = "unavailable";;
		
		public function StageVideoIndicator()
		{
			super();
			
			
			if(!StageVideoIndicator.instances)
			{
				StageVideoIndicator.instances = new Vector.<StageVideoIndicator>();
			}
			
			StageVideoIndicator.instances.push( this );
			
			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );
			
			
		}
		
		
		public static function updateStatus( status:String, instance:StageVideoIndicator = null ):void
		{
			trace("SET CURRENT STATUS: " + status);
			currentStatus = status;
			for each( var indicator:StageVideoIndicator in instances )
			{
				if( instance )
				{
					if( instance == indicator )
					{
						instance.gotoAndPlay( status );
						return;
					}
				}
				else
				{
					indicator.gotoAndPlay( status );
				}
			}
		}
		
		////////////////////////////
		// EVENT LISTENERS
		////////////////////////////
		
		protected function onAddedToStage( event:Event ):void
		{
			//chek if currently available and listen to what we can otherwise to tell
			this.gotoAndPlay( StageVideoIndicator.currentStatus );
			trace("APPLYING CURRENT STATUS: " + StageVideoIndicator.currentStatus);
		}
		
		
	}
}