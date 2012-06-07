<?php

$inputFolder = "/RED5_HOME/APP_NAME/streams/responses";
$outputFolder = "/RED5_HOME/APP_NAME/streams/responses_fixed";

if($folderIterator = dir($inputFolder)){
        $items = array();
        while(false!==($item=$folderIterator->read())){
                $itemAbsolutePath = $inputFolder."/".$item;
                if(!is_dir($itemAbsolutePath) && !is_link($itemAbsolutePath)){
                        $itemMetaData=pathinfo($itemAbsolutePath);
            //Ensure the file you want to process is an FLV file
			if($itemMetaData['extension']=='flv'){
				//We copy both audio & video codecs but the metadata and the stream channels get fixed in the way
                        	$preset = "ffmpeg -y -i '%s' -vcodec copy -acodec copy '%s'";
				//pathinfo['filename'] only available since PHP 5.2.x
				$inputFile = $inputFolder."/".$itemMetaData['filename'].".flv";
				$outputFile = $outputFolder."/".$itemMetaData['filename'].".flv";
				$sysCall = sprintf($preset,$inputFile,$outputFile);
				$cmdlastline = (exec($sysCall,$cmdverbose));
			}
                }
        }
        $folderIterator->close();
}

?>
