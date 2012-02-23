package com.realeyes.osmf.components
{
	import com.realeyes.osmf.data.IChapter;
	import com.realeyes.osmf.events.DebugEvent;
	import com.realeyes.osmf.interfaces.IVideoShell;
	
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetStream;
	
	import mx.core.UIComponent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	
	[Event(name="netConnectionChange", type="flash.events.Event")]
	[Event(name="netStreamChange", type="flash.events.Event")]
	[Event(name="netGroupChange", type="flash.events.Event")]
	[Event(name="pluginsComplete", type="flash.events.Event")]
	[Event(name="pluginsSuccessful", type="flash.events.Event")]
	[Event(name="playerReady", type="flash.events.Event")]
	[Event(name="debug", type="com.realeyes.osmf.events.DebugEvent")]
	public class PlayerWrapper extends UIComponent implements IVideoShell
	{
		//==========================================================
		//	PROPERTY DECLARATIONS
		//==========================================================
		public var player:PluginPlayer;
		
		
		//==========================================================
		//	INIT METHODS
		//==========================================================
		public function PlayerWrapper()
		{
			super();
			
			_initPlayer();
		}
		
		private function _initPlayer():void
		{
			player = new PluginPlayer();
			player.width = width;
			player.height = height;
			
			//Redispatch any player events
			player.addEventListener( PluginPlayer.NET_CONNECTION_CHANGE, _onPlayerEvent );
			player.addEventListener( PluginPlayer.NET_STREAM_CHANGE, _onPlayerEvent );
			player.addEventListener( PluginPlayer.NET_GROUP_CHANGE, _onPlayerEvent );
			player.addEventListener( PluginPlayer.PLUGINS_COMPLETE, _onPlayerEvent );
			player.addEventListener( PluginPlayer.PLUGINS_SUCCESSFUL, _onPlayerEvent );
			player.addEventListener( PluginPlayer.PLAYER_READY, _onPlayerEvent );
			player.addEventListener( PluginPlayer.DEBUG, _onPlayerEvent );
			
			addChild( player );
		}
		
		
		//==========================================================
		//	CONTROL METHODS
		//==========================================================
		public function generateMediaElement( resource:MediaResourceBase ):MediaElement
		{
			return player.generateMediaElement( resource );
		}
		
		public function generateDualBufferMediaElement( resource:MediaResourceBase, initialBuffer:Number, expandedBuffer:Number, liveBuffer:Number ):MediaElement
		{
			return player.generateDualBufferMediaElement( resource, initialBuffer, expandedBuffer, liveBuffer );
		}
		
		public function proxyToDualBufferMediaElement( element:MediaElement, initialBuffer:Number, expandedBuffer:Number, liveBuffer:Number ):MediaElement
		{
			return player.proxyToDualBufferMediaElement( element, initialBuffer, expandedBuffer, liveBuffer );
		}
		
		public function play( path:String, urlIncludesFMSApplicationInstance:Boolean = false ):void
		{
			player.play( path, urlIncludesFMSApplicationInstance );
		}
		
		public function playResource( resource:MediaResourceBase ):void
		{
			player.playResource( resource );
		}
		
		public function clear():Boolean
		{
			return player.clear();
		}
		
		public function clearMediaElement( element:MediaElement ):Boolean
		{
			return player.clearMediaElement( element );
		}
		
		public function dispatchHide():void
		{
			player.dispatchHide();
		}
		
		public function dispatchShow():void
		{
			player.dispatchShow();
		}
		
		public function ping():Boolean
		{
			return player.ping();
		}
		
		public function loadPluginsFromXML( pluginsList:XMLList ):void
		{
			player.loadPluginsFromXML( pluginsList );
		}
		
		public function loadPlugin( plugin:MediaResourceBase ):void
		{
			player.loadPlugin( plugin );
		}
		
		public function addPluginToQue( plugin:MediaResourceBase ):void
		{
			player.addPluginToQue( plugin );
		}
		
		public function removePluginFromQue( plugin:MediaResourceBase ):Boolean
		{
			return removePluginFromQue( plugin );
		}
		
		public function loadAllPlugins():void
		{
			player.loadAllPlugins();
		}
		
		public function clearPluginLoadCounts():void
		{
			player.clearPluginLoadCounts();
		}
		
		public function authenticate( user:String, pass:String ):void
		{
			player.authenticate( user, pass );
		}
		
		public function authenticateToken( token:* ):void
		{
			player.authenticateToken( token );
		}
		
		public function addChapters( chapters:Vector.<IChapter> ):void
		{
			player.addChapters( chapters );
		}
		
		public function cleanupElement():void
		{
			player.cleanupElement();
		}
		
		public function debug(msg:String):void
		{
			this.dispatchEvent( new DebugEvent( DebugEvent.DEBUG, msg, false ) );
		}
		
		
		//==========================================================
		//	EVENT HANDLERS
		//==========================================================
		private function _onPlayerEvent( event:Event ):void
		{
			if( !event.bubbles )
			{
				dispatchEvent( event );
			}
		}
		
		
		//==========================================================
		//	GETTER/SETTERS
		//==========================================================
		public function get autoLinkMediaPlayer():Boolean
		{
			return player.autoLinkMediaPlayer;
		}
		public function set autoLinkMediaPlayer( value:Boolean ):void
		{
			player.autoLinkMediaPlayer = value;
		}
		
		public function get mediaContainer():MediaContainer
		{
			return player.mediaContainer;
		}
		
		public function get isLive():Boolean
		{
			return player.isLive;
		}
		public function set isLive(value:Boolean):void
		{
			player.isLive = value;
		}
		
		public function get pluginsComplete():Boolean
		{
			return player.pluginsComplete;
		}
		
		public function get pluginState():String
		{
			return player.pluginState;
		}
		
		public function get mediaPlayer():MediaPlayer
		{
			return player.mediaPlayer;
		}
		
		public function get mediaElement():MediaElement
		{
			return player.mediaElement;
		}
		public function set mediaElement( value:MediaElement ):void
		{
			player.mediaElement = value;
		}
		
		[Bindable(event="netStreamChange")]
		public function get netStream():NetStream
		{
			return player.netStream;
		}
		public function set netStream(value:NetStream):void
		{
			player.netStream = value;
		}
		
		[Bindable(event="netGroupChange")]
		public function get netGroup():NetGroup
		{
			return player.netGroup;
		}
		public function set netGroup(value:NetGroup):void
		{
			player.netGroup = value;
		}
		
		[Bindable(event="netConnectionChange")]
		public function get netConnection():NetConnection
		{
			return player.netConnection;
		}
		public function set netConnection(value:NetConnection):void
		{
			player.netConnection = value;
		}
		
		public function get multicastWindowDuration():Number
		{
			return player.multicastWindowDuration;
		}
		public function set multicastWindowDuration(value:Number):void
		{
			player.multicastWindowDuration = value;
		}
		
		override public function get width():Number
		{
			return super.width;
		}
		override public function set width( value:Number ):void
		{
			super.width = value;
			player.mediaContainer.width = value;
		}
		
		override public function get height():Number
		{
			return super.height;
		}
		override public function set height( value:Number ):void
		{
			super.height = value;
			player.mediaContainer.height = value;
		}
		
		public function get totalPluginCount():uint
		{
			return player.totalPluginCount;
		}
		
		public function get loadedPluginCount():uint
		{
			return player.loadedPluginCount;
		}
		
		public function get failedPluginCount():uint
		{
			return player.failedPluginCount;
		}
		
		public function get pluginList():Vector.<MediaResourceBase>
		{
			return player.pluginList;
		}
		
		public function get autoSize():Boolean
		{
			return player.autoSize;
		}
		
		public function set autoSize(value:Boolean):void
		{
			player.autoSize = value;
		}
		
		public function get backgroundColor():Number
		{
			return player.backgroundColor;
		}
		public function set backgroundColor( value:Number ):void
		{
			player.backgroundColor = value;
		}
		
		public function get drmState():String
		{
			return player.drmState;
		}
		public function set drmState(value:String):void
		{
			player.drmState = value;
		}
	}
}