package modules.videoPlayer.controls
{
	import modules.videoPlayer.events.ScrubberBarEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;
	import mx.controls.Alert;

	public class ScrubberBar extends UIComponent
	{
		
		/**
		 * Variables
		 * 
		 */
		 
		
		private var _bar:Sprite;
		private var _progBar:Sprite;
		private var _loadedBar:Sprite;
		private var _scrubber:Sprite;
		private var _bg:Sprite;
		
		
		private var _barColor:uint = 0x00000;
		private var _progColor:uint = 0x008ead;
		private var _loadedColor:uint = 0x555555;
		private var _scrubberColor:uint = 0xababab;
		
		private var _barWidth:Number = 100;
		private var _barHeight:Number = 10;
		
		private var _defaultHeight:Number = 20;
		private var _defaultY:Number;
		private var _defaultX:Number;
		private var _maxX:Number;
		private var _minX:Number;
		private var _dragging:Boolean = false;
		
		
		
		public function ScrubberBar()
		{
			super();
			
			_bar = new Sprite();
			_progBar = new Sprite();
			_loadedBar = new Sprite();
			_scrubber = new Sprite();
			_bg = new Sprite();
		}
		
		
		public function enableSeek(flag:Boolean) : void
		{
			_bar.useHandCursor = flag;
			_bar.buttonMode = flag;
			
			_progBar.useHandCursor = flag;
			_progBar.buttonMode = flag;
			
			_scrubber.useHandCursor = flag;
			_scrubber.buttonMode = flag;
			
			if ( flag )
			{
				_scrubber.addEventListener( MouseEvent.MOUSE_DOWN, onScrubberDrag );
				_bar.addEventListener( MouseEvent.CLICK, onBarClick );
				_progBar.addEventListener( MouseEvent.CLICK, onBarClick );
			}
			else
			{
				_scrubber.removeEventListener( MouseEvent.MOUSE_DOWN, onScrubberDrag );
				_bar.removeEventListener( MouseEvent.CLICK, onBarClick );
				_progBar.removeEventListener( MouseEvent.CLICK, onBarClick );
			}
		}
		
		
		/**
		 * Methods
		 * 
		 */
		
		
		/** Overriden */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if( height == 0 ) height = _defaultHeight;
			if( width == 0 ) width = _barWidth + 10;
			if( width > _barWidth ) _barWidth = width - 10;
			
			createBG( _bg, width, height );
			
			this.graphics.clear();
			
			createBox( _bar, _barColor, _barWidth, _barHeight );
			_bar.y = height/2 - _bar.height/2;
			_bar.x = width/2 - _bar.width/2;
			addChild( _bar );
			
			
			createBox( _loadedBar, _loadedColor, 1, _barHeight );
			_loadedBar.x = _bar.x;
			_loadedBar.y = _bar.y;
			addChild( _loadedBar );
			
			
			createBox( _progBar, _progColor, 1, _barHeight );
			_progBar.x = _bar.x;
			_progBar.y = _bar.y;
			addChild( _progBar );
			
			
			createBox( _scrubber, _scrubberColor, _barHeight, _barHeight, true, 0xefefef );
			_defaultX = _scrubber.x = _bar.x;
			_defaultY = _scrubber.y = height/2 - _scrubber.height/2;
			addChild( _scrubber );
			
			
			_minX = _scrubber.x;
			_maxX = _bar.x + _bar.width - _scrubber.width;
		}
		
		private function onBarClick( e:MouseEvent ) : void
		{
			// This pauses video before seek
			this.dispatchEvent( new ScrubberBarEvent( ScrubberBarEvent.SCRUBBER_DRAGGING ) );
			
			var _x:Number = mouseX;
			
			if( _x > ( _bar.x + _bar.width - _scrubber.width ) ) _x = _bar.x + _bar.width - _scrubber.width;
			
			var a1:AnimateProperty = new AnimateProperty();
			a1.target = _scrubber;
			a1.property = "x";
			a1.toValue = _x;
			a1.duration = 250;
			a1.play();
			a1.addEventListener( EffectEvent.EFFECT_END, scrubberChanged );
			
			var a2:AnimateProperty = new AnimateProperty();
			a2.target = _progBar;
			a2.property = "width";
			a2.toValue = _x - _scrubber.width/2;
			a2.duration = 250;
			a2.play();
		}
		
		private function scrubberChanged( e:EffectEvent = null ) : void
		{
			this.dispatchEvent( new ScrubberBarEvent( ScrubberBarEvent.SCRUBBER_DROPPED ) );
		}
		
		
		private function onScrubberDrag( e:MouseEvent ):void
		{
			_dragging = true;
			this.dispatchEvent( new ScrubberBarEvent( ScrubberBarEvent.SCRUBBER_DRAGGING ) );
			this.parentApplication.addEventListener( MouseEvent.MOUSE_UP, onScrubberStopDrag );
			_scrubber.startDrag( false, new Rectangle( _bar.x, _defaultY, ( _bar.width - _scrubber.width ), 0 ) );
			
			addEventListener( Event.ENTER_FRAME, updateProgWidth );
		}
		
		private function onScrubberStopDrag( e:MouseEvent ):void
		{
			this.dispatchEvent( new ScrubberBarEvent( ScrubberBarEvent.SCRUBBER_DROPPED ) );
			
			_dragging = false;
			
			this.parentApplication.removeEventListener( MouseEvent.MOUSE_UP, onScrubberStopDrag );
			this.removeEventListener( Event.ENTER_FRAME, updateProgWidth );
			
			_scrubber.stopDrag();
			
			updateProgWidth( );
		}
		
		
		private function updateProgWidth( e:Event = null ):void
		{
			_progBar.width = _scrubber.x - _defaultX;
		}
		
		
		
		private function createBox( b:Sprite, color:Object, bWidth:Number, bHeight:Number, border:Boolean = false, borderColor:uint = 0, borderSize:Number = 1 ):void
		{
			b.graphics.beginFill( color as uint );
			if( border ) b.graphics.lineStyle( borderSize, borderColor );
			b.graphics.drawRect( 0, 0, bWidth, bHeight );
			b.graphics.endFill();
		}
		
		
		private function createBG( _bg:Sprite, bgWidth:Number, bgHeight:Number ):void
		{
			_bg.graphics.beginFill( 0x343434 );
			_bg.graphics.drawRect( 0, 0, bgWidth, bgHeight );
			_bg.graphics.endFill();
			
			addChild( _bg );
		}
		
		
		public function updateProgress( seconds:Number, duration:Number ):void
		{
			if( !_dragging ) _scrubber.x = ( seconds / duration ) * ( _bar.width-_scrubber.width ) + _defaultX;
			if( !_dragging ) _progBar.width = ( seconds / duration ) * _bar.width;
		}
		
		
		public function updateLoaded( totalLoaded:Number ):void
		{
			_loadedBar.width = totalLoaded * _bar.width;
		}
		
		
		public function seekPosition( duration:Number ):Number
		{
			return Math.floor( ( _scrubber.x / ( _bar.width - _scrubber.width ) ) * duration );
		}
		
	}
}