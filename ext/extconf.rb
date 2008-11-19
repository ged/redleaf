#!/usr/bin/env ruby

require 'mkmf'
require 'fileutils'

ADDITIONAL_LIBRARY_DIRS = %w[
	/usr/local/lib
	/opt/lib
	/opt/local/lib
]

$CFLAGS << ' -Wall' << ' -ggdb' << ' -DDEBUG'

def fail( *messages )
	$stderr.puts( *messages )
	exit( 1 )
end


dir_config( 'redland' )

have_header( 'redland.h' )  or fail( "missing redland.h" )
have_header( 'stdio.h' )    or fail( "missing stdio.h" )
have_header( 'string.h' )   or fail( "missing string.h" )
have_header( 'inttypes.h' ) or fail( "missing inttypes.h" )

find_library( 'rdf', 'librdf_new_world', *ADDITIONAL_LIBRARY_DIRS ) or
	fail( "Could not find Redland RDF library (http://librdf.org/)." )

create_makefile( 'redleaf_ext' )
