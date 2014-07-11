package components.videoSlice
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.utils.Timer;
	
	import model.DataModel;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.HSlider;
	import mx.controls.Label;
	import mx.controls.SWFLoader;
	import mx.controls.TextInput;
	import mx.controls.sliderClasses.SliderThumb;
	
	
	public class AS3Player extends Canvas
	{
		
		
		/*Copyright 2009 Google Inc.
		
		Licensed under the Apache License, Version 2.0 (the "License");
		you may not use this file except in compliance with the License.
		You may obtain a copy of the License at
		
		http://www.apache.org/licenses/LICENSE-2.0
		
		Unless required by applicable law or agreed to in writing, software
		distributed under the License is distributed on an "AS IS" BASIS,
		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		See the License for the specific language governing permissions and
		limitations under the License.
		*/
		
		/*Code extracted from Youtube's AS3 chromeless videoplayer API. Contains modifications to suit 
		BabeliumProject's needs*/
		
		// Member variables.
		//private var cueButton:Button;
		//private var isQualityPopulated:Boolean;
		private var isWidescreen:Boolean;
		private var pauseButton:Button;
		private var playButton:Button;
		private var recordButton:Button;
		private var stopRecButton:Button;
		private var createSliceButton:Button;
		private var playSliceButton:Button;
		private var player:Object;
		private var playerLoader:SWFLoader;
		//private var qualityComboBox:ComboBox;
		private var videoIdTextInput:TextInput;
		private var youtubeApiLoader:URLLoader;
		private var YOUTUBE_VIDEO_ID:String;
		private var hslider:HSlider;
		private var cTimeLbl:Label;
		private var tTimeLbl:Label;
		private var spacerLbl:Label;
		private var _myTimer:Timer;
		private var sliceStopTime:int;
		private var sliceStopFlag:Boolean;
		
		
		// CONSTANTS.
		private static const PLAYER_URL:String =
			"http://www.youtube.com/apiplayer?version=3";
		private static const SECURITY_DOMAIN:String = "http://www.youtube.com";
		private static const YOUTUBE_API_PREFIX:String =
			"http://gdata.youtube.com/feeds/api/videos/";
		private static const YOUTUBE_API_VERSION:String = "2";
		private static const YOUTUBE_API_FORMAT:String = "5";
		private static const WIDESCREEN_ASPECT_RATIO:String = "widescreen";
		private static const QUALITY_TO_PLAYER_WIDTH:Object = {
			small: 320,
			medium: 640,
			large: 854,
			hd720: 1280,
			custom: 420
		};
		private static const STATE_ENDED:Number = 0;
		private static const STATE_PLAYING:Number = 1;
		private static const STATE_PAUSED:Number = 2;
		private static const STATE_CUED:Number = 5;
		
		public function AS3Player():void {
			// Specifically allow the chromless player .swf access to our .swf.
			Security.allowDomain(SECURITY_DOMAIN);
			
			/* Ya no construimos aqui, sino en la llamada a la funcion setYoutubeVideoId
			setupUi();
			setupPlayerLoader();
			setupYouTubeApiLoader();
			*/
		}
		
		private function setupUi():void {
			
			//Update slide bar timer
			_myTimer = new Timer(250, 0);
			_myTimer.addEventListener(TimerEvent.TIMER, timerHandler);
			
			sliceStopFlag = false;
			
			// Create a TextInput field for the YouTube video id, and pre-populate it.
			/*videoIdTextInput = new TextInput();
			videoIdTextInput.text = YOUTUBE_VIDEO_ID;
			videoIdTextInput.width = 100;
			videoIdTextInput.x = 0;
			videoIdTextInput.y = 10;
			addChild(videoIdTextInput);*/
			
			// Create a Button for cueing up the video whose id is specified.
			/*cueButton = new Button();
			cueButton.enabled = false;
			cueButton.label = resourceManager.getString("myResources","CUEVIDEO");
			cueButton.width = 100;
			cueButton.x = 110;
			cueButton.y = 10;
			cueButton.addEventListener(MouseEvent.CLICK, cueButtonClickHandler);
			addChild(cueButton);*/
			
			// Create a ComboBox that will contain the list of available playback
			// qualities. Selecting from the ComboBox will change the playback quality
			// and resize the player. Note that playback qualities are only available
			// once a video has started playing, so the values in this ComboBox can't
			// be populated until then.
			/*qualityComboBox = new ComboBox();
			qualityComboBox.prompt = "n/a";
			qualityComboBox.width = 100;
			qualityComboBox.x = 230;
			qualityComboBox.y = 10;
			qualityComboBox.addEventListener(ListEvent.CHANGE,
			qualityComboBoxChangeHandler);
			addChild(qualityComboBox);*/
			
			// Create a Button for playing the cued video.
			playButton = new Button();
			playButton.enabled = false;
			playButton.label = "Play";
			playButton.width = 80;
			playButton.x = 440;
			playButton.y = 10;
			playButton.addEventListener(MouseEvent.CLICK, playButtonClickHandler);
			addChild(playButton);
			
			// Create a Button for pausing the cued video.
			pauseButton = new Button();
			pauseButton.enabled = false;
			pauseButton.label = "Pause";
			pauseButton.width = 80;
			pauseButton.x = 440;
			pauseButton.y = 45;
			pauseButton.addEventListener(MouseEvent.CLICK, pauseButtonClickHandler);
			addChild(pauseButton);
			
			// Create a Button for starting the slice recording process
			recordButton = new Button();
			recordButton.enabled = false;
			recordButton.label = "Rec";
			recordButton.width = 80;
			recordButton.x = 440;
			recordButton.y = 80;
			recordButton.addEventListener(MouseEvent.CLICK, recordButtonClickHandler);
			addChild(recordButton);
			
			// Create a Button for stopping the slice recording process
			stopRecButton = new Button();
			stopRecButton.enabled = false;
			stopRecButton.visible = false;
			stopRecButton.label = "Stop";
			stopRecButton.width = 80;
			stopRecButton.x = 440;
			stopRecButton.y = 80;
			stopRecButton.addEventListener(MouseEvent.CLICK, stopRecButtonClickHandler);
			addChild(stopRecButton);
			
			//Create a Button for confirmation of the slicing process creation
			createSliceButton = new Button();
			createSliceButton.enabled = false;
			createSliceButton.visible = true;
			createSliceButton.label = resourceManager.getString("myResources","CREATE");
			createSliceButton.width = 95;
			createSliceButton.height = 50;
			createSliceButton.x = 433;
			createSliceButton.y = 130;
			createSliceButton.addEventListener(MouseEvent.CLICK, createSliceButtonClickHandler);
			addChild(createSliceButton);
			
			// Create a Button for playing the current slice.
			playSliceButton = new Button();
			playSliceButton.enabled = false;
			playSliceButton.label = resourceManager.getString("myResources","PLAYSLICE");
			playSliceButton.width = 80;
			playSliceButton.x = 440;
			playSliceButton.y = 195;
			playSliceButton.addEventListener(MouseEvent.CLICK, playSliceButtonClickHandler);
			addChild(playSliceButton);
			
			//Create Time labels
			cTimeLbl = new Label();
			cTimeLbl.width = 40;
			cTimeLbl.x = 335;
			cTimeLbl.y = 335;
			cTimeLbl.text = "00:00";
			cTimeLbl.visible = false;
			
			spacerLbl = new Label();
			spacerLbl.text = "/";
			spacerLbl.width = 10;
			spacerLbl.x = 370;
			spacerLbl.y = 335;
			spacerLbl.visible = false;
			
			tTimeLbl = new Label();
			tTimeLbl.width = 40;
			tTimeLbl.x = 380;
			tTimeLbl.y = 335;
			tTimeLbl.text = "00:00";
			tTimeLbl.visible = false;
			
			addChild(cTimeLbl);
			addChild(spacerLbl);
			addChild(tTimeLbl);
			
			// Create the Horizontal time slider
			hslider = new HSlider();
			hslider.x = 0;
			hslider.y = 345;
			hslider.width = 420;
			hslider.height = 16;
			hslider.allowTrackClick = true;
			hslider.showDataTip = false;
			hslider.minimum = 0;
			hslider.maximum = 420;
			hslider.mouseEnabled = true;  
			hslider.visible = false;
			addChild(hslider);
			
		}
		
		private function setupPlayerLoader():void {
			playerLoader = new SWFLoader();
			playerLoader.addEventListener(Event.INIT, playerLoaderInitHandler);
			playerLoader.load(PLAYER_URL);
		}
		
		private function playerLoaderInitHandler(event:Event):void {
			addChild(playerLoader);
			playerLoader.content.addEventListener("onReady", onPlayerReady);
			playerLoader.content.addEventListener("onError", onPlayerError);
			playerLoader.content.addEventListener("onStateChange",
				onPlayerStateChange);
			//playerLoader.content.addEventListener("onPlaybackQualityChange",
			//                                      onVideoPlaybackQualityChange);
		}
		
		private function setupYouTubeApiLoader():void {
			youtubeApiLoader = new URLLoader();
			youtubeApiLoader.addEventListener(IOErrorEvent.IO_ERROR,
				youtubeApiLoaderErrorHandler);
			youtubeApiLoader.addEventListener(Event.COMPLETE,
				youtubeApiLoaderCompleteHandler);
		}
		
		private function youtubeApiLoaderCompleteHandler(event:Event):void {
			var atomData:String = youtubeApiLoader.data;
			
			// Parse the YouTube API XML response and get the value of the
			// aspectRatio element.
			var atomXml:XML = new XML(atomData);
			var aspectRatios:XMLList = atomXml..*::aspectRatio;
			
			isWidescreen = aspectRatios.toString() == WIDESCREEN_ASPECT_RATIO;
			
			//isQualityPopulated = false;
			// Cue up the video once we know whether it's widescreen.
			// Alternatively, you could start playing instead of cueing with
			//player.loadVideoById(YOUTUBE_VIDEO_ID);
			player.cueVideoById(YOUTUBE_VIDEO_ID);
		}
		
		/*private function qualityComboBoxChangeHandler(event:Event):void {
		var qualityLevel:String = ComboBox(event.target).selectedLabel;
		player.setPlaybackQuality(qualityLevel);
		}*/
		
		private function cueVideoRequest():void {
			var request:URLRequest = new URLRequest(YOUTUBE_API_PREFIX +
				YOUTUBE_VIDEO_ID);
			
			var urlVariables:URLVariables = new URLVariables();
			urlVariables.v = YOUTUBE_API_VERSION;
			urlVariables.format = YOUTUBE_API_FORMAT;
			request.data = urlVariables;
			
			try {
				youtubeApiLoader.load(request);
			} catch (error:SecurityError) {
				trace("A SecurityError occurred while loading", request.url);
			}
		}
		
		private function playButtonClickHandler(event:MouseEvent):void {      
			var th:SliderThumb = hslider.getThumbAt(0);
			th.setStyle("fillColors", ["white","white"]);
			player.playVideo();
			_myTimer.start();
		}
		
		private function pauseButtonClickHandler(event:MouseEvent):void {
			player.pauseVideo();
		}
		
		private function recordButtonClickHandler(event:MouseEvent):void {
			var th:SliderThumb = hslider.getThumbAt(0);
			th.setStyle("fillColors", ["red","red"]);
			
			recordButton.enabled = false;
			recordButton.visible = false;
			stopRecButton.enabled = true;    
			stopRecButton.visible = true;
			createSliceButton.enabled = false;
			playSliceButton.enabled = false; 
			
			DataModel.getInstance().slicePreview = false;
			DataModel.getInstance().tempVideoSlice.start_time = player.getCurrentTime();    
		}
		
		private function stopRecButtonClickHandler(event:MouseEvent):void {
			var th:SliderThumb = hslider.getThumbAt(0);
			th.setStyle("fillColors", ["white","white"]);
			
			stopRecButton.enabled = false;    
			stopRecButton.visible = false;
			recordButton.enabled = true;
			recordButton.visible = true;
			createSliceButton.enabled = true;
			playSliceButton.enabled = true;
			
			sliceStopTime = player.getCurrentTime();
			DataModel.getInstance().tempVideoSlice.duration = sliceStopTime - DataModel.getInstance().tempVideoSlice.start_time;
			
		}
		
		private function createSliceButtonClickHandler(event:MouseEvent):void {
			
			stopRecButton.enabled = false;    
			stopRecButton.visible = false;
			recordButton.enabled = false;
			recordButton.visible = true;
			
			//Use ffmpeg to slice Youtube's video and then show video Slice form
			DataModel.getInstance().slicePreview = true;    
		}
		
		private function playSliceButtonClickHandler(event:MouseEvent):void {           
			var th:SliderThumb = hslider.getThumbAt(0);
			th.setStyle("fillColors", ["green","green"]);
			
			player.playVideo();
			var sTime:Object = DataModel.getInstance().tempVideoSlice.start_time;
			player.seekTo(Number(sTime),true);
			sliceStopFlag = true;
			
		}
		
		private function youtubeApiLoaderErrorHandler(event:IOErrorEvent):void {
			trace("Error making YouTube API request:", event);
		}
		
		private function timerHandler(event:TimerEvent):void {  
			//update time values for all components
			if ( int(player.getCurrentTime()) > -1 ) {
				var cMin:Object = Math.floor( player.getCurrentTime()/60 );
				var cSec:Object = Math.floor( player.getCurrentTime() - ( Number( cMin )*60 ) );
				
				var dMin:Object = Math.floor( player.getDuration()/60 );
				var dSec:Object = Math.floor( player.getDuration() - ( Number( dMin )*60 ) );
				
				if( Number( cSec ) > Number( dSec ) && Number( cMin ) == Number( dMin ) ) cSec = dSec;		
				if( cSec.toString().length == 1 ) cSec = "0" + cSec;
				if( dSec.toString().length == 1 ) dSec = "0" + dSec; 
				
				cTimeLbl.text = cMin + ":" + cSec;
				tTimeLbl.text = dMin + ":" + dSec;
				
				hslider.value = player.getCurrentTime();
				hslider.maximum = player.getDuration();
				
				if (sliceStopFlag == true) {
					//We are previewing the current Slice
					if ( int(player.getCurrentTime()) == sliceStopTime ){
						
						player.pauseVideo();
						sliceStopFlag = false;
					}
				}
			} 
		}
		
		private function onPlayerReady(event:Event):void {
			player = playerLoader.content;
			player.visible = false;
			
			//cueButton.enabled = true;
		}
		
		private function onPlayerError(event:Event):void {
			trace("Player error:", Object(event).data);
		}
		
		private function onPlayerStateChange(event:Event):void {
			trace("State is", Object(event).data);
			
			switch (Object(event).data) {
				case STATE_ENDED:
					playButton.enabled = true;
					pauseButton.enabled = false;
					break;
				
				case STATE_PLAYING:
					playButton.enabled = false;
					pauseButton.enabled = true;
					recordButton.enabled = true;
					
					/*if(!isQualityPopulated) {
					populateQualityComboBox();
					}*/
					break;
				
				case STATE_PAUSED:
					playButton.enabled = true;
					pauseButton.enabled = false;
					recordButton.enabled = false;
					
					break;
				
				case STATE_CUED:
					playButton.enabled = true;
					pauseButton.enabled = false;
					recordButton.enabled = false;
					createSliceButton.enabled = false;
					
					resizePlayer("custom");
					break;
			}
		}
		
		/*private function onVideoPlaybackQualityChange(event:Event):void {
		trace("Current video quality:", Object(event).data);
		resizePlayer(Object(event).data);
		}*/
		
		private function resizePlayer(qualityLevel:String):void {
			var newWidth:Number = QUALITY_TO_PLAYER_WIDTH[qualityLevel] || 640;
			var newHeight:Number;
			
			if (isWidescreen) {
				// Widescreen videos (usually) fit into a 16:9 player.
				newHeight = newWidth * 9 / 16;
			} else {
				// Non-widescreen videos fit into a 4:3 player.
				newHeight = newWidth * 3 / 4;
			}
			
			trace("isWidescreen is", isWidescreen, ". Size:", newWidth, newHeight);
			player.setSize(newWidth, newHeight);
			
			// Center the resized player on the stage.
			//player.x = (stage.stageWidth - newWidth) / 2;
			//player.y = (stage.stageHeight - newHeight) / 2;
			player.x = 0;
			player.y = 10;
			
			player.visible = true;
			
			hslider.visible = true;
			cTimeLbl.visible = true;
			spacerLbl.visible = true;
			tTimeLbl.visible = true;
			
		}
		
		/*private function populateQualityComboBox():void {
		isQualityPopulated = true;
		
		var qualities:Array = player.getAvailableQualityLevels();
		qualityComboBox.dataProvider = qualities;
		
		var currentQuality:String = player.getPlaybackQuality();
		qualityComboBox.selectedItem = currentQuality;
		}*/
		
		public function setYoutubeVideoId (videoId:String):void {
			
			YOUTUBE_VIDEO_ID = videoId;	
			
			setupUi();
			setupPlayerLoader();
			setupYouTubeApiLoader();
			cueVideoRequest();
			
		}
		
		
	}
}