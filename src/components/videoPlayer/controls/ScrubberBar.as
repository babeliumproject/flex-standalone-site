package components.videoPlayer.controls
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;

	import components.videoPlayer.events.ScrubberBarEvent;

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


		public function ScrubberBar()
		{
			super("ScrubberBar"); // Required for setup skinable component

			_bar=new Sprite();
			_progBar=new Sprite();
			_loadedBar=new Sprite();
			_scrubber=new Sprite();
			_bg=new Sprite();
			_marks=new Sprite();

			addChild(_bg);
			addChild(_bar);
			addChild(_marks); // z-index
			addChild(_loadedBar);
			addChild(_progBar);
			addChild(_scrubber);
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
			super.availableProperties([BG_COLOR, BARBG_COLOR, BAR_COLOR, SCRUBBER_COLOR, SCRUBBERBORDER_COLOR, LOADEDBAR_COLOR]);
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

			createBox(_bar, getSkinColor(BARBG_COLOR), _barWidth, _barHeight, false, 0, 0, 0.85);
			_bar.y=height / 2 - _bar.height / 2;
			_bar.x=width / 2 - _bar.width / 2;

			createBox(_loadedBar, getSkinColor(LOADEDBAR_COLOR), 1, _barHeight);
			_loadedBar.x=_bar.x;
			_loadedBar.y=_bar.y;

			createBox(_progBar, getSkinColor(BAR_COLOR), 1, _barHeight, false, 0, 0, 0.65);
			_progBar.x=_bar.x;
			_progBar.y=_bar.y;

			createBox(_scrubber, getSkinColor(SCRUBBER_COLOR), _barHeight + 1, _barHeight + 1, true, getSkinColor(SCRUBBERBORDER_COLOR));
			_defaultX=_scrubber.x=_bar.x;
			_defaultY=_scrubber.y=height / 2 - _scrubber.height / 2;

			_minX=_scrubber.x;
			_maxX=_bar.x + _bar.width - _scrubber.width;

			// set marks
			_marks.graphics.clear();
			for each (var obj:Object in _dataProvider)
			{
				doShowMark(obj.showTime, obj.hideTime, _duration);
			}
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
			_progBar.width=_scrubber.x - _defaultX;
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
				_scrubber.x=(seconds / duration) * (_bar.width - _scrubber.width) + _defaultX;
			if (!_dragging)
				_progBar.width=(seconds / duration) * _bar.width;
		}


		public function updateLoaded(totalLoaded:Number):void
		{
			_loadedBar.width=totalLoaded * _bar.width;
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
			refresh();
		}

		private function doShowMark(startTime:Number, endTime:Number, duration:Number):void
		{
			_marks.graphics.beginFill(getSkinColor(MARKER_COLOR_UP), getSkinColor(MARKER_COLOR_UP_ALPHA));
			//_marks.graphics.drawRect( startTime*(_bar.width-_scrubber.width)/duration+_bar.x+_scrubber.width-2, 2, 2, _defaultHeight-4 );
			_marks.graphics.drawRoundRect(startTime * (_bar.width - _scrubber.width) / duration + _bar.x + _scrubber.width - 2, 2, (endTime - startTime) * (_bar.width) / duration, _defaultHeight - 4, 2);
			_marks.graphics.endFill();
		}

		public function removeMarks():void
		{
			_dataProvider=null;
			refresh();
		}
	}
}
