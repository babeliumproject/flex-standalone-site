<?php

$folderPath = "/RED5_HOME/APP_NAME/streams/responses";

if($folderIterator = dir($folderPath)){
	$items = array();
	while(false!==($item=$folderIterator->read())){
		$itemAbsolutePath = $folderPath."/".$item;
		if(!is_dir($itemAbsolutePath) && !is_link($itemAbsolutePath)){
			$itemMetaData=pathinfo($itemAbsolutePath);
			if($itemMetaData['extension']=='flv'){
				if(preg_match('/resp-([\d]+)/',$item,$matches)){
					$itemEpoch = $matches[1]/1000; //Flash prints epoch with milliseconds
					$items[$itemAbsolutePath] = $itemEpoch;
				}
			}
		}
	}
	$folderIterator->close();
	ksort($items);
	foreach($items as $key=>$value){
		$itemFormattedDate = date("D, d M Y H:i:s O",$value);
		echo $itemFormattedDate."\t".$key."\n";
		//Change the modification time to the provided epoch value, if the file does not exist it is created
		touch($key,$value);
	}
}
