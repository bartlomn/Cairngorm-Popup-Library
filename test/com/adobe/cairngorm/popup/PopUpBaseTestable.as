/**
 *  Copyright (c) 2007 - 2009 Adobe
 *  All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package com.adobe.cairngorm.popup
{
    import flash.events.Event;
    
    import flexunit.framework.EventfulTestCase;
    
    import mx.core.IFlexDisplayObject;
    import mx.events.CloseEvent;

    /**
     * This unit test doesn't operate in isolation, since PopUpBase uses the
     * static methods of PopUpManager. It may be possible to refactor PopUpBase
     * to use the excluded IPopUpManager interface, which could then be stubbed
     * but that would complicate the test case and component.
     */
    public class PopUpBaseTestable extends EventfulTestCase
    {
        //------------------------------------------------------------------------
        //
        //  Fixture
        //
        //------------------------------------------------------------------------

        private var popUpBase:PopUpBase;

        private var suspendedEvent:PopUpEvent;

        protected function createPopUpComponent():PopUpBase
        {
            throw new Error("abstract method call");
        }

        protected function assertPopUpOpenedTwice():void
        {
            expectEvents(popUpBase, PopUpEvent.OPENED, PopUpEvent.OPENED);

            popUpBase.open = true;
            popUpBase.open = false;
            popUpBase.open = true;

            assertExpectedEventsOccurred();
        }

        //------------------------------------------------------------------------
        //
        //  Overrides : TestCase
        //
        //------------------------------------------------------------------------

        override public function setUp():void
        {
            popUpBase = createPopUpComponent();
        }

        override public function tearDown():void
        {
            popUpBase.open = false;
        }

        //------------------------------------------------------------------------
        //
        //  Tests
        //
        //------------------------------------------------------------------------

        public function testOpensPopUp():void
        {
            expectEvent(popUpBase, PopUpEvent.OPENING);

            popUpBase.open = true;

            assertExpectedEventsOccurred();
            assertNotNull(
                "The popup view as not created and passed into the event.",
                PopUpEvent(actualEvents[0]).popup);
        }

        public function testClosesPopUpWhenCloseEventIsDispatched():void
        {
            var popup:IFlexDisplayObject;

            popUpBase.addEventListener(
                PopUpEvent.OPENING,
                function(event:PopUpEvent):void
                {
                    popup = event.popup;
                });

            popUpBase.open = true;

            expectEvents(popUpBase, PopUpEvent.CLOSING, PopUpEvent.CLOSED);
            popup.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
            assertExpectedEventsOccurred();
			
			assertFalse("popup still open", popUpBase.open);
        }
		
		//https://bugs.adobe.com/jira/browse/CGM-59
		public function testDoNotClosePopUpWhenCloseEventIsDispatchedButCancelled():void
		{
			var popup:IFlexDisplayObject;
			
			popUpBase.addEventListener(
				PopUpEvent.OPENING,
				function(event:PopUpEvent):void
				{
					popup = event.popup;
				});
			
			popUpBase.open = true;
			
			//Cancel closing of popup.
			popup.addEventListener(
				CloseEvent.CLOSE,
				function(event:CloseEvent):void
				{
					assertTrue("event is not cancelable", event.cancelable);
					event.preventDefault();
				});		
			
			//try to close
			popup.dispatchEvent(new CloseEvent(CloseEvent.CLOSE, false, true));
			
			assertTrue("popup.open false, closing has not been cancelled", popUpBase.open);
		}		

        public function testDispatchesEventsDuringOpening():void
        {
            expectEvents(popUpBase, PopUpEvent.OPENING, PopUpEvent.OPENED);

            popUpBase.open = true;

            assertExpectedEventsOccurred();
        }

        public function testDispatchesEventsDuringClosure():void
        {
            popUpBase.open = true;

            expectEvents(popUpBase, PopUpEvent.CLOSING, PopUpEvent.CLOSED);

            popUpBase.open = false;

            assertExpectedEventsOccurred();
        }

        public function testAppliesPopUpBehaviors():void
        {
            var behavior1:MockBehavior = new MockBehavior();
            var behavior2:MockBehavior = new MockBehavior();

            popUpBase.behaviors = [ behavior1, behavior2 ];

            assertTrue("The behavior was not applied", behavior1.applied);
            assertTrue("The behavior was not applied", behavior2.applied);

            assertEquals(
                "The popup opener was not passed to the behavior",
                popUpBase,
                behavior1.opener);
            assertEquals(
                "The popup opener was not passed to the behavior",
                popUpBase,
                behavior2.opener);
        }

        public function testClosureCanBeSuspendedAndResumed():void
        {
            suspendClosure();

            expectEvent(popUpBase, PopUpEvent.CLOSED);

            suspendedEvent.resumeClosure();

            assertExpectedEventsOccurred();
        }

        public function testClosureCanBeSuspendedAndResumedMultipleTimes():void
        {
            popUpBase.addEventListener(
                PopUpEvent.CLOSING,
                function(e:PopUpEvent):void
                {
                    suspendedEvent = e;
                    e.suspendClosure();
                    e.suspendClosure();
                    e.suspendClosure();
                });

            popUpBase.open = true;
            popUpBase.open = false;

            suspendedEvent.resumeClosure();
            suspendedEvent.resumeClosure();
            // third time should cause closure
            expectEvent(popUpBase, PopUpEvent.CLOSED);
            suspendedEvent.resumeClosure();
            assertExpectedEventsOccurred();
        }

        public function testReopenWhileClosureIsSupsendedForcesClosure():void
        {
            suspendClosure();

            expectEvents(
                popUpBase,
                PopUpEvent.CLOSED,
                PopUpEvent.OPENING,
                PopUpEvent.OPENED);

            popUpBase.open = true;

            assertExpectedEventsOccurred(
                "The popup should have been closed then reopened.");
        }

        //------------------------------------------------------------------------
        //
        //  Private Methods
        //
        //------------------------------------------------------------------------

        private function suspendClosure():void
        {
            popUpBase.addEventListener(
                PopUpEvent.CLOSING,
                function(e:PopUpEvent):void
                {
                    suspendedEvent = e;
                    suspendedEvent.suspendClosure();
                });

            popUpBase.open = true;
            popUpBase.open = false;
        }
    }
}