package components.videoPlayer.controls
{
	import components.videoPlayer.events.ScrubberBarEvent;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;

	public class ScrubberBar extends DictionarySkinnableComponent
	{
		/**
		 * Skin constants
		 */
		public static const BG_COLOR:String="bgColor";
		public static const BARBG_COLOR:String="barBgColor";
		public static const BAR_COLOR:String="barColor";
		public static const SCRUBBER_COLOR:String="scrubberColor";
		public static const SCRUBBERBORDER_COLOR:String="scrubberBorderColor";
		public static const LOADEDBAR_COLOR:String="loadedColor";

		public static const BG_GRADIENT_ANGLE:String="bgGradientAngle";
		public static const BG_GRADIENT_START_COLOR:String="bgGradientStartColor";
		public static const BG_GRADIENT_END_COLOR:String="bgGradientEndColor";
		public static const BG_GRADIENT_START_ALPHA:String="bgGradientStartAlpha";
		public static const BG_GRADIENT_END_ALPHA:String="bgGradientEndAlpha";
		public static const BG_GRADIENT_START_RATIO:String="bgGradientStartRatio";
		public static const BG_GRADIENT_END_RATIO:String="bgGradientEndRatio";
		public static const BORDER_COLOR:String="borderColor";
		public static const BORDER_WEIGHT:String="borderWeight";

		public static const MARKER_COLOR_UP:String="markerColorUp";
		public static const MARKER_COLOR_HOVER:String="markerColorHover";
		public static const MARKER_COLOR_ACTIVE:String="markerColorActive";
		public static const MARKER_COLOR_UP_ALPHA:String="markerColorUpAlpha";
		public static const MARKER_COLOR_HOVER_ALPHA:String="markerColorHoverAlpha";
		public static const MARKER_COLOR_ACTIVE_ALPHA:String="markerColorActiveAlpha";
		public static const MARKER_BORDER_COLOR:String="markerBorderColor";
		public static const MARKER_BORDER_WEIGHT:String="markerBorderWeight";

		private var _bar:Sprite;
		private var _progBar:Sprite;
		private var _loadedBar:Sprite;
		private var _scrubber:Sprite;
		private var _bg:Sprite;
		private var _marks:Sprite;
		private var _marksProg:Sprite;
		private var _marksLoaded:Sprite;

		private var _barWidth:Number=100;
		private var _barHeight:Number=10;

		private var _defaultHeight:Number=20;
		private var _defaultY:Number;
		private var _defaultX:Number;
		private var _maxX:Number;
		private var _minX:Number;
		private var _dragging:Boolean=false;

		private var a1:AnimateProperty;
		private var a2:AnimateProperty;

		private var _dataProvider:Object;
		private var _duration:Number;

		private var _lastScrubberX:Number=0;
		private var _lastProgBarWidth:Number=0;

		public function ScrubberBar()
		{
			//Pass the name of the component to look for its skin properties in the skin dictionary
			super("ScrubberBar");

			_bar=new Sprite();
			_progBar=new Sprite();
			_loadedBar=new Sprite();
			_scrubber=new Sprite();
			_bg=new Sprite();

			_marks=new Sprite();
			_marksProg=new Sprite();
			_marksLoaded=new Sprite();

			addChild(_bg);
			addChild(_bar);

			_bar.addChild(_marks);
			_bar.addChild(_loadedBar);
			_bar.addChild(_marksLoaded);
			_bar.addChild(_progBar);
			_bar.addChild(_marksProg);

			addChild(_scrubber);
		/*
		addChild(_loadedBar);
		addChild(_progBar);

		_bar.addChild(_marks);
		_loadedBar.addChild(_marksLoaded);
		_progBar.addChild(_marksProg);
		*/
		}

		override public function dispose():void
		{
			super.dispose();

			if (_scrubber)
			{
				_scrubber.removeEventListener(MouseEvent.MOUSE_DOWN, onScrubberDrag);
				removeChildSuppressed(_scrubber);
				_scrubber=null;
			}
			if (_bar)
			{
				_bar.removeEventListener(MouseEvent.CLICK, onBarClick);
				removeChildSuppressed(_bar);
				_bar=null;
			}
			if (_progBar)
			{
				_progBar.removeEventListener(MouseEvent.CLICK, onBarClick);
				removeChildSuppressed(_progBar);
				_progBar=null;
			}
			if (a1)
			{
				a1.removeEventListener(EffectEvent.EFFECT_END, scrubberChanged);
				a1.stop();
				a1=null;
			}
			if (a2)
			{
				a2.stop();
				a2=null;
			}

			this.parentApplication.removeEventListener(MouseEvent.MOUSE_UP, onScrubberStopDrag);
			this.removeEventListener(Event.ENTER_FRAME, updateProgWidth);
		}

		override public function availableProperties(obj:Array=null):void
		{
			super.availableProperties([BG_COLOR, BARBG_COLOR, BAR_COLOR, SCRUBBER_COLOR, SCRUBBERBORDER_COLOR, LOADEDBAR_COLOR, BG_GRADIENT_ANGLE, BG_GRADIENT_START_COLOR, BG_GRADIENT_END_COLOR, BG_GRADIENT_START_ALPHA, BG_GRADIENT_END_ALPHA, BG_GRADIENT_START_RATIO, BG_GRADIENT_END_RATIO, BORDER_COLOR, BORDER_WEIGHT, MARKER_COLOR_UP, MARKER_COLOR_HOVER, MARKER_COLOR_ACTIVE, MARKER_COLOR_UP_ALPHA, MARKER_COLOR_HOVER_ALPHA, MARKER_COLOR_ACTIVE_ALPHA, MARKER_BORDER_COLOR, MARKER_BORDER_WEIGHT]);
		}

		public function enableSeek(flag:Boolean):void
		{
			_bar.useHandCursor=flag;
			_bar.buttonMode=flag;

			_progBar.useHandCursor=flag;
			_progBar.buttonMode=flag;

			_scrubber.useHandCursor=flag;
			_scrubber.buttonMode=flag;

			if (flag)
			{
				_scrubber.addEventListener(MouseEvent.MOUSE_DOWN, onScrubberDrag, false, 0, true);
				_bar.addEventListener(MouseEvent.CLICK, onBarClick, false, 0, true);
				_progBar.addEventListener(MouseEvent.CLICK, onBarClick, false, 0, true);
			}
			else
			{
				_scrubber.removeEventListener(MouseEvent.MOUSE_DOWN, onScrubberDrag);
				_bar.removeEventListener(MouseEvent.CLICK, onBarClick);
				_progBar.removeEventListener(MouseEvent.CLICK, onBarClick);
			}
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (height == 0)
				height=_defaultHeight;
			if (width == 0)
				width=_barWidth + 10;
			if (width > _barWidth)
				_barWidth=width - 10;

			createBG(_bg, width, height);

			this.graphics.clear();

			createBox(_bar, getSkinColor(BARBG_COLOR), _barWidth, _barHeight, false);
			_bar.y=height / 2 - _bar.height / 2;
			_bar.x=width / 2 - _bar.width / 2;

			createBox(_loadedBar, getSkinColor(LOADEDBAR_COLOR), 1, _barHeight, false);
			//_loadedBar.x=_bar.x;
			//_loadedBar.y=_bar.y;

			createBox(_progBar, getSkinColor(BAR_COLOR), 1, _barHeight, false);
			//_progBar.x=_bar.x;
			//_progBar.y=_bar.y;

			createBox(_scrubber, getSkinColor(SCRUBBER_COLOR), _barHeight + 1, _barHeight + 1, true, getSkinColor(SCRUBBERBORDER_COLOR));
			_defaultX=_scrubber.x=_bar.x;
			_defaultY=_scrubber.y=height / 2 - _scrubber.height / 2;

			_minX=_scrubber.x;
			_maxX=_bar.x + _bar.width - _scrubber.width;


			drawMarkers(_dataProvider, _marks, _bar.width, _bar.width, _bar.height, _duration, getSkinColor(MARKER_COLOR_UP), getSkinColor(MARKER_COLOR_UP_ALPHA));
			drawMarkers(_dataProvider, _marksLoaded, _loadedBar.width, _bar.width, _bar.height, _duration, getSkinColor(MARKER_COLOR_HOVER), getSkinColor(MARKER_COLOR_HOVER_ALPHA));
			drawMarkers(_dataProvider, _marksProg, _progBar.width, _bar.width, _bar.height, _duration, getSkinColor(MARKER_COLOR_ACTIVE), getSkinColor(MARKER_COLOR_ACTIVE_ALPHA));
		}

		private function onBarClick(e:MouseEvent):void
		{
			// This pauses video before seek
			this.dispatchEvent(new ScrubberBarEvent(ScrubberBarEvent.SCRUBBER_DRAGGING));

			var _x:Number=mouseX;

			if (_x > (_bar.x + _bar.width - _scrubber.width))
				_x=_bar.x + _bar.width - _scrubber.width;

			a1=new AnimateProperty();
			a1.target=_scrubber;
			a1.property="x";
			a1.toValue=_x;
			a1.duration=250;
			a1.play();
			a1.addEventListener(EffectEvent.EFFECT_END, scrubberChanged);

			a2=new AnimateProperty();
			a2.target=_progBar;
			a2.property="width";
			a2.toValue=_x - _scrubber.width / 2;
			a2.duration=250;
			a2.play();
		}

		private function scrubberChanged(e:EffectEvent=null):void
		{
			this.dispatchEvent(new ScrubberBarEvent(ScrubberBarEvent.SCRUBBER_DROPPED));
		}


		private function onScrubberDrag(e:MouseEvent):void
		{
			_dragging=true;
			this.dispatchEvent(new ScrubberBarEvent(ScrubberBarEvent.SCRUBBER_DRAGGING));
			this.parentApplication.addEventListener(MouseEvent.MOUSE_UP, onScrubberStopDrag);

			_scrubber.startDrag(false, new Rectangle(_bar.x, _defaultY, (_bar.width - _scrubber.width), 0));

			addEventListener(Event.ENTER_FRAME, updateProgWidth);
		}

		private function onScrubberStopDrag(e:MouseEvent):void
		{
			this.dispatchEvent(new ScrubberBarEvent(ScrubberBarEvent.SCRUBBER_DROPPED));

			_dragging=false;

			this.parentApplication.removeEventListener(MouseEvent.MOUSE_UP, onScrubberStopDrag);
			this.removeEventListener(Event.ENTER_FRAME, updateProgWidth);

			_scrubber.stopDrag();
			trace("Scrubber stop dragging x:" + _scrubber.x + " :::: scrubberwidth:" + _scrubber.width);
			updateProgWidth();
		}


		private function updateProgWidth(e:Event=null):void
		{
			_lastProgBarWidth=_scrubber.x - _defaultX;
			_progBar.width=_lastProgBarWidth;
		}

		private function createBox(b:Sprite, color:Object, bWidth:Number, bHeight:Number, border:Boolean=false, borderColor:uint=0, borderSize:Number=1, alpha:Number=1):void
		{
			b.graphics.clear();
			b.graphics.beginFill(color as uint, alpha);
			if (border)
				b.graphics.lineStyle(borderSize, borderColor);
			b.graphics.drawRect(0, 0, bWidth, bHeight);
			b.graphics.endFill();
		}


		private function createBG(bg:Sprite, bgWidth:Number, bgHeight:Number):void
		{
			var matr:Matrix=new Matrix();
			matr.createGradientBox(bgHeight, bgHeight, getSkinColor(BG_GRADIENT_ANGLE) * Math.PI / 180, 0, 0);

			var colors:Array=[getSkinColor(BG_GRADIENT_START_COLOR), getSkinColor(BG_GRADIENT_END_COLOR)];
			var alphas:Array=[getSkinColor(BG_GRADIENT_START_ALPHA), getSkinColor(BG_GRADIENT_END_ALPHA)];
			var ratios:Array=[getSkinColor(BG_GRADIENT_START_RATIO), getSkinColor(BG_GRADIENT_END_RATIO)];

			bg.graphics.clear();
			bg.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matr);
			if (getSkinColor(BORDER_WEIGHT) > 0)
				bg.graphics.lineStyle(getSkinColor(BORDER_WEIGHT), getSkinColor(BORDER_COLOR));
			bg.graphics.drawRect(0, 0, bgWidth, bgHeight);
			bg.graphics.endFill();
		}

		/**
		 * Set timeline bar and the scrubber position
		 * @param seconds
		 * @param duration
		 */
		public function updateProgress(seconds:Number, duration:Number):void
		{
			if (!_dragging)
			{
				//Avoid getting out of bounds
				var s:Number = seconds > duration ? duration : seconds;
				
				var _currentScrubberX:Number=(s / duration) * (_bar.width - _scrubber.width) + _defaultX;
				var _currentProgBarWidth:Number=(s / duration) * _bar.width;
				_currentScrubberX=Number(_currentScrubberX.toFixed(0));
				_currentProgBarWidth=Number(_currentProgBarWidth.toFixed(0));

				if (_lastScrubberX != _currentScrubberX)
				{
					_lastScrubberX=_currentScrubberX;
					_scrubber.x=_currentScrubberX;
				}
				if (_lastProgBarWidth != _currentProgBarWidth)
				{
					_lastProgBarWidth=_currentProgBarWidth;
					_progBar.width=_currentProgBarWidth;

					if (_dataProvider)
					{
						drawMarkers(_dataProvider, _marksProg, _currentProgBarWidth, _bar.width, _bar.height, _duration, getSkinColor(MARKER_COLOR_ACTIVE), getSkinColor(MARKER_COLOR_ACTIVE_ALPHA));
					}
				}
			}
		}


		public function updateLoaded(totalLoaded:Number):void
		{
			_loadedBar.width=totalLoaded * _bar.width;
			if (_dataProvider)
			{
				drawMarkers(_dataProvider, _marksLoaded, _loadedBar.width, _bar.width, _bar.height, _duration, getSkinColor(MARKER_COLOR_HOVER), getSkinColor(MARKER_COLOR_HOVER_ALPHA));
			}
		}


		public function seekPosition(duration:Number):Number
		{
			//Correct the margin
			var nominalScrubberX:Number=_scrubber.x - _defaultX;

			return Math.floor((nominalScrubberX / (_bar.width - _scrubber.width)) * duration);
		}

		public function setMarks(data:Object, duration:Number):void
		{
			_dataProvider=data;
			_duration=duration;

			//Force to update the display list in the next frame
			invalidateDisplayList();
		}

		public function removeMarks():void
		{
			_dataProvider=null;

			//Force to update the display list in the next frame
			invalidateDisplayList();
		}

		private function drawMarkers(markers:Object, element:Sprite, currenWidth:Number, maxWidth:Number, maxHeight:Number, duration:Number, color:uint, alpha:Number):void
		{
			element.graphics.clear();
			if (!markers)
				return;

			var mOffsetX:Number=_scrubber.width;
			var mOffsetY:Number=0;
			var mHeight:Number=maxHeight;
			var mY:Number=mOffsetY;
			var mEllipseWidth:Number=2;
			var mEllipseHeight:Number=2;

			for each (var obj:Object in markers)
			{
				var startTime:Number=obj.showTime;
				var endTime:Number=obj.hideTime;

				var mX:Number=startTime * (maxWidth - _scrubber.width) / duration + mOffsetX;
				var mWidth:Number=(endTime - startTime) * maxWidth / duration;
				mX=Number(mX.toFixed(0));
				mWidth=Number(mWidth.toFixed(0));

				if (mX < currenWidth)
				{
					if (mX + mWidth > currenWidth)
					{
						mWidth=currenWidth - mX;
					}
					if (!isNaN(mWidth) && mWidth > 0)
					{
						element.graphics.beginFill(color, alpha);
						//element.graphics.drawRoundRect(mX, mY, mWidth, mHeight, mEllipseWidth, mEllipseHeight);
						element.graphics.drawRect(mX, mY, mWidth, mHeight);
						element.graphics.endFill();
					}
				}
				else
				{
					break;
				}
			}
		}
	}
}