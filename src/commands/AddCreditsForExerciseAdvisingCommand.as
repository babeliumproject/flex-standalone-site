package commands
{
	import business.CreditsDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.CreditEvent;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	public class AddCreditsForExerciseAdvisingCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new CreditsDelegate(this).addCreditsForExerciseAdvising((event as CreditEvent).userId);
		}
		
		public function result(data:Object):void
		{
			var successfulUpdate:Boolean = data.result as Boolean;
			if(!successfulUpdate)
				Alert.show("A problem occurred while trying to update your credits");
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show("Error: "+faultEvent.message);
			trace(ObjectUtil.toString(info));
		}
		
	}
}