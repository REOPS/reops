package com.realeyes.osmf.controls
{
	import com.realeyes.osmf.events.ToggleButtonEvent;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	/**
	 * Button for displaying a on/off state.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ToggleButton extends SkinElementBase
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		private var _enabled:Boolean = true;
		private var _selected:Boolean;
		private var _currentState:String;
		
		/**
		 * Does this button toggle?	(Boolean)
		 * @default	true
		 */
		public var toggle:Boolean = true;
		
		static public const UP:String = "up";
		static public const OVER:String = "over";
		static public const DOWN:String = "down";
		static public const DISABLED:String = "disabled";
		
		static public const UP_SELECTED:String = "selectedUp";
		static public const OVER_SELECTED:String = "selectedOver";
		static public const DOWN_SELECTED:String = "selectedDown";
		static public const DISABLED_SELECTED:String = "selectedDisabled";
		
		
		private var _anchor:String;//left/right
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		
		public function ToggleButton()
		{
			super();
			buttonMode = true;
			useHandCursor = true;
			_initListeners();
			_currentState = UP;
		}
		
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		
		/**
		 * Initialize listeners for mouse events
		 * 
		 * @return	void
		 */
		private function _initListeners():void
		{
			this.addEventListener( MouseEvent.MOUSE_OVER, _onMouseOver, false, 0, true );
			this.addEventListener( MouseEvent.MOUSE_DOWN, _onMouseDown, false, 0, true );
			//this.addEventListener( MouseEvent.MOUSE_UP, _onMouseOver, false, 0, true );
			this.addEventListener( MouseEvent.CLICK, _onMouseClick, false, 0, true );
			this.addEventListener( MouseEvent.MOUSE_OUT, _onMouseOut, false, 0, true );
			
		}
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		/**
		 * enabled
		 * Is the button enabled for use?
		 * @return	Boolean
		 */
		override public function get enabled():Boolean
		{
			
			return _enabled;
			
		}
		
		override public function set enabled( p_value:Boolean ):void
		{
			super.enabled = p_value;
			
			_enabled = p_value;
			
			if( !_enabled )
			{
				useHandCursor = false;
				buttonMode = false;
				currentState = DISABLED;
			}
			else
			{
				buttonMode = true;
				useHandCursor = true;
				currentState = UP;
			}
			
		}
		
		/**
		 * selected
		 * Is the button selected?
		 * @return	Boolean
		 */
		public function get selected():Boolean
		{
			
			return _selected;
			
		}
		
		public function set selected( p_value:Boolean ):void
		{
			
			_selected = p_value;
			
			currentState = _currentState;
			
		}
		
		
		/**
		 * currentState
		 * The current state of the button. The valid values are
		 * UP, OVER, DOWN, DISABLED, UP_SELECTED, OVER_SELECTED, 
		 * DOWN_SELECTED, and DISABLED_SELECTED.
		 * 
		 * @return	String
		 */  
		public function get currentState():String
		{
			if( _selected ) 
			{
				switch( _currentState )
				{
					case UP:
					{
						return UP_SELECTED;
						break;
					}
					case OVER:
					{
						return OVER_SELECTED;
						break;
					}
					case DOWN:
					{
						return DOWN_SELECTED;
						break;
					}
					case DISABLED:
					{
						return DISABLED_SELECTED;
						break;
					}
				}
			}
			
			return _currentState;
			
		}
		
		public function set currentState( p_value:String ):void
		{
			//trace("SELECTED: " + _selected + " || " + _currentState);
			
			
			_currentState = p_value;
			
			if( _selected )
			{
				
				switch( p_value )
				{
					case UP:
					{
						this.gotoAndPlay( UP_SELECTED );
						break;
					}
					case OVER:
					{
						this.gotoAndPlay( OVER_SELECTED );
						break;
					}
					case DOWN:
					{
						this.gotoAndPlay( DOWN_SELECTED );
						break;
					}
					case DISABLED:
					{
						this.gotoAndPlay( DISABLED_SELECTED );
						break;
					}
				}
			}
			else
			{
				//trace("frame label = " + this.currentFrameLabel)
				//trace("state = " + _currentState)
				
				this.gotoAndPlay( _currentState );
				
			}
			
			//trace(">frame label = " + this.currentFrameLabel)
		}
		
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		/**
		 * Show over state on mouse over
		 * 
		 * @param	p_evt	(MouseEvent) mouse over event
		 * @return	void
		 */
		private function _onMouseOver( p_evt:MouseEvent ):void
		{
			if( _enabled )
			{
				currentState = OVER;
			}
		}
		
		/**
		 * Show down state on mouse down
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onMouseDown( p_evt:MouseEvent ):void
		{
			if( _enabled )
			{
				currentState = DOWN;
			}
		}
		
		/**
		 * Show up state on mouse out
		 * 
		 * @param	p_evt	(MouseEvent) mouse out event
		 * @return	void
		 */
		private function _onMouseOut( p_evt:MouseEvent ):void
		{
			if( _enabled )
			{
				currentState = UP;
			}
		}
		
		
		/**
		 * Toggle the selected state of the button (if toggle is enabled), and
		 * show the over state. Also dispatches a ToggleButtonEvent.TOGGLE_BUTTON_CLICK
		 * event.
		 * 
		 * @see		ToggleButtonEvent
		 * @param	p_evt	(MouseEvent) mouse over event
		 * @return	void
		 */
		private function _onMouseClick( p_evt:MouseEvent ):void
		{
			if( _enabled )
			{
				_currentState = OVER;
				
				if( toggle )
				{
				
					if( selected )
					{
						selected = false;
					}
					else
					{
						selected = true;
					}
				
				}
				
				this.dispatchEvent( new ToggleButtonEvent( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, selected ) );
			}
		}
		
	}
}