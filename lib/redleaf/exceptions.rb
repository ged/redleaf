#!/usr/bin/env ruby

require 'e2mmap' 
require 'redleaf'

#--
# A collection of exception classes used in Redleaf
# 
module Redleaf # :nodoc:
	extend Exception2MessageMapper
	
	# The base error class for exceptions raised from Redleaf.
	class Error < RuntimeError; end
	def_e2message Redleaf::Error, "Redleaf error"
	
	# The exception raised when a Redland feature is not implemented in
	# the current environment (e.g., the PostgreSQL store is used on a
	# machine which doesn't have it compiled into its Redland libraries.)
	class FeatureError < Redleaf::Error; end
	def_e2message Redleaf::FeatureError, "unimplemented feature"
	
	# The exception raised when a Redleaf::Parser can't parse its input.
	class ParseError < Redleaf::Error; end
	def_e2message Redleaf::ParseError, "parse error"
	
end # module Redleaf


