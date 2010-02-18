package modules.videoPlayer.controls
{
	import modules.videoPlayer.events.PlayPauseEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;

	public class PlayButton extends SkinableComponent
	{
		/**
		 * Skin related constants
		 */
		public static const BG_COLOR:String = "bgColor";
		public static const OVERBG_COLOR:String = "overBgColor";
		public static const ICON_COLOR:String = "iconColor";
		
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
		private var bg:Sprite;
		private var bgOver:Sprite;
		private var btn:Sprite;
		
		
		public function PlayButton()
		{
			super("PlayButton");
			
			this.height = 20;
			this.width = 20;
			
			this.buttonMode = true;
			this.useHandCursor = true;
			
			bgOver = new Sprite();
			bg = new Sprite();
			btn = new Sprite();
			
			addChild( bgOver );
			addChild( bg );
			addChild( btn );
			
			this.addEventListener( MouseEvent.ROLL_OVER, onMouseOver );
			this.addEventListener( MouseEvent.ROLL_OUT, onMouseOut );
			this.addEventListener( MouseEvent.CLICK, onClick );
		}
		
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BG_COLOR,OVERBG_COLOR,ICON_COLOR]);
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
		
		public function getState( ):String
		{
			return _state;
		}
		
		/**
		 * Enable/disable play button
		 **/
		override public function set enabled(flag:Boolean) : void
		{
			super.enabled = flag;

			this.buttonMode = flag;
			this.useHandCursor = flag;

			if ( flag )
			{
				this.addEventListener( MouseEvent.ROLL_OVER, onMouseOver );
				this.addEventListener( MouseEvent.ROLL_OUT, onMouseOut );
				this.addEventListener( MouseEvent.CLICK, onClick );
			}
			else
			{
				this.removeEventListener( MouseEvent.ROLL_OVER, onMouseOver );
				this.removeEventListener( MouseEvent.ROLL_OUT, onMouseOut );
				this.removeEventListener( MouseEvent.CLICK, onClick );
			}
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
			
			bgOver.graphics.clear();
			bgOver.graphics.beginFill( getSkinColor(OVERBG_COLOR) );
			bgOver.graphics.drawRect( 0, 0, 20, 20 );
			bgOver.graphics.endFill();
			
			bg.graphics.clear();
			bg.graphics.beginFill( getSkinColor(BG_COLOR) );
			bg.graphics.drawRect( 0, 0, 20, 20 );
			bg.graphics.endFill();
			
			if( _state == PLAY_STATE )
			{
				CreatePlayButton();
				btn.x = this.width/2 - btn.width/2;
				btn.y = this.height/2 - btn.height/2;
			} else
			{
				CreatePauseButton();
				btn.x = this.width/2 - btn.width/2;
				btn.y = this.height/2 - btn.height/2;
				
				addChild( btn );
			}
		}
		
		
		private function CreatePlayButton():void
		{
			var g:Sprite = btn;
			g.graphics.clear();
			g.graphics.beginFill( getSkinColor(ICON_COLOR) );
			g.graphics.lineTo( 6, 6 );
			g.graphics.lineTo( 0, 10 );
			g.graphics.lineTo( 0,0 );
			g.graphics.endFill();
		}
		
		
		private function CreatePauseButton():void
		{
			var g:Sprite = btn;
			g.graphics.clear();
			g.graphics.beginFill( getSkinColor(ICON_COLOR) );
			g.graphics.drawRect( 0, 0, 3, 10 );
			g.graphics.drawRect( 6, 0, 3, 10 );
			g.graphics.endFill();
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
			this.State = _state == PLAY_STATE ? PAUSE_STATE : PLAY_STATE;
			
			dispatchEvent( new PlayPauseEvent( PlayPauseEvent.STATE_CHANGED ) );
		}
		
	}
}