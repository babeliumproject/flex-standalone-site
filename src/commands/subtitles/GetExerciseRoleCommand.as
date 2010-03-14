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
	import mx.utils.ObjectUtil;
	import mx.utils.ArrayUtil;


	public class GetExerciseRoleCommand implements ICommand, IResponder
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
//					
//				if ( resultCollection.length > 0 && (resultCollection[0] is ExerciseRoleVO ) )
//				{		
					//Set the data to the application's model
					DataModel.getInstance().availableExerciseRoles=resultCollection;
					// Alert.show("RESULTADO:" + ObjectUtil.toString(resultCollection ));
//				}	
//				if (!(resultCollection[0] is ExerciseRoleVO ))
//				{
//					Alert.show("The Result is not a well-formed object");
//				}

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