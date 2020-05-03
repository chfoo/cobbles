package cobbles.test;

import utest.Assert;
import utest.Async;

class TestMarkup extends BaseTestCase {
    public function test(asyncHandle:Async) {
        #if js
        loadAndRun(asyncHandle, _test);
        #else
        loadAndRun(asyncHandle, _test);
        #end
    }

    function _test(library:Library) {
        final engine = new Engine(library);

        engine.addMarkup("<span size='40pt' color='#ff3333'>Hel͜lo<br/>wo̎rld! يونيكود</span>");
        engine.layOut();

        Assert.pass();
    }
}
