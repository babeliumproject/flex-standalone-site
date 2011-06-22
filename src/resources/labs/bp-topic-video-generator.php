<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
<head>
<title>Babelium Project: Log In</title>
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
	float: right;
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
}
input{
  color:#555;
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
			title: 'No slides were added to the slideshow',
			resizable: false
		});

		$('#secondStep').hide();
	
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
					html += '<h2>Images related to the provided topic</h2>';
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
				var html = '<h2>Words/phrases related to the provided topic</h2>';
				html += '<label>Add new text:</label><input type="text" id="addWordInput" class="input" value="" size="20"/><input type="submit" id="addWordBtn" class="button-primary" value="Add word"/></label>';
				html += '<ol id="selectable" class="ui-helper-reset ui-helper-clearfix"></ol>';
				$("#cambridgeSearchResults").append(html);
				buildDraggableWordList();
				addWordClickHandler();
			});
		}

		function parseCambridgePage(result){
			//What happens when the topic is not found
			var html = '<h2>Words/phrases related to the provided topic</h2>';
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
		});

		$('#saveSlideshow').click(function (event) {
			var jsonObj = []; //declare array
			$('#drop-carousel > li').each(function(i){
				jsonObj.push({index: $('div',this).attr('id').split('_')[1], img: $('img',this).attr('src'), text: $('div',this).html(), displayTime: $('input',this).val()});
			});
			var server = "bp-tvg-backend.php";
			$.post(server, { action: "saveslideshow", data: jsonObj },
					   function(data) {
					     alert("Data Loaded: " + data);
					   });
			
			console.log(jsonObj);
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
		<div id="carousel" style="width: 640px; height: 480px;">
			<ul id="drop-carousel"></ul>
		</div>
		<input type="submit" id="backToChooseSlides" value="Back to choosing slides"/>
		<input type="submit" id="saveSlideshow" value="Save Slideshow" />
	</div>

</body>
</html>

