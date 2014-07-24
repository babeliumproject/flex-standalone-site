package modules.create.command
{
	import business.UserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.UserEvent;
	
	import model.DataModel;
	
	import modules.create.event.CreateEvent;
	import modules.create.service.CreateDelegate;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class ModifyVideoDataCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new CreateDelegate(this).updateExercise((event as CreateEvent).params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			
			if (result == true){
				DataModel.getInstance().videoDataModified = true;
			} else {
				DataModel.getInstance().videoDataModified = false;
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_MODIFYING_VIDEO_DATA'));
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources', 'ERROR_WHILE_MODIFYING_VIDEO_DATA'));
			trace(ObjectUtil.toString(info));
		}
	}
}