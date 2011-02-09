#!/usr/bin/env ruby

require 'mkmf'
require 'fileutils'

$CFLAGS << ' -Wall'
$CFLAGS << ' -ggdb' << ' -DDEBUG' if $DEBUG

def fail( *messages )
	$stderr.puts( *messages )
	exit( 1 )
end


dir_config( 'redland' )
if redland_config = find_executable( 'redland-config' )
	ver = `#{redland_config} --version`.chomp
	$CFLAGS << ' ' + `#{redland_config} --cflags`.chomp
	$LDFLAGS << ' ' + `#{redland_config} --libs`.chomp
else
	warn "No 'redland-config' in your path. Attempting to configure without it."
end

find_library( 'rdf', 'librdf_new_world' ) or
	fail( "Could not find Redland RDF library (http://librdf.org/)." )
find_header( 'redland.h' )  or fail( "missing redland.h" )

have_header( 'stdio.h' )    or fail( "missing stdio.h" )
have_header( 'string.h' )   or fail( "missing string.h" )
have_header( 'inttypes.h' ) or fail( "missing inttypes.h" )

have_func( 'librdf_serializer_get_description' ) or
	fail( "Your librdf is too old!" )
have_func( 'librdf_parser_get_description' ) or
	fail( "Your librdf is too old!" )



# find_library( 'efence', 'malloc', *ADDITIONAL_INCLUDE_DIRS )

create_makefile( 'redleaf_ext' )
