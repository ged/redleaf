#!/usr/bin/env ruby

require 'e2mmap' 
require 'redleaf'

# A collection of exception classes used in Redleaf
# 
# == Subversion Id
#
#  $Id$
# 
# == Authors
# 
# * Michael Granger <ged@FaerieMUD.org>
# * Mahlon Smith <mahlon@martini.nu>
# 
# :include: LICENSE
#
#---
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
module Redleaf
	extend Exception2MessageMapper
	
	class Error < RuntimeError; end
	def_e2message Redleaf::Error, "Redleaf error"
	
	class FeatureError < Redleaf::Error; end
	def_e2message Redleaf::FeatureError, "unimplemented feature"
	
end # module Redleaf


