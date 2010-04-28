package testSuites.Configuration Module Test.tests{
    import com.gorillalogic.flexmonkey.flexunit.tests.MonkeyFlexUnitTestCase;

    import com.gorillalogic.flexmonkey.core.MonkeyTest;
    import com.gorillalogic.flexmonkey.monkeyCommands.*;
    import com.gorillalogic.flexmonkey.application.VOs.AttributeVO;
    import com.gorillalogic.flexmonkey.events.MonkeyCommandRunnerEvent;

    import mx.collections.ArrayCollection;

    public class TestCase extends MonkeyFlexUnitTestCase{
        public function TestCase(){
            super();
        }

        private var mtWebCam & BandWidth:MonkeyTest = new MonkeyTest('WebCam & BandWidth', 500,
            new ArrayCollection([
                new UIEventMonkeyCommand('Click', 'Login', 'automationName', [null]),
                new UIEventMonkeyCommand('SelectText', 'username', 'automationName', ['0', '0']),
                new UIEventMonkeyCommand('Input', 'username', 'automationName', ['erab1']),
                new UIEventMonkeyCommand('ChangeFocus', 'username', 'automationName', [null]),
                new UIEventMonkeyCommand('Input', 'password', 'automationName', ['erab1']),
                new UIEventMonkeyCommand('Type', 'password', 'automationName', ['ENTER']),
                new PauseMonkeyCommand(1000),
                new VerifyMonkeyCommand('New Verify', null, 'Configuration', 'automationName', false,
                    new ArrayCollection([
                        new AttributeVO('enabled', null, 'property', 'true')
                    ]), null, null, false, '0', '1', 0),
                new UIEventMonkeyCommand('Click', 'Configuration', 'automationName', [null]),
                new UIEventMonkeyCommand('Click', 'REC', 'automationName', [null]),
                new UIEventMonkeyCommand('Click', 'REC', 'automationName', [null]),
                new PauseMonkeyCommand(11500),
                new UIEventMonkeyCommand('Click', 'PLAY', 'automationName', [null]),
                new PauseMonkeyCommand(11500),
                new VerifyMonkeyCommand('New Verify', null, 'Webcam: OK', 'automationName', false,
                    new ArrayCollection([
                        new AttributeVO('text', null, 'property', 'Webcam: OK')
                    ]), null, null, false, '0', '1', 0),
                new UIEventMonkeyCommand('Change', 'configurationMenu', 'automationName', ['BandWidth Configuration']),
                new UIEventMonkeyCommand('Click', 'BANDWIDTH TEST', 'automationName', [null]),
                new PauseMonkeyCommand(1000),
                new VerifyMonkeyCommand('New Verify', null, 'Bandwidth: OK', 'automationName', false,
                    new ArrayCollection([
                        new AttributeVO('text', null, 'property', 'Bandwidth: OK')
                    ]), null, null, false, '0', '1', 0)
            ]));

        private var mtWebCam & BandWidthTimeoutTime:int = 56500;

        [Test]
        public function WebCam & BandWidth():void{
            // startTest(<MonkeyTest>, <Complete method>, <Async timeout value>, <Timeout method>);
            startTest(mtWebCam & BandWidth, mtWebCam & BandWidthComplete, mtWebCam & BandWidthTimeoutTime, defaultTimeoutHandler);
        }

        public function mtWebCam & BandWidthComplete(event:MonkeyCommandRunnerEvent, passThroughData:Object):void{
            checkCommandResults(mtWebCam & BandWidth);
        }


    }
}