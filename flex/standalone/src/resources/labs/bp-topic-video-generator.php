<?php 

require_once 'services/utils/SessionValidation.php';

//session_start();
//if(!isset($_SESSION['logged']) || $_SESSION['logged'] == false){
//	header('Location: http://'.$_SERVER['SERVER_NAME'].'/bp-login.php');
//} else {

try{
   $service = new SessionValidation(true);
}catch(Exception $e){
   header('Location: http://'.$_SERVER['SERVER_NAME'].'/bp-login.php');
}

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
<head>
<title>Babelium Project: Video Topic Generator</title>
<script type="text/javascript" src="js/jquery1.5.1.js"></script>
<script type="text/javascript" src="js/jquery-ui-1.8.13.custom.min.js"></script>
<script type="text/javascript"
	src="js/infinitecarousel/jquery.infinitecarousel2.js"></script>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name='robots' content='noindex,nofollow' />

<!--
<link rel='stylesheet' id='login-css' href='css/login.css'
	type='text/css' media='all' />-->
<link type="text/css" href="css/jquery-ui-1.8.13.custom.css"
	rel="stylesheet" />

<style type="text/css">

*{
  margin:0;
  padding:0;
}

#gallery {
	float: none;
	/*width: 90%;*/
	min-height: 12em;
}

body{
  font:11px "Lucida Grande",Verdana,Arial,"Bitstream Vera Sans",sans-serif;
  background-image: -webkit-gradient(
    linear,
    left top,
    right top,
    color-stop(0.25, rgb(229,236,242)),
    color-stop(0.5, rgb(249,249,249)),
    color-stop(1, rgb(229,236,242))
	);
	background-image: -moz-linear-gradient(
    left center,
    rgb(229,236,242) 25%,
    rgb(249,249,249) 50%,
    rgb(229,236,242) 100%
	);
  
}

#header{
	background: url("./themes/babelium/images/pattern2.png");
	display: block;
	margin-top: 0;
	padding: 16px;
	border-bottom: 1px solid #38BABC;
}

#header h1{
	color: #972C0A;
	padding-bottom: 10px;
}

.h2{
	color: #268caa;
	text-decoration: underline;
	padding-bottom: 16px;
	padding-top: 16px;
}

.stepContent{
	padding: 16px;
}

.nextStep{
	background: #ffffff;
	border-top: 1px solid #38BABC;
	display: block;
	padding: 4px 16px;
}

.nextStep div{
	/*float: right;*/
	background: inherit;
}

.input{
  font-size:16px;
  padding:3px;
  margin-top:2px;
  margin-right:6px;
  margin-bottom:16px;
  border:1px solid #92D3D5;
  background:#fbfbfb;
  width: 300px;
}
input{
  color:#555;
}

select{
  font-size:16px;
  padding:3px;
  margin-top:2px;
  margin-right:6px;
  margin-bottom:16px;
  border:1px solid #92D3D5;
  background:#fbfbfb;
}

#dataForm{
	border: 1px solid #92D3D5;
	padding: 16px;
}

.formLabel{
	width: 250px;
	font-size: 14px;
	display: block;
	float:left;
	text-align:right;
	margin-right: 8px;
}

#videoHolder{
   display: block;
   margin-right: auto;
   margin-left: auto;
   padding: 16px;
}

* html #gallery {
	height: 12em;
} /* IE6 */
.gallery.custom-state-active {
	background: #eee;
}

.gallery li {
	float: left;
	/*width: 100px;*/
	width: 155px;
	height: 155px;
	padding: 0.4em;
	margin: 0 0.4em 0.4em 0;
	text-align: center;
}

.gallery li h5 {
	margin: 0 0 0.4em;
	cursor: move;
}

.gallery li a {
	float: right;
}

.gallery li a.ui-icon-zoomin {
	float: left;
}

.gallery li img { /*width: 100%;*/
	cursor: move;
}

#trash {
	min-height: 20em;
	margin: 16px 16px 16px 16px;
}

* html #trash { /*height: 20em; */
	
} /* IE6 */
#trash h4 {
	line-height: 20px;
	margin: 0 0 0.4em;
}

#trash h4 .ui-icon {
	float: left;
}

#trash .gallery h5 {
	display: none;
}

#feedback {
	font-size: 1.4em;
}

