#!/usr/bin/ruby
# coding: utf-8

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent

	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	$LOAD_PATH.unshift( libdir.to_s ) unless $LOAD_PATH.include?( libdir.to_s )
	$LOAD_PATH.unshift( extdir.to_s ) unless $LOAD_PATH.include?( extdir.to_s )
}

# require 'simplecov'
# SimpleCov.start do
#	add_filter 'spec'
# end

require 'rspec'
require 'pp'
require 'yaml'

require 'redleaf'
require 'spec/lib/constants'


### RSpec helper functions.
module Redleaf::SpecHelpers
	include Redleaf::TestConstants

	class ArrayLogger
		### Create a new ArrayLogger that will append content to +array+.
		def initialize( array )
			@array = array
		end

		### Write the specified +message+ to the array.
		def write( message )
			@array << message
		end

		### No-op -- this is here just so Logger doesn't complain
		def close; end

	end # class ArrayLogger


	unless defined?( LEVEL )
		LEVEL = {
			:debug => Logger::DEBUG,
			:info  => Logger::INFO,
			:warn  => Logger::WARN,
			:error => Logger::ERROR,
			:fatal => Logger::FATAL,
		}
	end


	###############
	module_function
	###############

	### Make an easily-comparable version vector out of +ver+ and return it.
	def vvec( ver )
		return ver.split('.').collect {|char| char.to_i }.pack('N*')
	end


	### Reset the logging subsystem to its default state.
	def reset_logging
		Redleaf.reset_logger
	end


	### Alter the output of the default log formatter to be pretty in SpecMate output
	def setup_logging( level=Logger::FATAL )

		# Turn symbol-style level config into Logger's expected Fixnum level
		if Redleaf::Loggable::LEVEL.key?( level )
			level = Redleaf::Loggable::LEVEL[ level ]
		end

		logger = Logger.new( $stderr )
		Redleaf.logger = logger
		Redleaf.logger.level = level

		# Only do this when executing from a spec in TextMate
		if ENV['HTML_LOGGING'] || (ENV['TM_FILENAME'] && ENV['TM_FILENAME'] =~ /_spec\.rb/)
			Thread.current['logger-output'] = []
			logdevice = ArrayLogger.new( Thread.current['logger-output'] )
			Redleaf.logger = Logger.new( logdevice )
			# Redleaf.logger.level = level
			Redleaf.logger.formatter = Redleaf::HtmlLogFormatter.new( Redleaf.logger )
		end
	end


	### Load the test config if it exists and return the specified +section+ of the config 
	### as a Hash. If the file doesn't exist, or the specified section doesn't exist, an
	### empty Hash will be returned.
	def get_test_config( section )
		return {} unless TESTING_CONFIG_FILE.exist?

		Redleaf.logger.debug "Trying to load test config: %s" % [ TESTING_CONFIG_FILE ]

		begin
			config = YAML.load_file( TESTING_CONFIG_FILE )
			if config[ section ]
				Redleaf.logger.debug "Loaded the config, returning the %p section: %p." %
					[ section, config[section] ]
				return config[ section ]
			else
				Redleaf.logger.debug "No %p section in the config (%p)." % [ section, config ]
				return {}
			end
		rescue => err
			Redleaf.logger.error "Test config failed to load: %s: %s: %s" %
				[ err.class.name, err.message, err.backtrace.first ]
			return {}
		end
	end


	### Create an instance of the specified +storeclass+, and if doing
	### so raises a Redleaf::StoreCreationError, convert it to a 'pending'
	### with a (hopefully) helpful suggestion about how to make it work.
	def safely_create_store( storeclass, *args )
		return storeclass.new( *args )
	rescue Redleaf::StoreCreationError => err
		config = get_test_config( storeclass.backend.to_s )

		if !config.empty?
			msg = err.message + "\n"
			msg << "Loaded the following config from %s:\n" % [ TESTING_CONFIG_FILE ]
			PP.pp( config, msg )

			pending( msg )
		else
			msg = err.message + "\n"
			msg << "You might want to try adding a '%s' section to %s \n" %
				[ storeclass.backend, TESTING_CONFIG_FILE ]
			msg << "and verify that the connection criteria are correct.\n"
			msg << "See the 'Testing' section of the README for more info."

			pending( msg )
		end
	end

end



### Mock with Rspec
RSpec.configure do |config|
	config.mock_with :rspec

	config.include( Redleaf::TestConstants )
	config.include( Redleaf::SpecHelpers )

	config.filter_run_excluding( :ruby_1_9_only => true ) if
		Redleaf::SpecHelpers.vvec( RUBY_VERSION ) < Redleaf::SpecHelpers.vvec('1.9.0')
end



# vim: set nosta noet ts=4 sw=4:

