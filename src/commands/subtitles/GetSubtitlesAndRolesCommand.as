package commands.subtitles
{
	import business.SubtitlesAndRolesDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.SubtitlesAndRolesEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import vo.SubtitlesAndRolesVO;

	public class GetSubtitlesAndRolesCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new SubtitlesAndRolesDelegate(this).getInfoSubRoles((event as SubtitlesAndRolesEvent).info);
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
					if(resultCollection[0] is SubtitlesAndRolesVO)
					{
					DataModel.getInstance().availableSubtitlesAndRoles=resultCollection;
					DataModel.getInstance().availableSubtitlesAndRolesRetrieved = true;
					}
				}
				else 
				{
					DataModel.getInstance().availableSubtitlesAndRoles= new ArrayCollection();
					DataModel.getInstance().availableSubtitlesAndRolesRetrieved = true;
				}
					
				
				
				

			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error while retrieving app's sub&roles:\n\n"+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}