#selectable .ui-selecting {
	background: #FECA40;
}

#selectable .ui-selected {
	background: #F39814;
	color: white;
}

#selectable {
	list-style-type: none;
	/*margin: 0;
		padding: 0;*/
}

#selectable li {
	float: left;
	margin: 3px;
	padding: 0.4em;
	font-size: 1.4em;
	height: 18px;
	cursor: move;
}
</style>

<script type="text/javascript">

/*
function wp_attempt_focus(){
	setTimeout( function(){ 
			try{
			d = document.getElementById('gImageSearchTxtf');
			d.focus();
			d.select();
			} catch(e){
			}
			}, 200);
}

wp_attempt_focus();
*/

$(document).ready(function(){

		var gImages;
		var videoGenerated = false;
		var videoSaved = false;
		var videoPath;
		function createCarousel(){
		
			$('#carousel').infiniteCarousel({
				textholderHeight : .25,
				displayProgressBar : false,
				thumbnailWidth: '120px',
				thumbnailHeight: '90px',
				autoStart: false,
				showControls: true
			});
			//$('#drop-carousel').droppable();
		}

		$('#noSlideDialog').dialog({
			buttons: { "Ok": function() { $(this).dialog("close"); } },
			autoOpen: false,
			modal: true,
			draggable: false,
			title: 'No slides were added to the slideshow',
			resizable: false
		});

		$('#saveSlideDialog').dialog({
			autoOpen: false,
			title: 'Generating video',
			modal: true,
			draggable: false,
			resizable: false,
			beforeClose: function(event, ui) { return videoGenerated; }
			
		});

		$('#saveVideoDialog').dialog({
			autoOpen: false,
			title: 'Saving video data',
			modal: true,
			draggable: false,
			resizable: false,
			beforeClose: function(event, ui) { return videoSaved; }
			
		});

		$('#secondStep').hide();
		$('#thirdStep').hide();
	
		$('#gImageSearchTxtf').keypress(function (event) {
			var value = $(this).val();
			var key=event.keyCode || event.which; 
			if (key==13){
			gImagesQuery(value);
			}	
			}).keypress();
		$('#gImageSearchBtn').click(function (event) {
			var value = $('#gImageSearchTxtf').val();
			gImagesQuery(value);
			searchTopicRelatedWords(value);
		});

		/*
		$('#addWordBtn').click(function (event){
			var value = $('#addWordInput').val();
			var html = '<li class="ui-widget-content ui-draggable">'+trim(value)+'</li>';
			alert(html);
			$("#selectable").append(html);
		});
		*/

		
		/*
		   $.getJSON("http://api.flickr.com/services/feeds/photos_public.gne?tags=cat&tagmode=any&format=json&jsoncallback=?",function(data){
		   $.each(data.items, function(i,item){
		   $("<img/>").attr("src", item.media.m).appendTo("#images");
		   if ( i == 3 ) return false;
		   });
		   });
		 */
		 
		function gImagesQuery(query){
			var server = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&";
			var arg_imgtype = "imgtype=photo";
			var arg_resultperpage = "rsz=8";
			var start_page="";
			var query_string = server + arg_imgtype + '&' + arg_resultperpage + '&q=' + query + '&callback=?';
			$.getJSON(query_string, function(data){
					$("#gImageSearchResults").empty();
					var html = '<div id="trash" class="ui-widget-content ui-state-default"><h4 class="ui-widget-header">Drag items here</h4></div>';
					html += '<h2 class="h2">Images related to the provided topic</h2>';
					html += '<input type="submit" id="addBlankImageBtn" class="button-primary" value="Add Blank Image"/>';
					html += '<ul id="gallery" class="gallery ui-helper-reset ui-helper-clearfix">';
					
					gImages = data.responseData.results;
					$.each(data.responseData.results, function(i,results){
						html += '<li id="'+results.imageId+'" class="ui-widget-content ui-corner-tr"><div><img src="'+results.tbUrl+'" width="'+results.tbWidth+'" height="'+results.tbHeight+' "/>';
						html += '</div></li>';
						//html += '<a href="'+results.url+'">Image</a></div></li>';
						});
					html +='</ul>';
					$("#gImageSearchResults").append(html);
					buildDraggableImageGallery();
					addBlankImageClickHandler();
			});
		}

		//For the time being we'll webscrap cambridge's online dictionaries, since they provide a smart thesaurus
		function searchTopicRelatedWords(query){
			var server = "bp-tvg-backend.php?action=querydictionary&query=";
			//Strip the query from unnecessary symbols, replace the whitespaces with - character
			var filtered_query = query.replace(" ", "-");
			var query_string = server + filtered_query;
			$("#cambridgeSearchResults").empty();
			$.getJSON(query_string, function(data){
				parseCambridgePage(data);
			}).success(function() { 
				//alert("second success"); 
			}).error(function() { 
				var html = '<h2 class="h2">Words/phrases related to the provided topic</h2>';
				html += '<label>Add new text:</label><input type="text" id="addWordInput" class="input" value="" size="20"/><input type="submit" id="addWordBtn" class="button-primary" value="Add word"/></label>';
				html += '<ol id="selectable" class="ui-helper-reset ui-helper-clearfix"></ol>';
				$("#cambridgeSearchResults").append(html);
				buildDraggableWordList();
				addWordClickHandler();
			});
		}

		function parseCambridgePage(result){
			//What happens when the topic is not found
			var html = '<h2 class="h2">Words/phrases related to the provided topic</h2>';
			html += '<label>Add new text:<input type="text" id="addWordInput" class="input" value="" size="20"/><input type="submit" id="addWordBtn" class="button-primary" value="Add word"/></label>';
			html += '<ol id="selectable" class="ui-helper-reset ui-helper-clearfix">';
			$.each(result, function(i,results){	
				html += '<li class="ui-widget-content"><div>'+results+'</div></li>';
			});
			html += '</ol>';
			
			$("#cambridgeSearchResults").append(html);
			buildDraggableWordList();
			addWordClickHandler();
			//What happens if more precise hits are found?

			//If the topic is concrete-most webscrap the related words
		}

		function addWordClickHandler(){
			$('#addWordBtn').click(function (event){
				var value = $('#addWordInput').val();
				var html = '<li class="ui-widget-content"><div>'+value+'<div></li>';
				$("#selectable").append(html);
				//Make the added words draggable as well
				makeWordsDraggable();
			});
		}

		function addBlankImageClickHandler(){
			$('#addBlankImageBtn').click(function (event){
				var html = '<li class="ui-widget-content ui-corner-tr"><div></div></li>';
				 $('#gallery').append(html);
				 makeImagesDraggable();
			});
		}

		function makeWordsDraggable(){
			var $words = $('#selectable');
			$('li',$words).draggable({
				cancel: 'a.ui-icon',// clicking an icon won't initiate dragging
				revert: 'invalid', // when not dropped, the item will revert back to its initial position
				containment: $('#demo-frame').length ? '#demo-frame' : 'document', // stick to demo-frame if present
				helper: 'clone',
				cursor: 'move'
			});
		}

		function makeImagesDraggable(){
			var $gallery = $('#gallery'), $trash = $('#trash');
			$('li',$gallery).draggable({
				cancel: 'a.ui-icon',// clicking an icon won't initiate dragging
				revert: 'invalid', // when not dropped, the item will revert back to its initial position
				containment: $('#demo-frame').length ? '#demo-frame' : 'document', // stick to demo-frame if present
				helper: 'clone',
				cursor: 'move'
			});
		}

		function buildDraggableWordList(){
			var $words = $('#selectable');
			$('li',$words).draggable({
				cancel: 'a.ui-icon',// clicking an icon won't initiate dragging
				revert: 'invalid', // when not dropped, the item will revert back to its initial position
				containment: $('#demo-frame').length ? '#demo-frame' : 'document', // stick to demo-frame if present
				helper: 'clone',
				cursor: 'move'
			});

			$words.droppable({
				accept: '#trash li',
				activeClass: 'custom-state-active',
				drop: function(ev, ui) {
					removeItem(ui.draggable);
				}
			});

			function removeItem($item) {
				$item.fadeOut(function() {
				//	$item.find('a.ui-icon-close').remove();
				$item.appendTo($words).fadeIn();
				//	$item.css('width','96px').append(trash_icon).find('img').css('height','72px').end().appendTo($gallery).fadeIn();
				});
			}

			
		}

		function buildDraggableImageGallery() {
			// there's the gallery and the trash
			var $gallery = $('#gallery'), $trash = $('#trash');
			
			
			// let the gallery items be draggable
			$('li',$gallery).draggable({
				cancel: 'a.ui-icon',// clicking an icon won't initiate dragging
				revert: 'invalid', // when not dropped, the item will revert back to its initial position
				containment: $('#demo-frame').length ? '#demo-frame' : 'document', // stick to demo-frame if present
				helper: 'clone',
				cursor: 'move'
			});

			
			// let the trash be droppable, accepting the gallery items
			$trash.droppable({
				accept: 'li',
				activeClass: 'ui-state-highlight',
				drop: function(ev, ui) {
					addItem(ui.draggable);
				}
			});

			// let the gallery be droppable as well, accepting items from the trash
			$gallery.droppable({
				accept: '#trash li',
				activeClass: 'custom-state-active',
				drop: function(ev, ui) {
					removeImage(ui.draggable);
				}
			});

			/*
			function addWord($item){
				$item.fadeOut(function(){
					var $list = $('ul',$trash).length ? $('ul',$trash) : $('<ul class="gallery ui-helper-reset"/>"').appendTo($trash);
					$item.appendTo($list).fadeIn();
				});
			}*/
			

			// image deletion function
			//var remove_icon = '<a href="link/to/recycle/script/when/we/have/js/off" title="Remove image from selection" class="ui-icon ui-icon-close">Remove image</a>';
			function addItem($item) {
				$item.fadeOut(function() {
					var $list = $('ul',$trash).length ? $('ul',$trash) : $('<ul class="gallery ui-helper-reset"/>').appendTo($trash);
					$item.appendTo($list).fadeIn();
					//$item.find('a.ui-icon-plus').remove();
					//$item.append(remove_icon).appendTo($list).fadeIn(function() {
						//$item.animate({ width: '640px' }).find('img').animate({ height: '480px' });
					//});
				});
			}

			// image recycle function
			//var trash_icon = '<a href="link/to/trash/script/when/we/have/js/off" title="Delete this image" class="ui-icon ui-icon-plus">Delete image</a>';
			function removeImage($item) {
				$item.fadeOut(function() {
				//	$item.find('a.ui-icon-close').remove();
				$item.appendTo($gallery).fadeIn();
				//	$item.css('width','96px').append(trash_icon).find('img').css('height','72px').end().appendTo($gallery).fadeIn();
				});
			}

			// image preview function, demonstrating the ui.dialog used as a modal window
			/*
			function viewLargerImage($link) {
				var src = $link.attr('href');
				var title = $link.siblings('img').attr('alt');
				var $modal = $('img[src$="'+src+'"]');

				if ($modal.length) {
					$modal.dialog('open')
				} else {
					var img = $('<img alt="'+title+'" width="384" height="288" style="display:none;padding: 8px;" />').attr('src',src).appendTo('body');
					setTimeout(function() {
						img.dialog({
							title: title,
							width: 400,
							modal: true
						});
					}, 1);
				}
			}*/

			// resolve the icons behavior with event delegation
			/*
			$('ul.gallery > li').click(function(ev) {
				var $item = $(this);
				var $target = $(ev.target);

				if ($target.is('a.ui-icon-plus')) {
					deleteImage($item);
				} else if ($target.is('a.ui-icon-zoomin')) {
					viewLargerImage($target);
				} else if ($target.is('a.ui-icon-close')) {
					recycleImage($item);
				}
				return false;
			});*/


			
	}
		$('#makeSlideshow').click(function (event){
			var html = '';
			//Clear previous carousel
			$('#drop-carousel').empty();
			$("div[id^=thumbs]").remove();
			$("div[id^=play_pause_btn]").remove();
			$("div[id^=btn_rt]").remove();
			$("div[id^=btn_lt]").remove();
			//Add items to the soon-to-be carousel container
			if($('#trash > ul > li').length > 0){
				$('#trash > ul > li').each(function(j){
					var isImage = false;
					for (i=0; i<gImages.length;i++){
						if($(this).attr('id') == gImages[i].imageId){
							html +='<li><div id="slide_'+j+'"><img src="'+gImages[i].url+'" /></div></li>';
							isImage = true;
							break;
						}
					}
					if(!isImage){
						html += '<li><div id="slide_'+j+'">'+$('div',this).html()+'</div></li>';
					}
				});
				$('#firstStep').hide();
				$('#secondStep').show();
				$('#drop-carousel').append(html);
				createCarousel();
			} else {
				$('#noSlideDialog').dialog('open');
			}
		});

		$('#backToChooseSlides').click(function(event){
			$('#firstStep').show();
			$('#secondStep').hide();
			$('#thirdStep').hide();
		});

		$('#backToPreviewSlides').click(function(event){
			$('#firstStep').hide();
			$('#secondStep').show();
			$('#thirdStep').hide();
		});

		$('#saveVideo').click(function(event){
			//Retrieve form data
			var values = {};
				$.each($('#videoData').serializeArray(), function(i, field) {
    				values[field.name] = field.value;
				//console.log(field.name + ':' + field.value);
			});

			values['videopath'] = videoPath;
			//Show dialog & send request
			var server = "bp-tvg-backend.php";
			videoSaved = false;
			$('#saveVideoDialog').empty();
			$('#saveVideoDialog').append('Saving video data. Please wait...');
			$('#saveVideoDialog').dialog({buttons: {}, title: 'Saving video'});
			$('#saveVideoDialog').dialog('open');
			
			$.post(server, 
			       { action: "savevideo", data: values },
			       function(data){
				   //Show confirmation
			       	   videoSaved = true;
				   //$('#saveVideoDialog').dialog('close');
				   //$('#saveVideoDialog').empty();
				   if(data){
					$('#saveVideoDialog').empty();
				   	$('#saveVideoDialog').append('Video data successfully saved. It\'ll be made available in Babelium as soon as possible. Thank you.');
				   	$('#saveVideoDialog').dialog({buttons: {"Ok": function() { $(this).dialog("close"); }}, title: 'Successfully Saved'});
				        //Clear all data
					$("#gImageSearchResults").empty();
					$("#cambridgeSearchResults").empty();
					$("#gImageSearchTxtf").val("");
					
					$('#drop-carousel').empty();
                        		$("div[id^=thumbs]").remove();
                        		$("div[id^=play_pause_btn]").remove();
                        		$("div[id^=btn_rt]").remove();
                        		$("div[id^=btn_lt]").remove();

                        		$.each($('#videoData'), function(i, field) {
                               			$(field).val("");
                        		});
                        		//Go to first step
                        		$('#firstStep').show();
                        		$('#secondStep').hide();
                        		$('#thirdStep').hide();
                		   } else{
					$('#saveVideoDialog').empty();
				        $('#saveVideoDialog').append('Error saving your video data. Try again later.');
                                        $('#saveVideoDialog').dialog({buttons: {"Ok": function() { $(this).dialog("close"); }}, title: 'Error saving'});   
				   }
			       });
		});

		$('#saveSlideshow').click(function (event) {
			var jsonObj = []; //declare array
			$('#drop-carousel > li').each(function(i){
				jsonObj.push({index: $('div',this).attr('id').split('_')[1], img: $('img',this).attr('src'), text: $('div',this).html(), displayTime: $('input',this).val()});
			});
			var server = "bp-tvg-backend.php";
			videoGenerated = false;
			$('#saveSlideDialog').empty();
			$('#saveSlideDialog').append('Converting slideshow to video. Please wait...');
			$('#saveSlideDialog').dialog({buttons: {}, title: 'Generating video'});
			$('#saveSlideDialog').dialog('open');
			$.post(server, { action: "saveslideshow", data: jsonObj },
					   function(data) {
				   		 videoGenerated = true;
				   		 $('#saveSlideDialog').dialog('close');
				   		 $('#saveSlideDialog').empty();
				   		 $('#saveSlideDialog').append('Video was successfully generated');
				   		 $('#saveSlideDialog').dialog({buttons: { "Ok": function() { $(this).dialog("close"); }}, title: 'Successfully Generated'});
				   		 //$('#videoPl').attr('src',data);
				   		 //var elem = document.getElementById("videoPl");
				   		 //elem.load();
						 $('#videoHolder').empty();
						 $('#videoHolder').append('<video id="videoPl" controls><source src="'+data+'" type="video/mp4"><a href="'+data+'">Video tag not supported</video>');
				   		 videoPath = data;
						 $('#firstStep').hide();
						 $('#secondStep').hide();
						 $('#thirdStep').show();
					     //alert("Data Loaded: " + data);
					   });
			
			//console.log(jsonObj);
		});

});
</script>

