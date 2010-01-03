package modules.videoPlayer.controls
{
	import modules.videoPlayer.events.PlayPauseEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;

	public class PlayButton extends UIComponent
	{
		
		/**
		 * Variables
		 * 
		 */
		
		private var _state:String = "play";
		private var bg:Sprite;
		private var bgOver:Sprite;
		
		
		public function PlayButton()
		{
			super();
			
			this.height = 20;
			this.width = 20;
			
			this.buttonMode = true;
			this.useHandCursor = true;
			
			this.addEventListener( MouseEvent.ROLL_OVER, onMouseOver );
			this.addEventListener( MouseEvent.ROLL_OUT, onMouseOut );
			this.addEventListener( MouseEvent.CLICK, onClick );
		}
		
		
		
		/**
		 * Setters and Getters
		 * 
		 */
		
		public function set State( state:String ):void
		{
			_state = state;
			
			invalidateDisplayList();
		}
		
		public function get State( ):String
		{
			return _state;
		}
		
		
		/**
		 * Methods
		 * 
		 */
		
		
		/** OVERRIDEN */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			this.graphics.clear();
			
			bgOver = new Sprite();
			bgOver.graphics.beginFill( 0x454545 );
			bgOver.graphics.drawRect( 0, 0, 20, 20 );
			bgOver.graphics.endFill();
			
			addChild( bgOver );
			
			bg = new Sprite();
			bg.graphics.beginFill( 0x343434 );
			bg.graphics.drawRect( 0, 0, 20, 20 );
			bg.graphics.endFill();
			
			addChild( bg );
			
			
			var btn:Sprite = new Sprite();
			
			if( _state == "play" )
			{
				btn = CreatePlayButton();
				btn.x = this.width/2 - btn.width/2;
				btn.y = this.height/2 - btn.height/2;
				
				addChild( btn );
			} else
			{
				btn = CreatePauseButton();
				btn.x = this.width/2 - btn.width/2;
				btn.y = this.height/2 - btn.height/2;
				
				addChild( btn );
			}
		}
		
		
		private function CreatePlayButton():Sprite
		{
			var g:Sprite = new Sprite();
			g.graphics.beginFill( 0xffffff );
			g.graphics.lineTo( 6, 6 );
			g.graphics.lineTo( 0, 10 );
			g.graphics.lineTo( 0,0 );
			g.graphics.endFill();
			
			return g;
		}
		
		
		private function CreatePauseButton():Sprite
		{
			var g:Sprite = new Sprite();
			g.graphics.beginFill( 0xffffff );
			g.graphics.drawRect( 0, 0, 3, 10 );
			g.graphics.drawRect( 6, 0, 3, 10 );
			g.graphics.endFill();
			
			return g;
		}
		
		
		private function onMouseOver( e:MouseEvent ):void
		{
			bg.alpha = 0;
		}
		
		
		private function onMouseOut( e:MouseEvent ):void
		{
			bg.alpha = 1;
		}
		
		
		private function onClick( e:MouseEvent ):void
		{
			trace( "play/pause btn pressed" );
			this.State = _state == "play" ? "pause" : "play";
			
			dispatchEvent( new PlayPauseEvent( PlayPauseEvent.STATE_CHANGED ) );
		}
		
	}
}