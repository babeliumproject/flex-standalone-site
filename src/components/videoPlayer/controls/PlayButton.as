package components.videoPlayer.controls
{
	import flash.display.Sprite;
	
	public class PlayButton extends DictionarySkinnableButton
	{
		
		/**
		 * Constants
		 */
		public static const PLAY_STATE:String = "play";
		public static const PAUSE_STATE:String = "pause";
		
		/**
		 * Variables
		 * 
		 */
		private var _state:String = PLAY_STATE;
		
		
		public function PlayButton()
		{
			super("PlayButton"); // Required for setup skinable component
		}
		
		override public function dispose():void{
			super.dispose();
			
			//There are no objects that need to be manually disposed
		}
		
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BG_COLOR,OVERBG_COLOR,ICON_COLOR]);
		}
		
		
		/**
		 * Setters and Getters
		 * 
		 */
		
		public function set state(value:String):void
		{
			if(value && _state != value){
				_state = value;
				invalidateDisplayList();
			}
		}
		
		public function get state():String{
			return _state;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if( _state == PLAY_STATE )
				drawPlayIcon();
			else
				drawPauseIcon();
			btn.x = this.width/2 - btn.width/2;
			btn.y = this.height/2 - btn.height/2;
			addChild(btn);
		}
		
		
		private function drawPlayIcon():void
		{
			var g:Sprite = btn;
			g.graphics.clear();
			g.graphics.beginFill( getSkinColor(ICON_COLOR) );
			g.graphics.lineTo( 10, 5 );
			g.graphics.lineTo( 0, 10 );
			g.graphics.lineTo( 0, 0 );
			g.graphics.endFill();
		}
		
		
		private function drawPauseIcon():void
		{
			var g:Sprite = btn;
			g.graphics.clear();
			g.graphics.beginFill( getSkinColor(ICON_COLOR) );
			g.graphics.drawRect( 0, 0, 3, 10 );
			g.graphics.drawRect( 6, 0, 3, 10 );
			g.graphics.endFill();
		}	
	}
}