</head>
<body class="topic-video-generator">
	<div id="header">
	<h1>Topic-based video generator</h1>
	<p>Type a topic of your interest (i.e. climate change) and let Babelium search photos and useful words/phrases related to it for you. Then, pick the images and texts you want to put in your video-exercise and drop them in the designed area. Let Babelium create a slideshow with those resources and modify/preview the display times of each slide. Lastly, you can tell the system to generate a video with the provided slideshow.</p>
	</div>
	<div id="firstStep">
		<div class="stepContent">
		<label>Enter exercise topic:<br /> <input type="text"
			id="gImageSearchTxtf" class="input" value="" size="20" /> <input
			type="submit" id="gImageSearchBtn" class="button-primary"
			value="Search" /> </label>
		<div id="gImageSearchResults" class="ui-widget ui-helper-clearfix"></div>
		<div id="cambridgeSearchResults" class="ui-widget ui-helper-clearfix"></div>
		</div>
		<div class="nextStep">
			<div><input type="submit" id="makeSlideshow" class="ui-button ui-widget" value="Make slideshow" /></div>
		</div>
		<div id="noSlideDialog">No slides were added to the draggable area.</div>
	</div>
	<div id="secondStep">
		<div class="stepContent">
			<div id="carousel" style="width: 640px; height: 480px;">
				<ul id="drop-carousel"></ul>
			</div>
		</div>
		<div class="nextStep">
			<input type="submit" id="backToChooseSlides" class="ui-button ui-widget" value="Back to choosing slides"/>
			<input type="submit" id="saveSlideshow" class="ui-button ui-widget" value="Generate Video" />
		</div>
		<div id="saveSlideDialog">Converting slideshow to video. Please wait...</div>
	</div>
	
	<div id="thirdStep">
		<div class="stepContent">
			<div id="videoHolder">
				<!--
				<video id="videoPl" controls="controls">
				   <source src="" type="video/">
				   <a href="">Your browser does not support the video tag</a>
				</video>
				-->
			</div>
			<div id="dataForm">
				<form id="videoData" action="saveall" method="post">
					<label class="formLabel">Title:</label><input type="text" class="input" name="title" value=""/><br />
					<label class="formLabel">Description:</label><input type="text"  class="input" name="description" value=""/><br />
					<label class="formLabel">Tags:</label><input type="text" class="input" name="tags" value=""/><br />
					<label class="formLabel">Difficulty level:</label>
						<select name="difficulty">
							<option>A1 Beginner</option>
							<option>A2 Elementary</option>
							<option>B1 Pre-intermediate</option>
							<option>B2 Intermediate</option>
							<option>C1 Upper-intermediate</option>
						</select>
					<br />
					<label class="formLabel">Language:</label>
						<select name="language">
							<option>Arabic (Morocco)</option>
							<option>Basque</option>
							<option>English (New Zealand)</option>
							<option>English (United Kingdom)</option>
							<option>English (United States)</option>
							<option>German (Germany)</option><
							<option>French (France)</option>
							<option>Spanish (Spain)</option>
							<option>Spanish (Argentina)</option>
						</select>
					<br />
					<label class="formLabel">Specify video license:</label>
						<select name="license">
							<option>CC-BY: Attribution</option>
							<option>CC-BY-SA: Attribution Share-alike</option>
							<option>CC-BY-ND: Attribution No Derivative</option>
							<option>CC-BY-NC: Attribution Non-comercial</option>
							<option>CC-BY-NC-SA: Attribution Non-comercial Share Alike</option>
							<option>CC-BY-NC-ND: Attribution Non-comercial No Derivative</option>
							<option>Copyright</option>
						</select>
					<br />
					<label class="formLabel">Author's Name/Source url:</label><input type="text" class="input" name="reference" value=""/><br />			
				</form>
				
			</div>
		</div>
		<div class="nextStep">
			<input type="submit" id="backToPreviewSlides" class="ui-button ui-widget" value="Back to slideshow"/>
			<input type="submit" id="saveVideo" class="ui-button ui-widget" value="Save Video" />
		</div>
		<div id="saveVideoDialog">Saving video data. Please wait...</div>
	</div>

</body>
</html>

<?php 
//} 
?>
