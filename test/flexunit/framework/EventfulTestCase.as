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
package flexunit.framework
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * A base class for test cases that are interested in event dispatching.
	 *
	 * <p>
	 * The process of testing the dispatch of events typically involves four
	 * stages:
	 * </p>
	 *
	 * <ol>
	 *    <li>
	 *       Record the events that are expected to occur during the test case
	 *       using the <code>expectEvent()</code> or <code>expectEvents()</code>
	 *       functions.
	 *    </li>
	 *    <li>
	 *       Perform the action under test in the same way as a normal test case.
	 *    </li>
	 *    <li>
	 *       Assert that the expected events actually occurred using the
	 *       <code>assertExpectedEventsOccurred() function.
	 *    </li>
	 *    <li>
	 *       Assert that the details of these events are correct using the
	 *       <code>lastActualEvent</code> and <code>actualEvents</code> property
	 *       getters and standard FlexUnit assertion functions.
	 *    </li>
	 * </ol>
	 *
	 * <p>
	 * An example test case is shown below:
	 * </p>
	 *
	 * <pre>
	 * public function testAddPlutonium() : void
	 * {
	 *    // record the expected events
	 *    expectEvent( model, TemperatureChangeEvent.TEMPERATURE_CHANGED );
	 *
	 *    // perform the action that is being tested
	 *    reactor.addPlutonium( plutonium );
	 *
	 *    // assert that the expected events were dispatched
	 *    assertActualEventsOccurred(
	 *       "The temperature change event was not dispatched." );
	 *
	 *    // assert on the details of the actual event
	 *    var temperatureChangeEvent : TemperatureChangeEvent =
	 *       TemperatureChangeEvent( lastActualEvent );
	 *
	 *    var expectedTemperature : Number = 550;
	 *
	 *    assertEquals(
	 *       "The expected temperature change did not occur.",
	 *       expectedTemperature,
	 *       temperatureChangeEvent.temperature );
	 * }
	 * </pre>
	 */
	public class EventfulTestCase extends TestCase
	{
		/** Listens for expected events during a single test case. */
		private var eventListener : EventListener = new EventListener();

		//-------------------------------
		//
		// actual event getters
		//
		//-------------------------------

		/**
		 * Gets the last event to actually be heard. Only expected events
		 * registered through the <code>expectEvent()</code> or
		 * <code>expectEvents()</code> functions can be heard.
		 */
		protected function get lastActualEvent() : Event
		{
			return eventListener.lastActualEvent;
		}

		/**
		 * Gets the events that were heard.
		 */
		protected function get actualEvents() : Array
		{
			return eventListener.actualEvents;
		}

		//-------------------------------
		//
		// constructor
		//
		//-------------------------------

		public function EventfulTestCase( methodName : String = null )
		{
			super( methodName );
		}

		//-------------------------------
		//
		// expect functions
		//
		//-------------------------------

		/**
		 * Record an expected event. When the <tt>assertExpectedEvents()</tt>
		 * function is called, the expected events will be compared with the
		 * actual events.
		 *
		 * @param source
		 *    the object that is expected to dispatch the event
		 * @param type
		 *    the type of event that the source object is expected to dispatch
		 */
		protected function expectEvent(
			source : IEventDispatcher ,
			type : String ) : void
		{
			// prevent the same event listener hearing an event multiple times

			if ( source.hasEventListener( type ) )
			{
				source.removeEventListener( type , eventListener.handleEvent );
			}

			eventListener.expectEvent( type );

			source.addEventListener(
				type ,
				eventListener.handleEvent ,
				false ,
				0.0 ,
				true ); // weak reference so singleton listeners are cleaned up
		}

		/**
		 * Record a series of expected events. When the
		 * <tt>assertExpectedEvents()</tt> function is called, the expected events
		 * will be compared with the actual events.
		 *
		 * @param source
		 *    the object that is expected to dispatch the event
		 * @param types
		 *    the series of event types that the source object is expected to
		 *    dispatch
		 */
		protected function expectEvents(
			source : IEventDispatcher ,
			... types ) : void
		{
			for each ( var type : String in types )
			{
				expectEvent( source , type );
			}
		}

		//-------------------------------
		//
		// assertions
		//
		//-------------------------------

		/**
		 * Asserts that the expected events were dispatched. The expected events
		 * must first be recorded using the <tt>expectEvent()</tt> or
		 * <tt>expectEvents()</tt> functions.
		 *
		 * @param message
		 *    the user message to display when a test failure occurs
		 */
		public function assertExpectedEventsOccurred(
			message : String = "" ) : void
		{
			failExpectedEventsDidNotOccur( message , eventListener );
		}

		//-------------------------------
		//
		// private fail functions
		//
		//-------------------------------

		/**
		 * Fails the test case if the expected events did not actually occur.
		 */
		private function failExpectedEventsDidNotOccur(
			message : String ,
			listener : EventListener ) : void
		{
			if ( listener.verifyExpectedEventsOccurred() == false )
			{
				failWithUserMessage(
					message ,
					"Expected events:<" + listener.expectedEventTypes +
					"> but heard events:<" + listener.actualEventTypes + ">" );
			}
		}


		/**
		 * Private function duplicated from <code>Assert</code>. Ideally this
		 * would be protected in the FlexUnit <code>Assert</code> class instead.
		 */
		private static function failWithUserMessage(
			userMessage : String ,
			failMessage : String ) : void
		{
			if ( userMessage.length > 0 )
			{
				userMessage += " - ";
			}

			throw new AssertionFailedError( userMessage + failMessage );
		}
	}
}