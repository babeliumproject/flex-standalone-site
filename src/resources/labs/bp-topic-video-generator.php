<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
<head>
<title>Babelium Project: Log In</title>
<script type="text/javascript" src="js/jquery1.5.1.js"></script>
<script type="text/javascript" src="js/jquery-ui-1.8.13.custom.min.js"></script>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel='stylesheet' id='login-css'  href='css/login.css' type='text/css' media='all' />
<link type="text/css" href="css/jquery-ui-1.8.13.custom.css" rel="stylesheet" />
<meta name='robots' content='noindex,nofollow' />

<style type="text/css">
      #gallery { 
	float: left; 
	width: 65%; 
	min-height: 12em; 
      } 
      * html #gallery { 
	height: 12em; 
      } /* IE6 */
      .gallery.custom-state-active { 
	background: #eee; 
      }
      .gallery li { 
	float: left; 
	width: 100px;
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
      .gallery li img { 
	width: 100%; 
	cursor: move; 
      }

      #trash { 
	float: right; 
	width: 32%; 
	min-height: 18em; 
	padding: 1%;
      } 
      * html #trash { 
	height: 18em; 
      } /* IE6 */
      #trash h4 { 
	line-height: 16px; 
	margin: 0 0 0.4em; 
      }
      #trash h4 .ui-icon { 
	float: left; 
      }
      #trash .gallery h5 { 
	display: none; 
      }
</style>

<script type="text/javascript">
$(document).ready(function(){
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
					var html = '<ul id="gallery" class="gallery ui-helper-reset ui-helper-clearfix">';
					$.each(data.responseData.results, function(i,results){
						html += '<li class="ui-widget-content ui-corner-tr"><img src="'+results.tbUrl+'" width="'+results.tbWidth+'" height="'+results.tbHeight+' "/>';
						html += '<a href="'+results.url+'" title="View larger image" class="ui-icon ui-icon-zoomin">View larger</a>';
						html += '<a href="link/to/trash/script/when/we/have/js/off" title="Add image to selection" class="ui-icon ui-icon-plus">Add Image</a></li>';
						});
					html +='</ul><div id="trash" class="ui-widget-content ui-state-default"><h4 class="ui-widget-header">Selected Images</h4></div>';
					$("#gImageSearchResults").append(html);
					buildDraggableImageGallery();
			});
		}

		//For the time being we'll webscrap cambridge's online dictionaries, since they provide a smart thesaurus
		function searchTopicRelatedWords(query){
			var server = "http://dictionary.cambridge.org/search/british/direct/?q=";
			//Strip the query from unnecessary symbols, replace the whitespaces with - character
			var filtered_query = query.replace(" ", "-");
			var query_string = server + filtered_query;
			alert(query_string);
			$.get(query_string, function(data,statusText,jqxhr){
				alert(statusText);
				parseCambridgePage(data);
			});
		}

		function parseCambridgePage(result){
			//What happens when the topic is not found?

			//What happens if more precise hits are found?

			//If the topic is concrete-most webscrap the related words
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
				accept: '#gallery > li',
				activeClass: 'ui-state-highlight',
				drop: function(ev, ui) {
					deleteImage(ui.draggable);
				}
			});

			// let the gallery be droppable as well, accepting items from the trash
			$gallery.droppable({
				accept: '#trash li',
				activeClass: 'custom-state-active',
				drop: function(ev, ui) {
					recycleImage(ui.draggable);
				}
			});

			// image deletion function
			var remove_icon = '<a href="link/to/recycle/script/when/we/have/js/off" title="Remove image from selection" class="ui-icon ui-icon-close">Remove image</a>';
			function deleteImage($item) {
				$item.fadeOut(function() {
					var $list = $('ul',$trash).length ? $('ul',$trash) : $('<ul class="gallery ui-helper-reset"/>').appendTo($trash);

					$item.find('a.ui-icon-plus').remove();
					$item.append(remove_icon).appendTo($list).fadeIn(function() {
						$item.animate({ width: '48px' }).find('img').animate({ height: '36px' });
					});
				});
			}

			// image recycle function
			var trash_icon = '<a href="link/to/trash/script/when/we/have/js/off" title="Delete this image" class="ui-icon ui-icon-plus">Delete image</a>';
			function recycleImage($item) {
				$item.fadeOut(function() {
					$item.find('a.ui-icon-close').remove();
					$item.css('width','96px').append(trash_icon).find('img').css('height','72px').end().appendTo($gallery).fadeIn();
				});
			}

			// image preview function, demonstrating the ui.dialog used as a modal window
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
			}

			// resolve the icons behavior with event delegation
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
			});
	}

});
</script>

</head>
<body class="topic-video-generator">
<h1>Topic-based video generator</h1>
<label>Enter exercise topic:<br />
<input type="text" id="gImageSearchTxtf" class="input" value="" size="20"/>
<input type="submit" id="gImageSearchBtn" class="button-primary" value="Search"/>
</label>
<div id="gImageSearchResults" class="ui-widget ui-helper-clearfix">
</div>


<script type="text/javascript">

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

</script>
</body>
</html>

