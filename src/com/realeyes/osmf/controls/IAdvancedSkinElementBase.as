package com.realeyes.osmf.controls
{
	import org.osmf.media.MediaPlayer;

	public interface IAdvancedSkinElementBase extends ISkinElementBase
	{
		function get mediaPlayerCore():MediaPlayer;
		function set mediaPlayerCore( value:MediaPlayer ):void;
	}
}