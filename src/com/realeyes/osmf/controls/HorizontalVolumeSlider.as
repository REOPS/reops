package com.realeyes.osmf.controls
{
	import com.realeyes.osmf.controls.VolumeSlider;
	import com.realeyes.osmf.events.ControlBarEvent;
	
	import flash.media.SoundTransform;
	
	public class HorizontalVolumeSlider extends VolumeSlider
	{
		public var volscrubber:ToggleButton;
		
		public function HorizontalVolumeSlider()
		{
			super();
			
			_lowerBound = 0;
			_upperBound = width - value_mc.width;
			
			_activeRange = width - value_mc.width;
			
			this.visible = true;
			this.useHandCursor = this.buttonMode = true;
			
			if( volscrubber)
			{
				volscrubber.toggle = false;
				//SETS THE INITIAL VOLUME TO HALF TODO: Pull initial volume from mediaPlayer
				var halfVol:Number = int( _activeRange/2 ); 
				volscrubber.x = halfVol;
				value_mc.x = halfVol;
			}
			
		}
		
		override protected function _updateVolume():void
		{
			if( mouseX > _lowerBound && mouseX < _upperBound )
			{
				var pixelValue:Number = mouseX;
				var volumeValue:Number = int( ( pixelValue / _activeRange ) * 100 ) / 100;
				
				trace( "pixelValue: " + pixelValue + ", volumeValue: " + volumeValue + "valuemc X is " + value_mc.x + "valuemc width is " + value_mc.width );
				
				value_mc.x = pixelValue;
				
				if( volscrubber )
				{
					volscrubber.x = value_mc.x;
					trace("volscrubber x is " + volscrubber.x);
				}
				
				dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME, volumeValue, true ) );
			}
		}
	}
}