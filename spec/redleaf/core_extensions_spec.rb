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
		String.included_modules.should_not include( Redleaf::ArrayExtensions )
	end

	it "adds extensions to core classes when install_core_extensions is called" do
		Array.should_receive( :instance_eval )
		String.should_receive( :instance_eval )

		Redleaf.install_core_extensions
	end


	describe Redleaf::ArrayExtensions do
		it "adds statement case-equality to Arrays by using the argument's #=== method if it " +
		   "is a statement" do
			ary = []
			ary.extend( Redleaf::ArrayExtensions )

			statement = mock( "redleaf statement object" )
			statement.should_receive( :is_a? ).with( Redleaf::Statement ).and_return( true )
			statement.should_receive( :=== ).with( ary ).and_return( true )

			ary.should === statement
		end
	end
	
	describe Redleaf::StringExtensions do
		before( :each ) do
			@string = ''
			@string.extend( Redleaf::StringExtensions )
		end
		

		it "adds a language-code setter to Strings" do
			@string.lang = 'en'
			@string.lang.should == :en
		end

		it "downcases the language-code part of the tag" do
			@string.lang = 'En'
			@string.lang.should == :en
		end

		it "ignores other parts of the language tag when comparing languages" do
			@string.lang = "mn-Cyrl-MN"
			@string.lang.should == :mn
		end

		it "provides an explicit getter for the whole language tag struct" do
			@string.lang = 'fr-Latn-CA'
			@string.language_tag.should == 
				Redleaf::StringExtensions::LanguageTag.new( :fr, :latn, :ca )
		end
	end

end

# vim: set nosta noet ts=4 sw=4:
