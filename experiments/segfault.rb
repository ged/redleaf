#!/usr/bin/env ruby

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.expand_path
	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	puts ">>> Adding #{libdir} to load path..."
	$LOAD_PATH.unshift( libdir.to_s )

	puts ">>> Adding #{extdir} to load path..."
	$LOAD_PATH.unshift( extdir.to_s )
}


# Try to require the 'thingfish' library
begin
	require 'logger'
	require 'redleaf'
	Redleaf.logger.level = Logger::DEBUG
rescue => e
	$stderr.puts "Ack! Redleaf library failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end

st = Redleaf::Statement.new
