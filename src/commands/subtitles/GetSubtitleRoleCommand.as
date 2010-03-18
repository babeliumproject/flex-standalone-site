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
	
	import vo.ExerciseRoleVO;
	import vo.SubtitleAndSubtitleLinesVO;


	public class GetSubtitleRoleCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			// Alert.show( ObjectUtil.toString(  (event as SubtitlesAndRolesEvent).info));
			new SubtitlesAndRolesDelegate(this).getRoles((event as SubtitlesAndRolesEvent).info);
			// new ExerciseRoleDelegate(this).getExerciseRoles((event as ExerciseRoleEvent).rol);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;
			
			if (result is Array)
			{
				resultCollection=new ArrayCollection( ArrayUtil.toArray(result));	
			
				if ( resultCollection.length > 0 )
				{		
					//Set the data to the application's model
					DataModel.getInstance().availableExerciseRoles.setItemAt(resultCollection, 0);
					DataModel.getInstance().availableExerciseRolesRetrieved.setItemAt(true, 0);
					// Alert.show("RESULTADO:" + ObjectUtil.toString(resultCollection ));
				}	
				else
				{
					Alert.show("No roles available");
				}

			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error while retrieving app's roles:\n\n"+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}