package com.realeyes.osmf.components
{
	
	import com.realeyes.osmf.buffering.DualThresholdBufferingProxyElement;
	import com.realeyes.osmf.data.ChapterVO;
	import com.realeyes.osmf.data.IChapter;
	import com.realeyes.osmf.events.ControlBarEvent;
	import com.realeyes.osmf.events.DebugEvent;
	import com.realeyes.osmf.interfaces.IPlugablePlayer;
	import com.realeyes.osmf.interfaces.IVideoShell;
	import com.realeyes.osmf.plugins.RESkinPluginInfo;
	import com.realeyes.osmf.utils.PluginUtils;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.utils.getDefinitionByName;
	import flash.xml.XMLNode;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.F4MLoader;
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.DRMState;
	import org.osmf.traits.DRMTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	
	[Event(name="pluginsSuccessful", type="com.realeyes.osmf.player.PluginPlayer")]
	[Event(name="pluginsComplete", type="flash.events.Event")]
	[Event(name="playerReady", type="com.realeyes.osmf.player.PluginPlayer")]
	[Event(name="pluginLoad", type="org.osmf.events.MediaFactoryEvent")]
	[Event(name="pluginLoadError", type="org.osmf.events.MediaFactoryEvent")]
	
	/**
	 * Base OSMF Player that has media management and plugin management 
	 * @author dhassoun
	 * 
	 */
	public class PluginPlayer extends Sprite implements IPlugablePlayer, IVideoShell
	{
		
		
		///////////////////////////////////////////////////
		// DECLARATIONS
		///////////////////////////////////////////////////
		
		private var _loadedPluginCount:uint;
		private var _failedPluginCount:uint;
		
		
		protected var _pluginList:Vector.<MediaResourceBase>;
		protected var _pluginState:String = "ready";
		protected var _pluginsComplete:Boolean = true;

		protected var _autoSize:Boolean = true;

				
		private var _mediaElement:MediaElement;
		protected var player:MediaPlayer;
		protected var container:MediaContainer;
		protected var mediaFactory:DefaultMediaFactory;
		protected var drmTrait:DRMTrait;
		
		private var _drmState:String;
		
		private var _isLive:Boolean;
		public var autoLinkMediaPlayer:Boolean = true;
		
		private var _netConnection:NetConnection;
		private var _netGroup:NetGroup;
		private var _netStream:NetStream;
		private var _multicastWindowDuration:Number;
		
		public static const NET_CONNECTION_CHANGE:String = "netConnectionChange";
		public static const NET_STREAM_CHANGE:String = "netStreamChange";
		public static const NET_GROUP_CHANGE:String = "netGroupChange";
		public static const PLUGINS_COMPLETE:String = "pluginsComplete";
		public static const PLUGINS_SUCCESSFUL:String = "pluginsSuccessful";
		public static const PLUGINS_LOADING:String = "pluginsLoading";
		public static const PLAYER_READY:String = "playerReady";
		public static const DEBUG:String = "debug";
		
		static public const NAMESPACE:String = "com.realeyes.osmf.components.PluginPlayer";
		
		///////////////////////////////////////////////////
		// CONSTRUCTOR
		///////////////////////////////////////////////////
		
		public function PluginPlayer()
		{
			debug("> Vid Player Constructor <");
			//Security.allowDomain( "*" );
			
			RESkinPluginInfo;
			initPlayer();
			if(stage)
			{
				onAddedToStage();
			}
			
		}
		
		///////////////////////////////////////////////////
		// INIT METHODS
		///////////////////////////////////////////////////
		
		
		
		/**
		 * Initializes the interkan OSMF controls and layout 
		 * 
		 */
		protected function initPlayer():void
		{
			debug("- INIT PLAYER -");
			// Create a mediafactory instance
			mediaFactory = new DefaultMediaFactory();
			
			//the simplified api controller for media
			player = new MediaPlayer();
			player.addEventListener( MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, _onStateChange );
			//the container (sprite) for managing display and layout
			container = new MediaContainer();	
			
			container.width = this.width;
			container.height = this.height;
			
			//Adds the container to the stage
			this.addChild( container );
			
			//event listeners for basic handling (success/fail)
			mediaFactory.addEventListener( MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded );
			mediaFactory.addEventListener( MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed );
			//loadPlugin( new URLResource( "http://office.realeyes.com/OSMF/plugins/MediaSelectorPlugin.swf" ) );
		}
		
		
		
		///////////////////////////////////////////////////
		// CONTROL METHODS
		///////////////////////////////////////////////////
		
		
		
		
		/**
		 * Utilizes the MediaFactory to generate a MediaElement from a supplied MediaResourceBase instance
		 * @param resource
		 * @return 
		 * 
		 */
		public function generateMediaElement( resource:MediaResourceBase ):MediaElement
		{
			return mediaFactory.createMediaElement( resource );
		}
		
		/**
		 * Utilizes the MediaFactory to generate a MediaElement from a supplied MediaResourceBase instance
		 * @param resource
		 * @return 
		 * 
		 */
		public function generateDualBufferMediaElement( resource:MediaResourceBase, initialBuffer:Number, expandedBuffer:Number, liveBuffer:Number ):MediaElement
		{
			return new DualThresholdBufferingProxyElement( initialBuffer, expandedBuffer, liveBuffer, mediaFactory.createMediaElement( resource ) );
			
		}
		
		public function proxyToDualBufferMediaElement( element:MediaElement, initialBuffer:Number, expandedBuffer:Number, liveBuffer:Number ):MediaElement
		{
			return new DualThresholdBufferingProxyElement( initialBuffer, expandedBuffer, liveBuffer, element );
			
		}
		
		
		/**
		 * Invokes playback via the MediaFactory for the specified path 
		 * @param path	String - Path to the media to invoke
		 * @param urlIncludesFMSApplicationInstance	Boolean - does the URL include an app instance?
		 */
		public function play( path:String, urlIncludesFMSApplicationInstance:Boolean = false ):void
		{
			
			debug("PLAY: " + path);
			
			var resource:URLResource;
			if( urlIncludesFMSApplicationInstance && path.indexOf( 'rtmp' ) > -1 )
			{
				resource = new StreamingURLResource( path );
				StreamingURLResource( resource ).urlIncludesFMSApplicationInstance = true;
			}
			else
			{
				resource = new URLResource( path );
			}
			
			var tempMediaElement:MediaElement = generateMediaElement( resource );
			
			mediaElement = tempMediaElement;
		}
		
		
		/**
		 * Allows for playback invocation directly from a MediaResouce. 
		 * Used to pass a custom Resource and kick off the plugin management - called from controller
		 * @param resource
		 * 
		 */
		public function playResource( resource:MediaResourceBase ):void
		{
			var tempMediaElement:MediaElement = generateMediaElement( resource );
			
			mediaElement = tempMediaElement;
		}
		
		
		/**
		 * Clears the current media element
		 * @param element
		 * @return 
		 * 
		 */
		public function clear():Boolean
		{
			return clearMediaElement( _mediaElement );
		}
		
		/**
		 * Checks if the specified MediaElement is within the container and if so clears it and returns - true 
		 * @param element
		 * @return 
		 * 
		 */
		public function clearMediaElement( element:MediaElement ):Boolean
		{
			
			if( container.containsMediaElement( element ) )
			{
				debug( "[ media element exist - remove from container ]");
				container.removeMediaElement( element );
				return true;
			}
			
			return false;
		}
		
		/**
		 * Dispatches the HIDE_CONTROLS event on the media container.
		 * If using the RESKinPlugin this will hide all the control elements 
		 * 
		 */
		public function dispatchHide():void
		{
			container.dispatchEvent( new Event( PluginUtils.HIDE_CONTROLS ) );
		}
		
		/**
		 * Dispatches the SHOW_CONTROLS event on the media container.
		 * If using the RESKinPlugin this will show all the control elements 
		 * 
		 */
		public function dispatchShow():void
		{
			container.dispatchEvent( new Event( PluginUtils.SHOW_CONTROLS ) );
		}
		
		
		/**
		 * Ping functionality for dynamically loaded player to verify loaded state. 
		 * Dispatches bubbling event and returns true 
		 * @return 
		 * 
		 */
		public function ping():Boolean
		{
			debug(">PING: Disp evt - player ready to go");
			this.dispatchEvent( new Event( PLAYER_READY, true, true ) );
			return true;
		}
		
		/**
		 *Loops from the pluginList:XMLList parameter adds the plugins to the que then loads all plugins 
		 * @param pluginsList
		 * 
		 */
		public function loadPluginsFromXML( pluginsList:XMLList ):void
		{
			
			var pluginResource:MediaResourceBase;
			
			for each( var plugin:XML in pluginsList)
			{
				//trace("source: " + plugin.@source != "");
				if( plugin.@source && plugin.@source  != "" ) //Load Dynamic Plugin
				{
					pluginResource = new URLResource( plugin.@source );
					
				}
				else if( plugin.@classPath ) //load class plugin
				{
					trace("CLASS PATH: " + plugin.@classPath);
					var classRef:Class = getDefinitionByName( plugin.@classPath ) as Class;
					pluginResource = new PluginInfoResource( new classRef() );
				}
				else
				{
					throw( new Error( "ERROR: No classPath or source path defined for plugin" ) );
				}
				
				//pluginResource.addMetadataValue( CSGPluginsUtil.VIDEO_APP_SHELL, this );
				
				if( plugin.hasOwnProperty("metadata") )
				{
					//trace("ns: " + plugin.metadata[0].text);
					var pluginNS:String = plugin.metadata.@namespace.toString();
					var keys:XMLList = plugin.metadata..key;
					//trace(keys.length());
					
					if(keys.length())
					{
						var metadata:Metadata = new Metadata();
						for each( var key:XML in keys )
						{
							trace(key.@name + ": " + key.toString());
							trace("======");
							metadata.addValue( key.@name, key.toString() );
						}
						pluginResource.addMetadataValue( pluginNS, metadata);
					}
					else
					{
						
						var metadataXML:XMLList = plugin.metadata.children();
						pluginResource.addMetadataValue( pluginNS, metadataXML);
					}
					
				}
				
				
				
				addPluginToQue( pluginResource );
			}
			
			
			loadAllPlugins();
		}
		
		/**
		 *  Executes loading the plugin via the MediaFactory.
		 * Should only be called directly if loading only 1 plugin or managing multiple from outside the player.
		 * Otherwise use the addPlugin and loadAllPlugins methods
		 * @param plugin
		 * 
		 */
		public function loadPlugin( plugin:MediaResourceBase ):void
		{
			debug("LOAD PLUGIN: " + plugin);// is PluginInfoResource ? (plugin as PluginInfoResource).pluginInfo : plugin
			
			plugin.addMetadataValue( PluginUtils.MEDIA_PLAYER, player );
			plugin.addMetadataValue( PluginUtils.PLUGIN_PLAYER, this );
			
			
			
			if( pluginList.indexOf( plugin ) == -1 )
			{
				_pluginList.push( plugin );
			}
			
			_pluginsComplete = false;
			_pluginState = PLUGINS_LOADING;
			mediaFactory.loadPlugin( plugin );
			
		}
		
		/**
		 * Register a OSMF plugin for loading via the MediaFactory 
		 * @param plugin
		 * 
		 */
		public function addPluginToQue( plugin:MediaResourceBase ):void
		{
			debug("-- addPluginToQue: " + plugin);
			pluginList.push( plugin );
		}
		
		/**
		 * Removes the specified plogin from the collection if it exists already and returns true, otherwise returns false
		 * @param plugin
		 * @return 
		 * 
		 */
		public function removePluginFromQue( plugin:MediaResourceBase ):Boolean
		{
			if( _pluginList.indexOf( plugin ) != -1 )
			{
				_pluginList.splice( _pluginList.indexOf( plugin ), 1 );
				return true;
			}
			
			return false;
		}
		
		/**
		 * Executing loading of all the registered plugins via the loadPlugin() mnethod
		 * 
		 */
		public function loadAllPlugins():void
		{
			debug("-- loadAllPlugins --");
			clearPluginLoadCounts();
			
			for each ( var plugin:MediaResourceBase in _pluginList )
			{
				loadPlugin( plugin );
			}
		}
		
		
		/**
		 * Reset the loaded and failed plugin counts 
		 * 
		 */
		public function clearPluginLoadCounts():void
		{
			_loadedPluginCount = _failedPluginCount = 0;
		}
		
		
		
		/**
		 * Traces and dispatches an event that bubbles 
		 * @param msg
		 * 
		 */
		public function debug( msg:String ):void
		{
			trace( msg );
			this.dispatchEvent( new DebugEvent( DebugEvent.DEBUG, msg, false ) );
			
		}
		
		
		protected function updateIsLiveMetaData():void
		{
			var liveMetaData:Metadata = _mediaElement.getMetadata( NAMESPACE );
			if( !liveMetaData )
			{
				liveMetaData = new Metadata();
			}
			
			liveMetaData.addValue( "isLive", _isLive );
			_mediaElement.addMetadata( NAMESPACE, liveMetaData );
		}
		
		public function authenticate( user:String, pass:String ):void
		{
			drmTrait.authenticate( user, pass );
		}
		
		public function authenticateToken( token:* ):void
		{
				drmTrait.authenticateWithToken( token );
		}
		
		public function addChapters( chapters:Vector.<IChapter> ):void
		{
			if( _mediaElement )
			{
				var chapterMetaData:Metadata = new Metadata();
				chapterMetaData.addValue( ChapterVO.CHAPTERS, chapters );
				_mediaElement.addMetadata( ChapterVO.CHAPTER_METADATA_NS, chapterMetaData );
			}
		}
		
		public function cleanupElement():void
		{
			if( _mediaElement )
			{
				clearMediaElement( _mediaElement );
				_mediaElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitAdd);
			}
			
			if( drmTrait )
			{
				drmTrait.removeEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMTraitDRMStateChange);
				drmTrait = null;
				drmState = "";
			}
			
		}
		
		///////////////////////////////////////////////////
		// GETTER/SETTERS
		///////////////////////////////////////////////////
		
		
		public function get mediaContainer():MediaContainer
		{
			return container;
		}
		
		public function get isLive():Boolean
		{
			return _isLive;
		}
		
		public function set isLive(value:Boolean):void
		{
			if( value != _isLive )
			{
				_isLive = value;
				container.dispatchEvent( new ControlBarEvent( ControlBarEvent.IS_LIVE, Number(_isLive) ) );
				
				if( _mediaElement )
				{
					updateIsLiveMetaData();
				}
			}
		}
		
		public function get pluginsComplete():Boolean
		{
			return _pluginsComplete;
		}
		
		public function get pluginState():String
		{
			return _pluginState;
		}
		
		public function get mediaPlayer():MediaPlayer
		{
			return player;
		}
		
		public function get mediaElement():MediaElement
		{
			return _mediaElement;
		}
		
		public function set mediaElement( value:MediaElement ):void
		{
			if( !value )
			{
				player.dispatchEvent( new MediaErrorEvent( MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError( 100, "PluginPlayer - Media Element was null" ) ) );
				return;
			}
			
			cleanupElement();
			
			_mediaElement = value;
			
			var loadTrait:LoadTrait = _mediaElement.getTrait( MediaTraitType.LOAD ) as LoadTrait;
			loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, _onLoadStateChange );
			
			_mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaElementTraitAdd);
			
			if( !container.containsMediaElement( _mediaElement ) )
			{	
				container.addMediaElement( value );
			}	
			
			//Made configurable since linking can be automated via skin plugin
			if( autoLinkMediaPlayer )
			{
				player.media = _mediaElement;
			}
			
			//TODO - should we auto update here?
			updateIsLiveMetaData();
			
		}
		
		[Bindable(event="netStreamChange")]
		public function get netStream():NetStream
		{
			return _netStream;
		}
		
		public function set netStream(value:NetStream):void
		{
			if( _netStream !== value)
			{
				_netStream = value;
				dispatchEvent(new Event(NET_STREAM_CHANGE));
				
				if( _netStream )
				{
					_netStream.removeEventListener( NetStatusEvent.NET_STATUS, _onNetStatus );
					_netStream.addEventListener( NetStatusEvent.NET_STATUS, _onNetStatus, false, 0, true );
					
				}
				
			}
		}
		
		[Bindable(event="netGroupChange")]
		public function get netGroup():NetGroup
		{
			return _netGroup;
		}
		
		public function set netGroup(value:NetGroup):void
		{
			if( _netGroup !== value)
			{
				_netGroup = value;
				dispatchEvent(new Event( NET_GROUP_CHANGE ));
				
				if( _netGroup )
				{
					_netGroup.removeEventListener( NetStatusEvent.NET_STATUS, _onNetStatus );
					_netGroup.addEventListener( NetStatusEvent.NET_STATUS, _onNetStatus, false, 0, true );
					
				}
			}
		}
		
		
		
		[Bindable(event="netConnectionChange")]
		public function get netConnection():NetConnection
		{
			return _netConnection;
		}
		
		public function set netConnection(value:NetConnection):void
		{
			if( _netConnection !== value)
			{
				_netConnection = value;
				dispatchEvent(new Event(NET_CONNECTION_CHANGE));
			}
		}
		
		public function get multicastWindowDuration():Number
		{
			return _multicastWindowDuration;
		}
		
		public function set multicastWindowDuration(value:Number):void
		{
			_multicastWindowDuration = value;
			
			if( _netStream )
			{
				_netStream.multicastWindowDuration = _multicastWindowDuration;
			}
		}
		
		
		
		override public function get width():Number
		{
			return super.width;
		}
		
		override public function set width( value:Number ):void
		{
			container.width = value;
			//trace("container.width: " + container.width);
		}
		
		
		override public function get height():Number
		{
			return super.height;
		}
		
		override public function set height( value:Number ):void
		{
			container.height = value;
		}
		
		public function get totalPluginCount():uint
		{
			return _pluginList.length;
		}
		
		public function get loadedPluginCount():uint
		{
			return _loadedPluginCount;
		}
		
		public function get failedPluginCount():uint
		{
			return _failedPluginCount;
		}
		
		public function get pluginList():Vector.<MediaResourceBase>
		{
			if(!_pluginList)
			{
				_pluginList = new Vector.<MediaResourceBase>();
			}
			
			return _pluginList;
		}
		
		
		public function get autoSize():Boolean
		{
			return _autoSize;
		}
		
		public function set autoSize(value:Boolean):void
		{
			_autoSize = value;
			if( !stage && _autoSize )
			{
				this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );
			}
