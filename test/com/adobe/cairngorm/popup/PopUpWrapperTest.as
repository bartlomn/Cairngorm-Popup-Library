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
	import mx.controls.Label;
	import mx.core.DeferredInstanceFromClass;

	public class PopUpWrapperTest extends PopUpBaseTestable
	{
		private var wrapper:PopUpWrapper;

		override protected function createPopUpComponent():PopUpBase
		{
			wrapper=new PopUpWrapper();
			wrapper.popup=new DeferredInstanceFromClass(Label);
			return wrapper;
		}

		public function testThrowsErrorWhenPopUpUnspecified():void
		{
			wrapper.popup=null;

			try
			{
				wrapper.open=true;
				fail("An error should have occurred.");
			}
			catch (e:Error)
			{
				assertEquals("The error has the wrong ID.", -50, e.errorID);
			}
		}

		public function testReusesTheSameInstanceOfPopupView():void
		{
			wrapper.reuse=true;
			assertPopUpOpenedTwice();

			assertEquals("The two popup view instances should be the same.", PopUpEvent(actualEvents[0]).popup, PopUpEvent(actualEvents[1]).popup);

		}
	}
}