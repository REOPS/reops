////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2009 RealEyes Media LLC.
//
////////////////////////////////////////////////////////////////////////////////
package com.realeyes.osmf.utils
{	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.MovieClip;
	import com.realeyes.osmf.events.RollOutToleranceEvent;
	import flash.geom.Point;
	
	/**
	 * RollOutTolerance applies a "tolerance zone" for roll out events.  It is not explicitly
	 * attached to roll out events, instead the start() method initiates the tolerance 
	 * behavior.
	 * 
	 * Usage:
	 * 
	 * public var rollOutTolerance:RollOutTolerance;
	 * rollOutTolerance = new RollOutTolerance( target, parentContainer, parentButton );
	 * rollOutTolerance.addEventListener( RollOutToleranceEvent.TOLERANCE_OUT, toleranceOut );
	 * rollOutTolerance.start();
	 * 
	 * @author Realeyes - Jamie
	 * @version 1.1
	 */	
	public class RollOutTolerance extends EventDispatcher
	{
		//-----------------------------------------------------------
		//DECLARATIONS
		//-----------------------------------------------------------			
		/**
		 * The target of the rollout tolerance behavior, usually a pop-up menu
		 */
		public var target:DisplayObject;
		/**
		 * The parent container of the target object for mouse position testing
		 */
		public var parentContainer:MovieClip;
		/**
		 * An optional button control that can be outside of the tolerance zone
		 */
		public var parentButton:DisplayObject;
		/**
		 * Tolerance variable: time
		 * 
		 * @default 1
		 */
		public var toleranceTime:Number = 1;
		/**
		 * Tolerance variables: delay
		 * 
		 * @default 30
		 */
		public var timerDelay:Number = 30;
		/**
		 * Tolerance variables: distance
		 * 
		 * @default 100
		 */
		public var toleranceDistance:Number = 100;
		/**
		 * Should exit be run when the mouse is is down outside
		 * of the target?
		 */
		public var exitOnMouseDownOutside:Boolean = true;
		/**
		 * Is the target a popup? Used when calculating global mouse point
		 */
		public var targetIsPopUp:Boolean = false;

		/**
		 * A timer for checking mouse position
		 */
		private var _toleranceTimer:Timer;
		/**
		 * The current mouse target
		 */
		private var _currentMouseTarget:Object;
		/**
		 * Is this RollOutTolerance object currently running?
		 */
		private var _running:Boolean = false;
		
		
		//-----------------------------------------------------------
		// INIT METHODS
		//-----------------------------------------------------------		
		/**
		 * Constructor
		 *  
		 * @param target				The target to which the rollout tolerance is applied
		 * @param parentButton			An optional parent button that may have opened/displayed the target.
		 * 								Included in the area calulcated by tolerance distance.
		 * @param toleranceTime			Used to calculate the timer interval
		 * @param timerDelay			How long it takes for tolerance out to be dispatched while the mouse
		 * 								is in the tolerance zone
 		 * @param toleranceDistance		The distance that determines the tolearance zone
		 * 
		 */		
		public function RollOutTolerance( 	target:DisplayObject, 
											parentButton:DisplayObject = null,
											toleranceTime:Number = 1,
											timerDelay:Number = 30,
											toleranceDistance:Number = 100 )
		{
			super();
			
			this.target = target;
			this.parentButton = parentButton;

			this.toleranceTime = toleranceTime
			this.timerDelay = timerDelay;
			this.toleranceDistance = toleranceDistance;
			
			//initialize timer
			_toleranceTimer = new Timer(timerDelay, (toleranceTime * 1000) / timerDelay );
			_toleranceTimer.addEventListener(TimerEvent.TIMER_COMPLETE, exit );
		}


		//-----------------------------------------------------------
		// CONTROL METHODS
		//-----------------------------------------------------------
		/**
		 * Stop and reset the timer
		 */
		public function reset():void
		{
			_toleranceTimer.stop();
			_toleranceTimer.reset();
		}
		
		/**
		 * Attach listeners to initiate tolerance behavior
		 */
		public function start():void
		{
			reset();
			
			if( target && target.stage )
			{
				// listen to stage level mouse events for tracking mouse targets
				target.stage.addEventListener( MouseEvent.MOUSE_MOVE, _onAppMouseMove );
				target.stage.addEventListener( MouseEvent.MOUSE_DOWN, _onAppMouseDown );			
				// reset running var
				_running = true;
			}

		}
		
		/**
		 * Remove listeners to stop RollOutTolerance behavior
		 */
		public function stop():void
		{
			//trace("STOP NOW!");
			
			reset();
			
			if( target && target.stage )
			{
				target.stage.removeEventListener( MouseEvent.MOUSE_MOVE, _onAppMouseMove );
				target.stage.removeEventListener( MouseEvent.MOUSE_DOWN, _onAppMouseDown );
			
				// reset running var
				_running = false;
			}
		}
		
		/**
		 * The mouse has left the tolerance zone, or the timer has completed
		 * dispatch an exit event
		 * 
		 * @param event - the event being handled (optional)
		 */
		public function exit( event:Event = null ):void
		{
			reset();
			
			dispatchEvent( new RollOutToleranceEvent( RollOutToleranceEvent.TOLERANCE_OUT, true, true ) );
		}
		
		/**
		 * Test to see if the mouse is within the target
		 * 
		 * @return True if within, else false
		 */
		private function _mouseIsWithinTarget():Boolean
		{
			if( target )
			{	
				if( target.mouseX > 0 && 
					target.mouseY > 0 &&
					target.mouseX < target.width && 
					target.mouseY < target.height )
					
				{
					//trace("WITHIN TARGET");
					return true;
				}
			}
			//trace("OUTSIDE TARGET");
			return false;
		}
		
		/**
		 * Test to see if the mouse is within the parent button
		 * 
		 * @return True if it is, else false
		 */
		private function _mouseIsWithinParentButton():Boolean
		{
			if( parentButton ) //if there is a parent button check to see if the mouse is over it
			{
				if( parentButton.mouseX > 0 && 
					parentButton.mouseY > 0 &&
					parentButton.mouseX < parentButton.width && 
					parentButton.mouseY < parentButton.height )
					
				{
					//trace("WITHIN PARENT BUTTON");
					return true;
				}
			}
			//trace("OUTSIDE PARENT BUTTON");
			return false;
		}
		
		/**
		 * Test to see if the mouse is within the tolerance zone
		 * 
		 * @return True if it is, else false
		 */
		private function _mouseIsWithinToleranceZone():Boolean
		{
			if( target )
			{
				
				if( target.mouseX > toleranceDistance * -1 && 
					target.mouseY > toleranceDistance * -1 &&
					target.mouseX < target.width + toleranceDistance && 
					target.mouseY < target.height + toleranceDistance )
					
				{
					//trace("WITHIN TOLERANCE ZONE");
					return true;
				}
			}
			//trace("OUTSIDE TOLERANCE ZONE");
			return false;
		}


		//-----------------------------------------------------------
		// EVENT HANDLERS
		//-----------------------------------------------------------		
		/**
		 * @private Capture mouseMove from the Application to test mouse position
		 */
		private function _onAppMouseMove( event:MouseEvent ):void
		{
			if( _mouseIsWithinParentButton() || _mouseIsWithinTarget() ) // if within target reset timer
			{
				reset();
				
				return;
			}
			else if ( _mouseIsWithinToleranceZone() ) // if within zone start timer
			{
				if( !_toleranceTimer.running )
				{
					reset();
					_toleranceTimer.start();
				}
				
				return;
			}
			else // if outside zone exit
			{
				exit(); 
			}		
		}
		
		/**
		 * Capture mouseDown from the application so that exit can be called
		 * on mouse down outside
		 */
		private function _onAppMouseDown( event:MouseEvent ):void
		{
			if( !_mouseIsWithinTarget() && !_mouseIsWithinParentButton() && exitOnMouseDownOutside )
			{
				exit();
			}
		}


		//-----------------------------------------------------------
		// GETTER/SETTERS
		//-----------------------------------------------------------	
		/**
		 * GETTER ONLY - Whether or not the timer is running
		 */
		public function get running():Boolean
		{
			return _running;
		}
	}
}