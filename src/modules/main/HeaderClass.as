package modules.main
{
	import events.LoginEvent;
	import events.ViewChangeEvent;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import model.DataModel;
	
	import modules.userManagement.LoginRestorePassForm;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.LinkButton;
	import mx.controls.PopUpMenuButton;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.managers.PopUpManager;
	
	import skins.IconButton;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.RepeatBehavior;
	import spark.effects.animation.SimpleMotionPath;
	
	import view.common.PrivacyRights;
	
	import vo.LoginVO;

	public class HeaderClass extends BorderContainer
	{
		private var interval:uint;
		private var intervalLoops:int;

		private var rememberSO:SharedObject;

		//The keyCode for ENTER key
		public static const ENTER_KEY:int=13;
		
		[Bindable]
		public var userOptions:Array= new Array({code: 'LABEL_USER_ACCOUNT', action: ViewChangeEvent.VIEW_ACCOUNT_MODULE});

		//Visual components declaration
		public var userCP:HGroup;
		public var anonymousCP:HGroup;

		public var userCPName:PopUpMenuButton;
		[Bindable] public var uCrds:Label;
		public var signInButton:IconButton;
		public var signUpButton:IconButton;
		public var signOutButton:IconButton;
		public var helpFAQButton:IconButton;
		
		public var localeComboBox:LocalizationComboBox;

		public function HeaderClass()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		public function onCreationComplete(event:FlexEvent):void
		{

			//Set the data bindings for this class
			setBindings();
		}

		public function setBindings():void
		{
			var model:DataModel=DataModel.getInstance();

			BindingUtils.bindSetter(onUserAuthenticated, model, "isLoggedIn");
			BindingUtils.bindSetter(creditsUpdated, model, "creditUpdateRetrieved");
			BindingUtils.bindSetter(exerciseRecording, model, "recordingExercise");
			BindingUtils.bindSetter(onAccountActivation, model, "accountActivationRetrieved");
		}

		public function signInClickHandler():void
		{
			//Create and show login popup
			showLogin();
		}

		public function showLogin():void
		{
			DataModel.getInstance().loginPop = PopUpManager.createPopUp(FlexGlobals.topLevelApplication.parent, LoginRestorePassForm, true) as LoginRestorePassForm;
			PopUpManager.centerPopUp(DataModel.getInstance().loginPop);
		}

		public function signUpClickHandler():void
		{
			//Change contentViewStack to sign up page
			new ViewChangeEvent(ViewChangeEvent.VIEW_REGISTER_MODULE).dispatch();
		}
		
		public function userOptionsLabelFunction(item:Object):String{
			return resourceManager.getString('myResources', item.code.toString());
		}

		public function userOptionsItemClickHandler(event:MenuEvent):void
		{
			var whereToGo:String = event.item.action;
			//Change contentViewStack to account page
			new ViewChangeEvent(whereToGo).dispatch();
		}

		public function signOutClickHandler():void
		{
			//Since our user isn't signed in we hide the users cp
			new LoginEvent(LoginEvent.SIGN_OUT, null).dispatch();
			// Redirecting to home
			new ViewChangeEvent(ViewChangeEvent.VIEW_HOME_MODULE).dispatch();
			anonymousCP.includeInLayout=true;
			anonymousCP.visible=true;
			userCP.includeInLayout=false;
			userCP.visible=false;
		}

		private function onUserAuthenticated(upd:Boolean):void
		{
			if (DataModel.getInstance().isLoggedIn)
			{
				anonymousCP.visible=false;
				anonymousCP.includeInLayout=false;
				userCPName.label=DataModel.getInstance().loggedUser.name;
				uCrds.text=DataModel.getInstance().loggedUser.creditCount.toString();
				userCP.includeInLayout=true;
				userCP.visible=true;
				localeComboBox.updateSelectedIndex();
		
			}
		}

		private function blinkCredits():void
		{
			var motion:SimpleMotionPath = new SimpleMotionPath();
			motion.property = "alpha";
			motion.valueFrom=1.0;
			motion.valueTo=0.0;
			var motionVector:Vector.<MotionPath> = new Vector.<MotionPath>();
			motionVector.push(motion);

			var anim:Animate = new Animate();
			anim.repeatBehavior = RepeatBehavior.REVERSE;
			anim.repeatCount=20;
			anim.duration = 300;
			anim.target = uCrds;
			anim.motionPaths=motionVector;
			anim.play();
		}

		private function creditsUpdated(retr:Boolean):void
		{
			if (DataModel.getInstance().loggedUser && DataModel.getInstance().creditUpdateRetrieved)
			{
				uCrds.text=DataModel.getInstance().loggedUser.creditCount.toString();
				blinkCredits();
				DataModel.getInstance().creditUpdateRetrieved=false;
			}
		}
		
		private function exerciseRecording(value:Boolean):void{
			var status:Boolean = ! DataModel.getInstance().recordingExercise;
			signInButton.enabled = status;
			signUpButton.enabled = status;
			signOutButton.enabled = status;
		}
		
		public function helpFAQ_clickHandler(event:MouseEvent):void{
			new ViewChangeEvent(ViewChangeEvent.VIEW_HELP_MODULE).dispatch();	
		}
		
		private function onAccountActivation(flag:Boolean) : void
		{
			localeComboBox.updateSelectedIndex();
		}

	}
}