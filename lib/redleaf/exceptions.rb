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
	
	def_exception :Error, "Redleaf error", RuntimeError
	
	def_exception :FeatureError, "unimplemented feature", Redleaf::Error
	
end # module Redleaf


