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

	public class AudioSlider extends UIComponent
	{
		
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
		
		private var _bgColor:uint = 0x343434;
		private var _amountColor:uint = 0x008ead;
		private var _sliderAreaColor:uint = 0x000000;
		private var _scrubberColor:uint = 0xababab;
		private var _scruberBorderColor:uint = 0xffffff;
		
		private var _defaultY:Number = 0;
		private var _defaultX:Number = 0;
		
		private var a1:AnimateProperty;
		private var a2:AnimateProperty;
		
		private var _currentVolume:Number = 0.5;
		
		private var _muteBtn:Sprite;
		private var _mutOverBg:Sprite;
		private var _muteOverBgColor:uint = 0x454545;
		private var _muted:Boolean = false;
		private var _mutedX:Number = 0;
		
		
		public function AudioSlider()
		{
			super();
			
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
			_bg.graphics.beginFill( _bgColor );
			_bg.graphics.drawRect( 0, 0, width, height );
			_bg.graphics.endFill();
			
			addChild( _bg );
			
			
			
			// mute button
			_mutOverBg.graphics.beginFill( _muteOverBgColor );
			_mutOverBg.graphics.drawRect( 0, 0, 20, 20 );
			_mutOverBg.graphics.endFill();
			
			addChild( _mutOverBg );
			
			_mutOverBg.alpha = 0;
			
			
			_muteBtn.graphics.beginFill( 0xffffff );
			_muteBtn.graphics.drawRect( 0, 2, 3, 6 );
			_muteBtn.graphics.moveTo( 5, 2 );
			_muteBtn.graphics.lineTo( 9, 0 );
			_muteBtn.graphics.lineTo( 9, 10 );
			_muteBtn.graphics.lineTo( 5, 8 );
			_muteBtn.graphics.endFill();
			
			addChild( _muteBtn );
			
			_muteBtn.x = _mutOverBg.width/2 - _muteBtn.width/2;
			_muteBtn.y = _mutOverBg.height/2 - _muteBtn.height/2;
			
			
			
			// Slider Drag Area
			_sliderArea.graphics.beginFill( _sliderAreaColor );
			_sliderArea.graphics.drawRect( 0, 0, width-30, 10 );
			_sliderArea.graphics.endFill();
			
			addChild( _sliderArea );
			
			_sliderArea.x = width - _sliderArea.width - 5;
			_sliderArea.y = height/2 - _sliderArea.height/2;
			
			
			_amount.graphics.beginFill( _amountColor );
			_amount.graphics.drawRect( 0, 0, 1, 10 );
			_amount.graphics.endFill();
			
			addChild( _amount );
			
			_amount.x = _sliderArea.x;
			_amount.y = _sliderArea.y;
			
			
			
			_scrubber.graphics.beginFill( _scrubberColor );
			_scrubber.graphics.lineStyle( 1, _scruberBorderColor );
			_scrubber.graphics.drawRect( 0, 0, 10, 10 );
			_scrubber.graphics.endFill();
			
			addChild( _scrubber );
			
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