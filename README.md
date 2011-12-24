# Stubble!

Stubble is a tool for `node.js` to help aid in your unit testing.  Stubble allows you
to require your source files in such a way that you can stub out any requirements you
choose to.

## Installing

    npm install stubble

## Usage

Let's say you have a simple server script, `server.js`:

    var http = require('http');

    server = http.createServer(function(req, res) {
      res.end('Hello World!');
    });

    server.listen(3000, '127.0.0.1');
    module.exports = server;

Obviously, this could be tricky to have written in a TDD fashion, as simply requiring
this script in your test would not work well.  `Stubble` to the rescue! First, create
a new `Stubble` instance with a hash of any modules you want Stubble to intercept.
Assuming you are writing your tests in `Jasmine`, your spec might start by looking something
like this:

    var Stubble  = require('stubble'),
        req      = {},
        res      = {
          end: jasmine.createSpy('res.end')
        },
        server   = {
          listen: jasmine.createSpy('server.listen')
        },
        httpMock = {
          createServer: jasmine.createSpy('http.createServer').andReturn(server)
        },
        stub = new Stubble(http: httpMock);

Now that you have your `Stubble` instance, you can use this to require your
module and make assertions against it.

    var returned = stub.require('./server');
    describe('server', function() {

      it('creates a server', function() {
        expect(http.createServer).toHaveBeenCalled();
      });

      it('calls res.end', function() {
        http.createServer.mostRecentCall.args[0](req, res);
        expect(res.end).toHaveBeenCalledWith('Hello World!');
      });

      it('starts the server', function() {
        expect(server.listen).toHaveBeenCalledWith(3000, '127.0.0.1');
      });

      it('exports the server', function() {
        expect(returned).toEqual(server);
      });
    });

You can even make specific assertions about the `require` calls that were made.

    expect(stub.required('http').toEqual(1);
    expect(stub.required('path').toEqual(0);

## Testing
Testing this package requires the global `jasmine-node` module.


