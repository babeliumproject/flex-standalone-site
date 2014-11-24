package modules.create.command
{
	import com.adobe.cairngorm.CairngormMessageCodes;
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
	
	public class SetDefaultThumbnail implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new CreateDelegate(this).setDefaultThumbnail((event as CreateEvent).params);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			
			if (result is String){
				DataModel.getInstance().defaultThumbnailModified = true;
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources', 'ERROR_SETTING_DEFAULT_THUMBNAIL'));
			trace(ObjectUtil.toString(info));
		}
	}
}