/*			else
			{
				stage.removeEventListener(Event.RESIZE, _onResize );
				stage.addEventListener(Event.RESIZE, _onResize, false, 0, true);
			}*/
		}
		
		
		public function get backgroundColor():Number
		{
			return container.backgroundColor;
		}
		
		public function set backgroundColor( value:Number ):void
		{
			container.backgroundAlpha = 1;
			container.backgroundColor = value;
		}
		
		
		
		public function get drmState():String
		{
			return _drmState;
		}
		
		public function set drmState(value:String):void
		{
			_drmState = value;
			debug( "DRM STATE: " + _drmState );
		}
		
		
		
		///////////////////////////////////////////////////
		// EVENT HANDLERS
		///////////////////////////////////////////////////
		
		protected function _onStateChange( event:MediaPlayerStateChangeEvent ):void
		{
			this.dispatchEvent( event );
		}
		
		
		protected function _onResize( event:Event ):void
		{
			debug("RESIZE: " + stage.stageWidth + " , " + stage.stageHeight);
			if( autoSize )
			{
				this.width = stage.stageWidth;
				this.height = stage.stageHeight
			}
		}
		
		protected function onAddedToStage( event:Event = null ):void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			this.width = stage.stageWidth;
			this.height = stage.stageHeight
			stage.addEventListener(Event.RESIZE, _onResize, false, 0, true);
		}
		
		
		/**
		 * Event Hnadler for single plugin loaded successfully. Checks plugin list loading progress.
		 * @param event
		 * 
		 */
		protected function onPluginLoaded( event:MediaFactoryEvent ):void
		{
			
			debug( "Plugin Loaded" );
			this.dispatchEvent( event );
			
			_loadedPluginCount++;
			debug("_loadedPluginCount: " + _loadedPluginCount);
			
			if( (_loadedPluginCount + _failedPluginCount) >= totalPluginCount )
			{
				debug("-- PLUGINS_COMPLETE --");
				_pluginsComplete = true;
				_pluginState = PLUGINS_COMPLETE;
				this.dispatchEvent( new Event(PLUGINS_COMPLETE) );
			}
			
			if( _loadedPluginCount >= totalPluginCount )
			{
				debug("-- PLUGINS_SUCCESSFUL --");
				
				_pluginState = PLUGINS_SUCCESSFUL;
				this.dispatchEvent( new Event(PLUGINS_SUCCESSFUL) );
			}
			
		}
		
		/**
		 * Event Handler for single plugin failure 
		 * @param event
		 * 
		 */
		protected function onPluginLoadFailed( event:MediaFactoryEvent ):void
		{
			debug( "!! Plugin failed to load !!  -- " + event.resource);	
			this.dispatchEvent( event );
			_failedPluginCount++;
		}
				
		protected function onMediaElementTraitAdd( event:MediaElementEvent ):void
		{
			if( event.traitType == MediaTraitType.DRM )
			{
				if(drmTrait)
				{
					//drmTrait.removeEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMTraitDRMStateChange);
					return;//only listen to the first drm trait added
				}
				drmTrait = mediaPlayer.media.getTrait( MediaTraitType.DRM ) as DRMTrait;
				drmTrait.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMTraitDRMStateChange);
			}	
		}
		
		
		protected function onDRMTraitDRMStateChange(event:DRMEvent):void
		{
			
			
			if( drmState == PlayState.PLAYING && event.drmState == DRMState.AUTHENTICATION_COMPLETE)
			{
				return;
			}
			
			drmState = event.drmState;
			
			if( event.drmState == DRMState.AUTHENTICATION_NEEDED )
			{
				dispatchEvent( new Event( DRMState.AUTHENTICATION_NEEDED ) );
			}
			/*else if( drmState == DRMState.AUTHENTICATION_COMPLETE )
			{
				drmState = "";
			}*/
			
		}
		
		
		protected function _onLoadStateChange( event:LoadEvent ):void
		{
			switch( event.loadState )
			{
				case LoadState.READY:
				{
					netStream = event.target.netStream;
					netConnection = event.target.connection;
					netGroup = event.target.netGroup;
					break;
				};
					
				case LoadState.LOAD_ERROR:
				{
					player.dispatchEvent( new MediaErrorEvent( MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError( 101, "PluginPlayer - Load Failed" ) ) );
					break;
				}
			}
			/*if( event.loadState == LoadState.READY )
			{
				netStream = event.target.netStream;
			}*/
		}	
		
		protected function _onNetStatus( event:NetStatusEvent ):void
		{
			debug( "NetStatus: " + event.info.code );
			
			
			
			switch( event.info.code )
			{
				case "NetStream.MulticastStream.Reset":
				{
					if( multicastWindowDuration )
					{
						netStream.multicastWindowDuration = multicastWindowDuration;
					}
					
					break;
				}
					
				case "NetGroup.MulticastStream.UnpublishNotify":
				{
					
					break;
				}
				case "NetGroup.MulticastStream.PublishNotify":
				{
					
					break;
				}
			}
			
			
			this.dispatchEvent( new Event( event.info.code ) );
			
		}	

		

		


	}
}