package commands.userManagement
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
				DataModel.getInstance().loggedUser.realName = (result as UserVO).realName;
				DataModel.getInstance().loggedUser.realSurname = (result as UserVO).realSurname;
				DataModel.getInstance().loggedUser.email = (result as UserVO).email;
				DataModel.getInstance().userPersonalDataModified = true;
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