#!/usr/bin/env ruby

require 'redleaf'
require 'redleaf/constants'


module Redleaf::TestConstants
	include Redleaf::Constants,
		Redleaf::Constants::CommonNamespaces

	TEST_NAMESPACE = FOAF
	
end

