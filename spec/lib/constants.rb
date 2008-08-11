#!/usr/bin/env ruby

require 'redleaf'
require 'redleaf/constants'


module Redleaf::TestConstants
	include Redleaf::Constants,
		Redleaf::Constants::CommonNamespaces

	TEST_NAMESPACE = Redleaf::Namespace.new( 'http://xmlns.com/foaf/0.1/' )
	
end

