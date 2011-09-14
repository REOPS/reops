package com.realeyes.osmf.controls
{
	import com.realeyes.osmf.controls.ControlBar;
	import com.realeyes.osmf.controls.ToggleButton;
	import com.realeyes.osmf.events.ControlBarEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class CloseControlBar extends ControlBar
	{
		public var close_mc:ToggleButton;
		public function CloseControlBar()
		{
			super();
			close_mc.addEventListener( MouseEvent.CLICK, _onClose );
			_addControlItem( close_mc );
		}
		
		
		private function _onClose( event:Event ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.STOP ) );
			setLoadBarPercent(0);
			container.dispatchEvent( new Event("closeMedia") );
		}
	}
}