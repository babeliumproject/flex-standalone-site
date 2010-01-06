package modules.videoPlayer.controls
{
	import modules.videoPlayer.events.VolumeEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;

	public class AudioSlider extends SkinableComponent
	{
		/**
		 * Skin constants
		 */
		public static const BG_COLOR:String = "bgColor";
		public static const BARBG_COLOR:String = "barBgColor";
		public static const BAR_COLOR:String = "barColor";
		public static const SCRUBBER_COLOR:String = "scrubberColor";
		public static const SCRUBBERBORDER_COLOR:String = "scrubberBorderColor";
		public static const MUTEOVERBG_COLOR:String = "muteOverBgColor";
		public static const MUTE_COLOR:String = "muteColor";
		
		/**
		 * Variables
		 * 
		 */
		
		private var _defaultWidth:Number = 120;
		private var _defaultHeight:Number = 20;
		
		private var _bg:Sprite;
		private var _sliderArea:Sprite;
		private var _amount:Sprite;
		private var _scrubber:Sprite;
		
		private var _defaultY:Number = 0;
		private var _defaultX:Number = 0;
		
		private var a1:AnimateProperty;
		private var a2:AnimateProperty;
		
		private var _currentVolume:Number = 0.5;
		
		private var _muteBtn:Sprite;
		private var _mutOverBg:Sprite;
		private var _muted:Boolean = false;
		private var _mutedX:Number = 0;
		
		
		public function AudioSlider()
		{
			super("AudioSlider");
			
			width = _defaultWidth;
			height = _defaultHeight;
			
			_bg = new Sprite();
			
			_sliderArea = new Sprite();
			
			_amount = new Sprite();
			
			_scrubber = new Sprite();
			_scrubber.useHandCursor = true;
			_scrubber.buttonMode = true;
			
			_muteBtn = new Sprite();
			_muteBtn.useHandCursor = true;
			_muteBtn.buttonMode = true;
			
			_mutOverBg = new Sprite();
			_mutOverBg.useHandCursor = true;
			_mutOverBg.buttonMode = true;
			
			addChild( _bg );
			addChild( _mutOverBg );
			addChild( _muteBtn );
			addChild( _sliderArea );
			addChild( _amount );
			addChild( _scrubber );
			
			
			//EventListeners
			
			_scrubber.addEventListener( MouseEvent.MOUSE_DOWN, onScrubberMouseDown );
			_sliderArea.addEventListener( MouseEvent.CLICK, onAreaClick );
			_amount.addEventListener( MouseEvent.CLICK, onAreaClick );
			_muteBtn.addEventListener( MouseEvent.MOUSE_OVER, muteOver );
			_mutOverBg.addEventListener( MouseEvent.MOUSE_OVER, muteOver );
			_muteBtn.addEventListener( MouseEvent.MOUSE_OUT, muteOut );
			_mutOverBg.addEventListener( MouseEvent.MOUSE_OUT, muteOut );
			_muteBtn.addEventListener( MouseEvent.CLICK, muteClicked );
			_mutOverBg.addEventListener( MouseEvent.CLICK, muteClicked );
		}
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BG_COLOR,BARBG_COLOR,BAR_COLOR,SCRUBBER_COLOR,
							SCRUBBERBORDER_COLOR,MUTE_COLOR,MUTEOVERBG_COLOR]);
		}
		
		
		/**
		 * Getters and Setters
		 * 
		 */
		public function getCurrentVolume( ):Number
		{
			return _currentVolume;
		}		
		
		
		/** 
		 * Methods
		 * 
		 */
		
		
		/** Overriden */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if( width == 0 ) width = _defaultWidth;
			if( height == 0 ) height = _defaultHeight;
			
			// Create Background
			_bg.graphics.clear();
			_bg.graphics.beginFill( getSkinColor(BG_COLOR) );
			_bg.graphics.drawRect( 0, 0, width, height );
			_bg.graphics.endFill();			
			
			// mute button
			_mutOverBg.graphics.clear();
			_mutOverBg.graphics.beginFill( getSkinColor(MUTEOVERBG_COLOR) );
			_mutOverBg.graphics.drawRect( 0, 0, 20, 20 );
			_mutOverBg.graphics.endFill();
			
			_mutOverBg.alpha = 0;
			
			_muteBtn.graphics.clear();
			_muteBtn.graphics.beginFill( getSkinColor(MUTE_COLOR) );
			_muteBtn.graphics.drawRect( 0, 2, 3, 6 );
			_muteBtn.graphics.moveTo( 5, 2 );
			_muteBtn.graphics.lineTo( 9, 0 );
			_muteBtn.graphics.lineTo( 9, 10 );
			_muteBtn.graphics.lineTo( 5, 8 );
			_muteBtn.graphics.endFill();
			
			_muteBtn.x = _mutOverBg.width/2 - _muteBtn.width/2;
			_muteBtn.y = _mutOverBg.height/2 - _muteBtn.height/2;
			
			
			
			// Slider Drag Area
			_sliderArea.graphics.clear();
			_sliderArea.graphics.beginFill( getSkinColor(BARBG_COLOR) );
			_sliderArea.graphics.drawRect( 0, 0, width-30, 10 );
			_sliderArea.graphics.endFill();
			
			_sliderArea.x = width - _sliderArea.width - 5;
			_sliderArea.y = height/2 - _sliderArea.height/2;
			
			_amount.graphics.clear();
			_amount.graphics.beginFill( getSkinColor(BAR_COLOR) );
			_amount.graphics.drawRect( 0, 0, 1, 10 );
			_amount.graphics.endFill();
			
			_amount.x = _sliderArea.x;
			_amount.y = _sliderArea.y;
			
			_scrubber.graphics.clear();
			_scrubber.graphics.beginFill( getSkinColor(SCRUBBER_COLOR) );
			_scrubber.graphics.lineStyle( 1, getSkinColor(SCRUBBERBORDER_COLOR) );
			_scrubber.graphics.drawRect( 0, 0, 10, 10 );
			_scrubber.graphics.endFill();
			
			_defaultX = _sliderArea.x;
			_defaultY = _scrubber.y = height/2 - _scrubber.height/2;
			
			_scrubber.x = _sliderArea.width/2 + _sliderArea.x - _scrubber.width/2;
			_amount.width = _sliderArea.width/2 - _scrubber.width/2;
			
		}
		
		
		private function onScrubberMouseDown( e:MouseEvent ):void
		{
			addEventListener( Event.ENTER_FRAME, updateAmount );
			
			_scrubber.startDrag( false, new Rectangle( _sliderArea.x, _defaultY, _sliderArea.width - _scrubber.width, 0 ) );
			
			this.parentApplication.addEventListener( MouseEvent.MOUSE_UP, onScrubberDrop );
		}
		
		
		private function onScrubberDrop( e:MouseEvent ):void
		{
			_muted = false;
			
			this.parentApplication.removeEventListener( MouseEvent.MOUSE_UP, onScrubberDrop );
			
			_scrubber.stopDrag();
			
			removeEventListener( Event.ENTER_FRAME, updateAmount );
			
			volumeChanged();
			
			updateAmount();
		}
		
		
		private function updateAmount( e:Event = null ):void
		{
			_amount.width = _scrubber.x - _defaultX;
		}
		
		
		private function onAreaClick( e:MouseEvent ):void
		{
			var _x:Number = mouseX;
			
			if( _x > ( _sliderArea.x + _sliderArea.width - _scrubber.width ) ) _x = _sliderArea.x + _sliderArea.width - _scrubber.width;
			
			
			a1 = new AnimateProperty();
			a1.target = _scrubber;
			a1.property = "x";
			a1.toValue = _x;
			a1.duration = 250;
			a1.play();
			a1.addEventListener( EffectEvent.EFFECT_END, volumeChanged );
			
			a2 = new AnimateProperty();
			a2.target = _amount;
			a2.property = "width";
			a2.toValue = _x - _defaultX;
			a2.duration = 250;
			a2.play();
			
		}
		
		
		private function volumeChanged( e:EffectEvent = null ):void
		{
			_currentVolume = _amount.width / ( _sliderArea.width - _scrubber.width );
			
			dispatchEvent( new VolumeEvent( VolumeEvent.VOLUME_CHANGED, _currentVolume ) );
		}
		
		
		private function muteOver( e:MouseEvent ):void
		{
			_mutOverBg.alpha = 1;
		}
		
		
		private function muteOut( e:MouseEvent ):void
		{
			_mutOverBg.alpha = 0;
		}
		
		
		private function muteClicked( e:MouseEvent ):void
		{
			var _x:Number = _muted == true ? _mutedX : _defaultX;
			
			if( _currentVolume == 0 && !_muted ) 
			{
				_x = _defaultX + _sliderArea.width/2 - _scrubber.width;
				_currentVolume = 0.5;
				_muted = true;
			}
			
			if( !_muted ) _mutedX = _scrubber.x;
			
			a1 = new AnimateProperty();
			a1.target = _scrubber;
			a1.property = "x";
			a1.toValue = _x;
			a1.duration = 250;
			a1.play();
			a1.addEventListener( EffectEvent.EFFECT_END, function( e:EffectEvent ):void
			{
				if( _muted )
				{
					dispatchEvent( new VolumeEvent( VolumeEvent.VOLUME_CHANGED, _currentVolume ) );
					_muted = false;
					
				} else
				{
					dispatchEvent( new VolumeEvent( VolumeEvent.VOLUME_CHANGED, 0 ) );
					_muted = true;
				}
				
			} );
			
			a2 = new AnimateProperty();
			a2.target = _amount;
			a2.property = "width";
			a2.toValue = _x - _defaultX;
			a2.duration = 250;
			a2.play();
		}
		
	}
}