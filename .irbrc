#!/usr/bin/ruby -*- ruby -*-

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.expand_path
	libdir = basedir + "lib"
	extdir = basedir + "ext"

	puts ">>> Adding #{libdir} to load path..."
	$LOAD_PATH.unshift( libdir.to_s )

	puts ">>> Adding #{extdir} to load path..."
	$LOAD_PATH.unshift( extdir.to_s )
}


# Try to require the 'thingfish' library
begin
	require 'redleaf'
	
	if $DEBUG
		Redleaf.logger.level = Logger::DEBUG
	end	
rescue => e
	$stderr.puts "Ack! Redleaf library failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end

