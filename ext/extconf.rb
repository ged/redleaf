#!/usr/bin/env ruby

require 'mkmf'
require 'fileutils'

ADDITIONAL_LIBRARY_DIRS = %w[
	/usr/local/lib
	/opt/lib
	/opt/local/lib
]
ADDITIONAL_INCLUDE_DIRS = %w[
	/usr/local/include
	/opt/include
	/opt/local/include
]

$CFLAGS << ' -Wall' << ' -ggdb' << ' -DDEBUG'

def fail( *messages )
	$stderr.puts( *messages )
	exit( 1 )
end


dir_config( 'redland' )

find_library( 'rdf', 'librdf_new_world', *ADDITIONAL_LIBRARY_DIRS ) or
	fail( "Could not find Redland RDF library (http://librdf.org/)." )
find_header( 'redland.h', *ADDITIONAL_INCLUDE_DIRS )  or fail( "missing redland.h" )

have_header( 'stdio.h' )    or fail( "missing stdio.h" )
have_header( 'string.h' )   or fail( "missing string.h" )
have_header( 'inttypes.h' ) or fail( "missing inttypes.h" )

create_makefile( 'redleaf_ext' )
