package modules.account.command
{
	import business.UserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.UserEvent;
	
	import model.DataModel;
	
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.UserVO;
	
	public class ModifyPersonalDataCommand implements ICommand, IResponder
	{
		
		public function execute(event:CairngormEvent):void
		{
			new UserDelegate(this).modifyUserPersonalData((event as UserEvent).personalData);
		}
		
		public function result(data:Object):void
		{
			var result:Object=data.result;
			
			if (result is UserVO){
				DataModel.getInstance().loggedUser.firstname = (result as UserVO).firstname;
				DataModel.getInstance().loggedUser.lastname = (result as UserVO).lastname;
				DataModel.getInstance().loggedUser.email = (result as UserVO).email;
				DataModel.getInstance().userPersonalDataModified = true;
			} else if (result is String) {
				CustomAlert.error(ResourceManager.getInstance().getString('myResources',(result as String).toUpperCase()));
			}
		}
		
		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources', 'ERROR_WHILE_MODIFYING_PERSONAL_DATA'));
			trace(ObjectUtil.toString(info));
		}
	}
}
