package modules.main
{
	import com.adobe.crypto.SHA1;
	
	import events.LoginEvent;
	import events.VideoStopEvent;
	import events.ViewChangeEvent;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
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


		public function HeaderClass()
		{
			super();
			this.height=60;
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			//Add this component's reference to DataModel so that it can be used across the application
			DataModel.getInstance().headerComponentInstance = this;
		}

		public function onCreationComplete(event:FlexEvent):void
		{

			//Set the data bindings for this class
			setBindings();

			//First, check if any user cookie is present and if so, make the login
			rememberSO=SharedObject.getLocal("babeliaData");
			if (rememberSO.data.username != undefined && rememberSO.data.hash != undefined)
			{
				processCachedLogin();
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

			BindingUtils.bindSetter(loggedSuccessfully, model, "isSuccessfullyLogged");
			BindingUtils.bindSetter(wrongLogin, model, "loginErrorMessage");
			BindingUtils.bindSetter(creditsUpdated, model, "creditUpdateRetrieved");
			BindingUtils.bindSetter(passRecoveryDone, model, "passRecoveryDone");

			BindingUtils.bindSetter(exerciseRecording, model, "recordingExercise");

		}

		public function signInClickHandler():void
		{
			//Create and show login popup
			showLogin();
		}

		private function checkPressedKey(e:KeyboardEvent):void
		{
			if (e.keyCode == ENTER_KEY)
			{
				processLogin(null);
			}
		}

		public function showLogin():void
		{
			loginPop=LoginForm(PopUpManager.createPopUp(Application.application.parent, LoginForm, true));
			loginPop.title=resourceManager.getString('myResources', 'TITLE_LOGIN_FORM');
			loginPop.showCloseButton=true;
			PopUpManager.centerPopUp(loginPop);

			loginPop.addEventListener("close", hideLogin);
			loginPop["cancelButton"].addEventListener("click", this.hideLogin);
			loginPop["okButton"].addEventListener("click", this.processLogin);
			loginPop["restorePassword"].addEventListener("click", showRestorePass);

			//We add a key listener so that we can push enter to processLogin
			loginPop.addEventListener(KeyboardEvent.KEY_DOWN, checkPressedKey);

			// Give the focus to username textfield
			//focusManager.setFocus(loginPop.username);
		}

		private function hideLogin(event:Event):void
		{
			PopUpManager.removePopUp(loginPop);
		}

		private function showRestorePass(event:Event):void
		{
			hideLogin(null);
			DataModel.getInstance().restorePassErrorMessage="";
			restorePop=RestorePassForm(PopUpManager.createPopUp(parent, RestorePassForm, true));
			restorePop.title=resourceManager.getString('myResources', 'TITLE_RESTORE_PASS_FORM');
			restorePop.showCloseButton=true;
			PopUpManager.centerPopUp(restorePop);

			restorePop.addEventListener("close", hideRestorePass);
			restorePop["cancelButton"].addEventListener("click", hideRestorePass);
			restorePop["okButton"].addEventListener("click", processRestorePass);
		}

		private function hideRestorePass(event:Event):void
		{
			PopUpManager.removePopUp(restorePop);
		}

		private function passRecoveryDone(flag:Boolean):void
		{
			hideRestorePass(null);
		}

		private function processRestorePass(event:Event):void
		{
			var user:LoginVO=new LoginVO(restorePop.username.text, "");
			new LoginEvent(LoginEvent.RESTORE_PASS, user).dispatch();
		}

		private function processLogin(event:Event):void
		{
			//Encrypt our password for security
			var passHash:String=SHA1.hash(loginPop.password.text);
			var user:LoginVO=new LoginVO(loginPop.username.text, passHash);
			new LoginEvent(LoginEvent.PROCESS_LOGIN, user).dispatch();
		}

		private function processCachedLogin():void
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

		private function loggedSuccessfully(upd:Boolean):void
		{
			if (DataModel.getInstance().isSuccessfullyLogged)
			{
				if ((rememberSO.data.username == undefined || rememberSO.data.hash == undefined) && loginPop != null)
				{
					//The user wants the application to remember him/her
					if (loginPop.rememberUser.selected)
					{
						var cacheHash:String=SHA1.hash(loginPop.password.text);
						rememberSO.data.username=loginPop.username.text;
						rememberSO.data.hash=cacheHash;
						rememberSO.flush();
					}
					PopUpManager.removePopUp(loginPop);
					loginPop.username.text="";
					loginPop.password.text="";
				}
				anonymousCP.visible=false;
				userCPName.label=DataModel.getInstance().loggedUser.name;
				uCrds.label=DataModel.getInstance().loggedUser.creditCount.toString();
				userCP.visible=true;
				DataModel.getInstance().isSuccessfullyLogged=false;
			}
		}

		private function wrongLogin(upd:Boolean):void
		{
			if (loginPop)
			{
				loginPop.errorInfo.text=DataModel.getInstance().loginErrorMessage;
				DataModel.getInstance().loginErrorMessage="";
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
			if (DataModel.getInstance().loggedUser)
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

	}
}