#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent
	
	libdir = basedir + "lib"
	extdir = basedir + "ext"
	
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
	$LOAD_PATH.unshift( extdir ) unless $LOAD_PATH.include?( extdir )
}

begin
	require 'spec'
	require 'spec/lib/constants'
	require 'spec/lib/helpers'

	require 'redleaf/core_extensions'
rescue LoadError
	unless Object.const_defined?( :Gem )
		require 'rubygems'
		retry
	end
	raise
end


include Redleaf::TestConstants
include Redleaf::Constants

#####################################################################
###	C O N T E X T S
#####################################################################

describe Redleaf, " core extensions" do
	include Redleaf::SpecHelpers

	it "doesn't extend core classes unless requested" do
		Array.included_modules.should_not include( Redleaf::ArrayExtensions )
	end

	it "adds extensions to core classes when install_core_extensions is called" do
		Array.should_receive( :instance_eval )

		Redleaf.install_core_extensions
	end
	
end

# vim: set nosta noet ts=4 sw=4:
