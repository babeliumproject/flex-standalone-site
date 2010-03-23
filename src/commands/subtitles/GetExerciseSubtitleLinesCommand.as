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

	public class GetExerciseSubtitleLinesCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).getSubtitleLines((event as SubtitleEvent).subtitle);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;
				
		if (result is Array)
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));	
					
				if ( resultCollection.length > 0 )
				{		
					if(resultCollection[0] is SubtitleLineVO)
					{
					DataModel.getInstance().availableSubtitleLines=resultCollection;
					DataModel.getInstance().availableSubtitleLinesRetrieved = true;
					}
				}
				else 
				{
					DataModel.getInstance().availableSubtitleLines= new ArrayCollection();
					DataModel.getInstance().availableSubtitleLinesRetrieved = true;
				}
					
				
				
				

			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error while retrieving exercise's subtitle lines:\n"+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}