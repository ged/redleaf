#!/usr/bin/env ruby

require 'redleaf'
require 'redleaf/constants'


module Redleaf::TestConstants
	include Redleaf::Constants,
	        Redleaf::Constants::CommonNamespaces

	unless defined?( TEST_NAMESPACE )
		TEST_NAMESPACE = FOAF

		MY_FOAF = Redleaf::Namespace.new( 'http://deveiate.org/foaf.xml#' )
		ME = MY_FOAF[:me]

		TEST_FOAF_TRIPLES = [
	        [ ME,       RDF[:type],                 FOAF[:Person] ],
	        [ ME,       FOAF[:name],                "Michael Granger" ],
	        [ ME,       FOAF[:givenname],           "Michael" ],
	        [ ME,       FOAF[:family_name],         "Granger" ],
	        [ ME,       FOAF[:homepage],            URI.parse('http://deveiate.org/') ],
	        [ ME,       FOAF[:workplaceHomepage],   URI.parse('http://laika.com/') ],
	        [ ME,       FOAF[:phone],               URI.parse('tel:303.555.1212') ],
	        [ ME,       FOAF[:mbox_sha1sum],        "8680b054d586d747a6fcb7046e9ce7cb39554404"],
	        [ ME,       FOAF[:knows],               :mahlon ],
	        [ :mahlon,  RDF[:type],                 FOAF[:Person] ],
	        [ :mahlon,  FOAF[:mbox_sha1sum],        "fd2b68f1f42cf523276824cb93261b0de58621b6" ],
	        [ :mahlon,  FOAF[:name],                "Mahlon E Smith" ],
		]

	end
	
end

