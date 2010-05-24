package modules.main
{
	import com.adobe.crypto.SHA1;
	
	import events.LoginEvent;
	import events.VideoStopEvent;
	import events.ViewChangeEvent;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import model.DataModel;
	
	import modules.userManagement.LoginForm;
	import modules.userManagement.RestorePassForm;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.HBox;
	import mx.controls.LinkButton;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import vo.LoginVO;

	public class HeaderClass extends HBox
	{

		//Login related properties
		public var loginPop:LoginForm;
		public var restorePop:RestorePassForm;

		private var closingEvent:Event;

		private var interval:uint;
		private var intervalLoops:int;

		private var rememberSO:SharedObject;

		//The keyCode for ENTER key
		public static const ENTER_KEY:int=13;

		//Visual components declaration
		public var userCP:HBox;
		public var anonymousCP:HBox;

		public var userCPName:LinkButton;
		public var uCrds:LinkButton;
		public var signInButton:LinkButton;
		public var signUpButton:LinkButton;
		public var userAccountButton:LinkButton;
		public var signOutButton:LinkButton;
		public var helpFAQButton:LinkButton;


		public function HeaderClass()
		{
			super();
			this.height=60;
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}

		public function onCreationComplete(event:FlexEvent):void
		{

			//Set the data bindings for this class
			setBindings();

			//First, check if any user cookie is present and if so, make the login
			rememberSO=SharedObject.getLocal("babeliaData");
			if (rememberSO.data.username != undefined && rememberSO.data.hash != undefined)
			{
				cachedAuthentication();
			}
			else
			{
				//Since our user isn't signed in we hide the users cp
				userCP.visible=false;
			}
		}

		public function setBindings():void
		{
			var model:DataModel=DataModel.getInstance();

			BindingUtils.bindSetter(onUserAuthenticated, model, "isLoggedIn");
			BindingUtils.bindSetter(creditsUpdated, model, "creditUpdateRetrieved");
			BindingUtils.bindSetter(exerciseRecording, model, "recordingExercise");

		}

		public function signInClickHandler():void
		{
			//Create and show login popup
			showLogin();
		}

		public function showLogin():void
		{
			loginPop=LoginForm(PopUpManager.createPopUp(Application.application.parent, LoginForm, true));
			PopUpManager.centerPopUp(loginPop);
		}

		private function cachedAuthentication():void
		{
			var cachedUser:LoginVO=new LoginVO(rememberSO.data.username, rememberSO.data.hash);
			new LoginEvent(LoginEvent.PROCESS_LOGIN, cachedUser).dispatch();
		}

		public function signUpClickHandler():void
		{
			// Stop videos if some one is playing
			new VideoStopEvent().dispatch();
			//Change contentViewStack to sign up page
			new ViewChangeEvent(ViewChangeEvent.VIEW_REGISTER_MODULE).dispatch();
		}

		public function accountClickHandler():void
		{
			// Stop videos if some one is playing
			new VideoStopEvent().dispatch();
			//Change contentViewStack to account page
			new ViewChangeEvent(ViewChangeEvent.VIEW_ACCOUNT_MODULE).dispatch();
		}

		public function signOutClickHandler():void
		{
			//Since our user isn't signed in we hide the users cp
			new LoginEvent(LoginEvent.SIGN_OUT, null).dispatch();
			// Stop videos if some one is playing
			new VideoStopEvent().dispatch();
			// Redirecting to home
			new ViewChangeEvent(ViewChangeEvent.VIEW_HOME_MODULE).dispatch();
			anonymousCP.visible=true;
			userCP.visible=false;
			rememberSO.clear();
		}

		private function onUserAuthenticated(upd:Boolean):void
		{
			if (DataModel.getInstance().isLoggedIn)
			{
				anonymousCP.visible=false;
				userCPName.label=DataModel.getInstance().loggedUser.name;
				uCrds.label=DataModel.getInstance().loggedUser.creditCount.toString();
				userCP.visible=true;
			}
		}

		private function blinkCredits():void
		{
			if (intervalLoops <= 20)
			{
				if (uCrds.visible)
				{
					uCrds.visible=false;
					intervalLoops++;
				}
				else
				{
					uCrds.visible=true;
					intervalLoops++;
				}
			}
			else
			{
				uCrds.visible=true;
				clearInterval(interval);
			}
		}

		private function creditsUpdated(retr:Boolean):void
		{
			if (DataModel.getInstance().loggedUser && DataModel.getInstance().creditUpdateRetrieved)
			{
				uCrds.label=DataModel.getInstance().loggedUser.creditCount.toString();
				intervalLoops=0;
				interval=setInterval(blinkCredits, 300);
				DataModel.getInstance().creditUpdateRetrieved=false;
			}
		}
		
		private function exerciseRecording(value:Boolean):void{
			var status:Boolean = ! DataModel.getInstance().recordingExercise;
			signInButton.enabled = status;
			signUpButton.enabled = status;
			signOutButton.enabled = status;
			userAccountButton.enabled = status;
		}
		
		public function helpFAQ_clickHandler(event:MouseEvent):void{
			new ViewChangeEvent(ViewChangeEvent.VIEW_HELP_MODULE).dispatch();	
		}

	}
}