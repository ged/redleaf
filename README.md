# Redleaf

* http://deveiate.org/projects/Redleaf

## Description

Redleaf is an RDF library for Ruby. It's composed of a hand-written binding
for the Redland RDF Library, and a high-level layer that adds some idioms that
Rubyists might find more familiar.

It currently binds a good slice of the functionality that is offered by
Redland, but is still missing a few features. There are plans to add them in
the near future. We've built and deployed projects using it, but the API may
have to change somewhat as we learn more.


## Installation

After installing Redland from http://librdf.org/:

    gem install redleaf


## Contributing

You can check out the current development source with Mercurial like so:

    hg clone http://repo.deveiate.org/Redleaf

Or if you prefer Git, via its Github mirror:

    https://github.com/ged/redleaf

After checking out the source, install Hoe (gem install hoe) if you haven't 
already and run:

	$ rake newb

This task will install any missing dependencies, run the tests/specs, and
generate the API documentation.


### RDBMS-backed Store Tests

Note that the Redleaf::Store classes that store triples in an RDBMS actually
do connect to a database. While this is not ideal (I'd much rather they work
in isolation), it can't be helped if the corresponding bindings are to be
testable. Connection errors should be handled gracefully as 'Pending'
examples, but if you want to exercise one or more of them, just make a YAML
file called 'test-config.yml' in the base directory, and add a Hash for each
backend you wish to test with the requisite connection information. An example
is provided as 'test-config.yml.example'.

### W3C and RDFa Auto-Generated Tests

Redleaf includes an optional (and only partially-finished) implementation of
the W3C RDF test suite (http://www.w3.org/TR/rdf-testcases/) and the RDFa test
suite (http://www.w3.org/2006/07/SWD/RDFa/testsuite/) that run using Redleaf.
There are rake tasks (`w3ctests` and `rdfatests` respecively) that will fetch
the latest test manifests and data files and generate specs in the spec/
directory that then are included in the normal 'rake spec' run.

There are currently a large number of failures in the W3C test suite, but I've
yet to determine whether they indicate a problem in Redleaf, Redland, or with
the way I'm generating the specs. Suggestions or help in fixing them would be
greatly appreciated.

The tests are really not that useful to the end-user (IMO), so they're not
distributed in the gem, and I'd ask that you only run them if you're
interested in helping out with them, as they do fetch files from other
peoples' servers (albeit with a sleep between each request).

See the spec/README file for more information on what the various files under
spec/ do.


## Contributors

* Thanks to Leslie Wu (lwu2 at graphics.stanford.edu) for her suggestions and
  bug reports.
* Thanks to Gregg Kellogg (gregg at kellogg-assoc.com) for suggestions
  regarding the testing of the RDBMS-backed stores.


## License

Copyright (c) 2008-2011, Michael Granger
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the author/s, nor the names of the project's
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

