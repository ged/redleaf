#!/usr/bin/env ruby

#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.expand_path
	libdir = basedir + "lib"
	extdir = basedir + "ext"

	puts ">>> Adding #{libdir} to load path..."
	$LOAD_PATH.unshift( libdir.to_s )

	puts ">>> Adding #{extdir} to load path..."
	$LOAD_PATH.unshift( extdir.to_s )
}

require 'redleaf'
require 'ipaddr'
require 'logger'

Redleaf.logger.level = Logger::DEBUG

# There's almost certainly an actual URI for IP addresses, but I 
# can't find it
IANA_NUMBERS = Redleaf::Namespace.new( 'http://www.iana.org/numbers/' )

Redleaf::NodeUtils.register_new_class( IPAddr, IANA_NUMBERS[:ipaddr] ) do |addr|
	af = case addr.family
	     when Socket::AF_INET then "ipv4"
	     when Socket::AF_INET6 then "ipv6"
	     else "unknown" end
	ip = addr.to_string

	# Regretably the only way to actually get the mask_addr as a string
	mask = addr.send( :_to_string, addr.instance_variable_get(:@mask_addr) )

	"%s:%s/%s" % [ af, ip, mask ]
end

Redleaf::NodeUtils.register_new_type( IANA_NUMBERS[:ipaddr] ) do |literal_string|
	IPAddr.new( literal_string[/.*:(.*)/, 1] )
end

addr = IPAddr.new( '192.168.16.96/27' )   # =>

# Make a tuple that contains the typed literal's type URI and its 
# canonical representation
literal = Redleaf::NodeUtils.make_object_typed_literal( addr )
literal # =>

# Now translate that tuple back to a Ruby object
obj = Redleaf::NodeUtils.make_typed_literal_object( *literal )
p obj
