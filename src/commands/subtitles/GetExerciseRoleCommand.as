package commands.subtitles
{
	import business.ExerciseRoleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ExerciseRoleEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import vo.ExerciseRoleVO;

	public class GetExerciseRoleCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ExerciseRoleDelegate(this).getExerciseRoles((event as ExerciseRoleEvent).rol);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;
				
		if (result is Array)
			{
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));	
					
				if ( resultCollection.length > 0 && (resultCollection[0] is ExerciseRoleVO ) )
				{		
					//Set the data to the application's model
					DataModel.getInstance().availableExerciseRoles=resultCollection;
				}	
				if (!(resultCollection[0] is ExerciseRoleVO ))
				{
					Alert.show("The Result is not a well-formed object");
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