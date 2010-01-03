package commands.subtitles
{
	import business.SubtitleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.SubtitleEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import vo.SubtitleLineVO;

	public class GetSubtitleLinesCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).getSubtitleLines((event as SubtitleEvent).subtitle);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			if (result is Array)
			{
				var resultCollection:ArrayCollection=new ArrayCollection(ArrayUtil.toArray(result));

				if ( resultCollection.length > 0 )
				{
					
					if (resultCollection[0] is SubtitleLineVO)
					{
					
						DataModel.getInstance().subtitleDp = resultCollection;
					}
					
				}
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent: FaultEvent = FaultEvent(info);
			Alert.show("Error while saving your subtitle lines: "+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}