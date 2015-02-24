package modules.create.command
{
	import business.UserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import modules.create.event.CreateEvent;
	import modules.create.service.CreateDelegate;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	public class DeleteCreations implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			var params:Object=(event as CreateEvent).params;
			new CreateDelegate(this).deleteSelectedCreations(params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			
			if (result == true){
				DataModel.getInstance().selectedVideosDeleted = true;
			} else {
				DataModel.getInstance().selectedVideosDeleted = false;
				CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_DELETING_VIDEOS'));
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources', 'ERROR_WHILE_DELETING_VIDEOS'));
			trace(ObjectUtil.toString(info));
		}
	}
}