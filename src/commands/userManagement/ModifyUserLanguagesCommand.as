package commands.userManagement
{
	import business.UserDelegate;

	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;

	import events.UserEvent;

	import model.DataModel;

	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;

	import view.common.CustomAlert;

	public class ModifyUserLanguagesCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new UserDelegate(this).modifyUserLanguages((event as UserEvent).dataList);
		}

		public function result(data:Object):void
		{
			var result:Object=data.result;
			var resultCollection:Array;

			if (result is Array && (result as Array).length > 0)
			{
				resultCollection=ArrayUtil.toArray(result);
				DataModel.getInstance().loggedUser.userLanguages=resultCollection;
				DataModel.getInstance().userPreferredLanguagesModified=true;
			}
//			else
//			{
//				DataModel.getInstance().loggedUser.userLanguages=new Array();
//				DataModel.getInstance().userPreferredLanguagesModified=false;
//			}

		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources', 'ERROR_WHILE_MODIFYING_LANGUAGES'));
			trace(ObjectUtil.toString(info));
		}
	}
}