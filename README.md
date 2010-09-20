# Redleaf

Redleaf is an RDF library for Ruby. It's composed of a hand-written binding for the Redland RDF Library, and a high-level layer that adds some idioms that Rubyists might find familiar.

It currently binds a good slice of the functionality that is offered by Redland, but is still missing a few features. There are plans to add them in the near future. We've built and deployed projects using it, but the API may have to change somewhat as we learn more.

You can help out by checking out the current development source with Mercurial from the following URL:

> http://repo.deveiate.org/Redleaf

The project page also has more details and the most-recent API documentation:

> http://deveiate.org/projects/Redleaf

## Testing

Provided you have Rake and RSpec (`gem install rake rspec` if you don't)
installed, you can run the tests in this directory with the command:

    $ rake spec

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

## Authors

* Michael Granger (ged@FaerieMUD.org)


## Contributors

* Thanks to Leslie Wu (lwu2 at graphics.stanford.edu) for her suggestions and
  bug reports.
* Thanks to Gregg Kellogg (gregg at kellogg-assoc.com) for suggestions
  regarding the testing of the RDBMS-backed stores.


## License

See the LICENSE file for additional licensing details.
