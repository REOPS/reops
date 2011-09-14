package com.realeyes.osmf.events
{
	import flash.events.Event;
	
	/**
	 * Event class for dispatching toggle button clicks
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ToggleButtonEvent extends Event
	{
		
		public static const TOGGLE_BUTTON_CLICK:String = "toggleButtonClick";
		
		/**
		 * Is the toggle button selected?	(Boolean)
		 */
		public var selected:Boolean;
		
		/**
		 * Constructor
		 * @param	p_type			(String) the event type
		 * @param	p_selected		(Boolean) is the toggle button selected?
		 * @param	p_bubbles		(Boolean) does the event bubble? Defaults to false
		 * @param	p_cancelable	(Boolean) can the event be canceled? Defaults to false
		 * @return	ToggleButtonEvent
		 */
		public function ToggleButtonEvent( p_type:String, p_selected:Boolean, p_bubbles:Boolean=false, p_cancelable:Boolean=false)
		{
			super(p_type, p_bubbles, p_cancelable);
			
			selected = p_selected;
			
		}
	}
}