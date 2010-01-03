package commands.subtitles
{
	import business.ExerciseRoleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.ExerciseRoleEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	public class SaveExerciseRoleCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new ExerciseRoleDelegate(this).saveExerciseRoles((event as ExerciseRoleEvent).roles);
		}
		
		public function result(data:Object):void
		{
			//We check if the insert went well by checking the last_insert_id value
			if (!data.result is int)
			{
				Alert.show("Your rol couldn't be saved properly");
			} else 
			{		
				DataModel.getInstance().exerciseRoleSaveId = int(data.result);
				DataModel.getInstance().exerciseRoleSaved = true ;
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent: FaultEvent = FaultEvent(info);
			Alert.show("Error while saving your roles: "+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}