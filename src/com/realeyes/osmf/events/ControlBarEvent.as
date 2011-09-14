package com.realeyes.osmf.events
{
	import flash.events.Event;
	
	/**
	 * Event for control bar interactions.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ControlBarEvent extends Event
	{
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause";
		public static const SEEK_PERCENT:String = "seekPercent";//Seek Percent
		public static const SEEK_TIME:String = "seekTime";
		public static const SEEK_TO_LIVE:String = "seekToLive";
		public static const STOP:String = "stop";
		public static const MUTE:String = "mute";
		public static const UNMUTE:String = "unmute";
		public static const VOLUME:String = "volume";
		public static const VOLUME_UP:String = "volumeUp";
		public static const VOLUME_DOWN:String = "volumeDown";
		public static const FULLSCREEN:String = "fullscreen";
		public static const FULLSCREEN_RETURN:String = "fullscreenReturn";
		public static const SHOW_CLOSEDCAPTION:String = "showClosedcaption";
		public static const HIDE_CLOSEDCAPTION:String = "hideClosedcaption";
		public static const BITRATE_UP:String = "bitrateUp";
		public static const BITRATE_DOWN:String = "bitrateDown";
		public static const CONTROL_BAR_VISIBILITY:String = "controlBarVisibility";
		public static const IS_LIVE:String = "IS_LIVE";
		public static const EXPAND:String = "expand";
		public static const RESTORE:String = "restore";
		public static const SWITCH_AUDIO:String = "switchAudio";
		/**
		 * The value for the data.	(Number)
		 * @default	0
		 */
		public var value:Number;
		
		
		
		/**
		 * Constructor
		 * @param	p_type			(String) the event type
		 * @param	p_volume		(Number) volume to use for a volume event. Defaults to 0.
		 * @param	p_seekPercent	(Number) percentage of the file to seek to for seek events. Defaults to 0.
		 * @param	p_bubbles		(Boolean) does the event bubble? Defaults to false
		 * @param	p_cancelable	(Boolean) can the event be canceled? Defaults to false
		 * @return	ControlBarEvent
		 */
		public function ControlBarEvent(	p_type:String,
											p_value:Number=0,
											p_bubbles:Boolean=false, 
											p_cancelable:Boolean=false )
		{
			super( p_type, p_bubbles, p_cancelable );
			
			this.value = p_value;
			
		}
		
		/**
		 * Clones the event
		 * 
		 * @return	Event
		 */
		override public function clone():Event
		{
			return new ControlBarEvent( type, value, bubbles, cancelable );
		}
	}
}