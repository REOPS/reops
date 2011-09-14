package com.realeyes.osmf.model.buffer
{
	////////////////////////////////////////////////////////////////////////////////
	//
	//  Copyright (C) 2009 RealEyes Media LLC.
	//
	////////////////////////////////////////////////////////////////////////////////

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class BufferManagerModel extends EventDispatcher
	{
		//-----------------------------------------------------------
		// CONSTRUCTOR
		//-----------------------------------------------------------
		public function BufferManagerModel( target:IEventDispatcher=null ) {}
		
		
		//-----------------------------------------------------------
		// PROPERTY DECLARATIONS
		//-----------------------------------------------------------
		private var _calcStartBuffer:Boolean;
		private var _calcErrorBuffer:Boolean;
		private var _useNetStreamInfo:Boolean;
		
		private var _calcOvershoot:Number = 0;
		private var _calcMultiplier:Number = 0;
		
		private var _startBuffer:Number = 1;
		private var _baseBuffer:Number = 10;
		private var _extendedBuffer:Number = 20;
		private var _limitedBuffer:Number = 3;
		
		private var _emptyCount:uint = 2;
		private var _fullTime:Number = 10;
		
		
		//-----------------------------------------------------------
		// GETTER/SETTERS
		//-----------------------------------------------------------
		public function get useNetStreamInfo():Boolean
		{
			return _useNetStreamInfo;
		}
		public function set useNetStreamInfo( value:Boolean ):void
		{
			if( value != _useNetStreamInfo )
			{
				_useNetStreamInfo = value;
				dispatchEvent( new Event( "useNetStreamInfoChange" ) );
			}
		}
		
		public function get calcStartBuffer():Boolean
		{
			return _calcStartBuffer;
		}
		public function set calcStartBuffer( value:Boolean ):void
		{
			if( value != _calcStartBuffer )
			{
				_calcStartBuffer = value;
				dispatchEvent( new Event( "calcStartBufferChange" ) );
			}
		}
		
		public function get calcErrorBuffer():Boolean
		{
			return _calcErrorBuffer;
		}
		public function set calcErrorBuffer( value:Boolean ):void
		{
			if( value != _calcErrorBuffer )
			{
				_calcErrorBuffer = value;
				dispatchEvent( new Event( "calcErrorBufferChange" ) );
			}
		}
		
		public function get calcOvershoot():Number
		{
			return _calcOvershoot;
		}
		public function set calcOvershoot( value:Number ):void
		{
			if( value != _calcOvershoot )
			{
				_calcOvershoot = value;
				dispatchEvent( new Event( "calcOvershootChange" ) );
			}
		}
		
		public function get calcMultiplier():Number
		{
			return _calcMultiplier;
		}
		public function set calcMultiplier( value:Number ):void
		{
			if( value != _calcMultiplier )
			{
				_calcMultiplier = value;
				dispatchEvent( new Event( "calcMultiplierChange" ) );
			}
		}
		
		public function get startBuffer():Number
		{
			return _startBuffer;
		}
		public function set startBuffer( value:Number ):void
		{
			if( value != _startBuffer )
			{
				_startBuffer = value;
				dispatchEvent( new Event( "startBufferChange" ) );
			}
		}
		
		public function get baseBuffer():Number
		{
			return _baseBuffer;
		}
		public function set baseBuffer( value:Number ):void
		{
			if( value != _baseBuffer )
			{
				_baseBuffer = value;
				dispatchEvent( new Event( "baseBufferChange" ) );
			}
		}
		
		public function get extendedBuffer():Number
		{
			return _extendedBuffer;
		}
		public function set extendedBuffer( value:Number ):void
		{
			if( value != _extendedBuffer )
			{
				_extendedBuffer = value;
				dispatchEvent( new Event( "extendedBufferChange" ) );
			}
		}
		
		public function get limitedBuffer():Number
		{
			return _limitedBuffer;
		}
		public function set limitedBuffer( value:Number ):void
		{
			if( value != _limitedBuffer )
			{
				_limitedBuffer = value;
				dispatchEvent( new Event( "limitedBufferChange" ) );
			}
		}
		
		public function get emptyCount():uint
		{
			return _emptyCount;
		}
		public function set emptyCount( value:uint ):void
		{
			if( value != _emptyCount )
			{
				_emptyCount = value;
				dispatchEvent( new Event( "emptyCountChange" ) );
			}
		}
		
		public function get fullTime():Number
		{
			return _fullTime;
		}
		public function set fullTime( value:Number ):void
		{
			if( value != _fullTime )
			{
				_fullTime = value;
				dispatchEvent( new Event( "fullTimeChange" ) );
			}
		}
	}
}