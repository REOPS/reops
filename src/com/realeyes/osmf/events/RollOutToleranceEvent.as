package com.realeyes.osmf.events
{
	import flash.events.Event;

	/**
	 * Event used with RollOutTolerance
	 * 
	 * @author RealEyes
	 * @version 1.0
	 */
	public class RollOutToleranceEvent extends Event
	{
		/**
		 * static const - tolerance out event type
		 */ 
		public static const TOLERANCE_OUT:String = "toleranceOut";
		
		/**
		 * Constructor
		 *  
		 * @param type - event type
		 * @param bubbles - event bubbling flag
		 * @param cancelable - cancelable flag
		 * 
		 */		
		public function RollOutToleranceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new RollOutToleranceEvent( type, bubbles, cancelable );
		}
	}
}