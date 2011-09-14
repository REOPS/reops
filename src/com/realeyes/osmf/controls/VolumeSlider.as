package com.realeyes.osmf.controls
{
	import com.realeyes.osmf.events.ControlBarEvent;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	
	/**
	 * Slider for control bar to control volume.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class VolumeSlider extends MovieClip
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		public var value_mc:MovieClip;
		
		protected var _direction:String;
		
		protected var _upperBound:Number;
		protected var _lowerBound:Number;
		protected var _activeRange:Number;
		
		private var _mouseDown:Boolean = false;
		
		public static const VERTICAL:String = "vertical";
		public static const HORIZONTAL:String = "horizontal";
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function VolumeSlider()
		{
			trace( "INIT -- VolumeSlider" );
			
			super();
			
			value_mc.mouseEnabled = false;
			
			this.trackAsMenu = true;	
			this.useHandCursor = true;
			
			stop();

			//DEFAULT VERTICAL
			direction = VERTICAL;
			
			_initListeners();
		}
		
		
		
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		/**
		 * Initializes listening for mouse events
		 * 
		 * @return	void
		 */
		private function _initListeners():void
		{
			
			addEventListener( MouseEvent.MOUSE_DOWN, _onMouseDown );
			addEventListener( MouseEvent.MOUSE_UP, _onMouseUp );
			addEventListener( MouseEvent.MOUSE_MOVE, _onMouseMove );
		}
		
		/**
		 * Adjusts the volume based on slider position. Dispatches a
		 * ControlBarEvent.VOLUME event.
		 * 
		 * @see		ControlBarEvent
		 * @return	void
		 */
		protected function _updateVolume():void
		{
			var mousePosition:Number = _direction == VERTICAL ? mouseY : mouseX;
			//trace("update volume: " + mousePosition + ", " + _upperBound + ", " + _lowerBound);
			
			var pixelValue:Number;
			var volumeValue:Number;
			
			if( _direction == VERTICAL )
			{
				if( mousePosition > _upperBound - 1 && mousePosition < _activeRange + _upperBound )
				{
					pixelValue = height - mousePosition - _lowerBound;
					volumeValue = pixelValue / _activeRange;
					
					//trace( "pixelValue: " + pixelValue + ", volumeValue: " + volumeValue );
					
					value_mc.height = pixelValue;
					dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME, volumeValue, true ) );
				}
			}
			else
			{
			
				if( mousePosition < _upperBound && mousePosition > _lowerBound + 1 )
				{
					pixelValue = mousePosition - _lowerBound;
					volumeValue = pixelValue / _activeRange;
					//trace("volumeValue: " + volumeValue);
					if( _direction == VERTICAL )
					{
						value_mc.height = pixelValue;
					}
					else
					{
						value_mc.width = mousePosition - _lowerBound;
					}
					dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME, volumeValue, true ) );
				}
			}
			
		}
		
		/**
		 * While dragging, stops the updating of the volume
		 * 
		 * @return	void
		 */
		private function _stopUpdatingVolume():void
		{
			_mouseDown = false;
		}
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		
		
		public function get direction():String
		{
			return _direction;
		}
		
		public function set direction(value:String):void
		{
			_direction = value;
			
			if( _direction == VERTICAL )
			{
				_activeRange = value_mc.height;
				_lowerBound = height - value_mc.y;
				_upperBound = height - value_mc.height - _lowerBound;
			}
			else
			{
				_activeRange = value_mc.width;
				_lowerBound = value_mc.x;
				_upperBound = _lowerBound + _activeRange;
			}
			
			
			
			
		}
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		/**
		 * Start updating the volume while dragging
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onMouseDown( p_evt:MouseEvent ):void
		{
			_updateVolume();
			
			_mouseDown = true;
			stage.addEventListener( MouseEvent.MOUSE_UP, _onStageMouseUp );
		}
		
		/**
		 * Stop update the volume when released
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onMouseUp( p_evt:MouseEvent ):void
		{
			_stopUpdatingVolume();
		}
		
		/**
		 * Update the volume while dragging
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onMouseMove( p_evt:MouseEvent ):void
		{
			if( _mouseDown )
			{
				_updateVolume();
			}
		}
		
		/**
		 * When the mouse is released outside of the slider, stop
		 * updating the volume.
		 *
		 * @param	p_evt	(MouseEvent)
		 * @return	void
		 */ 
		private function _onStageMouseUp( p_evt:MouseEvent ):void
		{
			if( stage )
			{
				stage.removeEventListener( MouseEvent.MOUSE_UP, _onStageMouseUp );
			}
			_stopUpdatingVolume();
		}
	}
}