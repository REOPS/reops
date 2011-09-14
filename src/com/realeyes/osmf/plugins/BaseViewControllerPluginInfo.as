package com.realeyes.osmf.plugins
{
	import com.realeyes.osmf.interfaces.IVideoShell;
	import com.realeyes.osmf.utils.PluginUtils;
	
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	
	public class BaseViewControllerPluginInfo extends PluginInfo
	{
		
		private var _vidShell:IVideoShell;
		private var _currentElement:MediaElement;
		//the plugin resource
		private var _resource:MediaResourceBase;
		
		/**
		 * Constructor - calls super
		 * @param mediaFactoryItems
		 * @param mediaElementCreationNotificationFunction
		 * 
		 */
		public function BaseViewControllerPluginInfo(mediaFactoryItems:Vector.<MediaFactoryItem>=null, mediaElementCreationNotificationFunction:Function=null)
		{
			super(mediaFactoryItems, mediaElementCreationNotificationFunction);
		}
		
		
		
		/**
		 * Called automatically once the plugin has been loaded 
		 * @param resource
		 * 
		 */
		override public function initializePlugin( resource:MediaResourceBase ):void
		{
			
			_resource = resource;
			_vidShell = resource.getMetadataValue( PluginUtils.SHELL ) as IVideoShell;
			
			debug( "BaseViewControllerPluginInfo - Initialized" );
			
		}
		
		
		////////////////////////////////////////////////
		//REFFERENCE PLUGIN IMPLEMENTATION
		protected function elementCreatedNotification( element:MediaElement ):void 
		{
			debug( "Element Created: " + element);
			
			if( _currentElement )
			{
				_currentElement.removeEventListener( ContainerChangeEvent.CONTAINER_CHANGE, _onContainerChange );
			}
			
			_currentElement = element;
			_currentElement.addEventListener( ContainerChangeEvent.CONTAINER_CHANGE, _onContainerChange, false, 0, true );
			
		}
		
		private function _onContainerChange( event:ContainerChangeEvent ):void
		{
			
		}
		
		
		protected function debug( msg:String ):void 
		{
			//trace( msg );
			if( _vidShell )
			{
				_vidShell.debug( msg );
			}
		}
	}
}