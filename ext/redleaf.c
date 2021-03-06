/*
 * Redleaf -- an RDF library for Ruby
 * $Id$
 *
 * Authors
 *
 * - Michael Granger <ged@FaerieMUD.org>
 *
 * Copyright (c) 2008, 2009 Michael Granger
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 *  * Redistributions in binary form must reproduce the above copyright notice, this
 *    list of conditions and the following disclaimer in the documentation and/or
 *    other materials provided with the distribution.
 *
 *  * Neither the name of the authors, nor the names of its contributors may be used to
 *    endorse or promote products derived from this software without specific prior
 *    written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *
 */

#include "redleaf.h"

VALUE rleaf_mRedleaf;
VALUE rleaf_mRedleafNodeUtils;

VALUE rleaf_cRedleafNamespace;

VALUE rleaf_eRedleafError;
VALUE rleaf_eRedleafFeatureError;
VALUE rleaf_eRedleafStoreCreationError;
VALUE rleaf_eRedleafParseError;

VALUE rleaf_rb_cURI;

librdf_world *rleaf_rdf_world = NULL;

const librdf_uri *rleaf_xsd_string_typeuri;
const librdf_uri *rleaf_xsd_float_typeuri;
const librdf_uri *rleaf_xsd_decimal_typeuri;
const librdf_uri *rleaf_xsd_integer_typeuri;
const librdf_uri *rleaf_xsd_boolean_typeuri;

ID rleaf_anon_bnodeid;

const char *rleaf_loglevels[] = {
	"debug",
	"debug",
	"info",
	"warn",
	"error",
	"fatal",
};

const char *rleaf_logfacility[] = {
	"",
	"Concepts",
	"Digest",
	"Files",
	"Hash",
	"Init",
	"Iterator",
	"List",
	"Model",
	"Node",
	"Parser",
	"Query",
	"Serializer",
	"Statement",
	"Storage",
	"Stream",
	"URI",
	"UTF8",
	"Memory",
	"Raptor"
};


/*
 * Log a message to the given +context+ object's logger.
 */
void
#ifdef HAVE_STDARG_PROTOTYPES
rleaf_log_with_context( VALUE context, const char *level, const char *fmt, ... )
#else
rleaf_log_with_context( VALUE context, const char *level, const char *fmt, va_dcl )
#endif
{
	char buf[BUFSIZ];
	va_list	args;
	VALUE logger = Qnil;
	VALUE message = Qnil;

	/* Don't log stuff if the world is already gone. */
	if ( ! rleaf_rdf_world ) return;

	va_start( args, fmt );
	vsnprintf( buf, BUFSIZ, fmt, args );
	message = rb_str_new2( buf );

	logger = rb_funcall( context, rb_intern("log"), 0, 0 );
	rb_funcall( logger, rb_intern(level), 1, message );

	va_end( args );
}


/*
 * Log a message to the global logger.
 */
void
#ifdef HAVE_STDARG_PROTOTYPES
rleaf_log( const char *level, const char *fmt, ... )
#else
rleaf_log( const char *level, const char *fmt, va_dcl )
#endif
{
	char buf[BUFSIZ];
	va_list	args;
	VALUE logger = Qnil;
	VALUE message = Qnil;

	/* Don't log stuff if the world is already gone. */
	if ( ! rleaf_rdf_world ) return;

	va_init_list( args, fmt );
	vsnprintf( buf, BUFSIZ, fmt, args );
	message = rb_str_new2( buf );

	logger = rb_funcall( rleaf_mRedleaf, rb_intern("logger"), 0, 0 );
	rb_funcall( logger, rb_intern(level), 1, message );

	va_end( args );
}



/* --------------------------------------------------------------
 * Utility functions for LibRDF interaction
 * -------------------------------------------------------------- */

/*
 * Give Redland a chance to clean up all of its stuff.
 */
static void
rleaf_redleaf_finalizer( VALUE unused ) {
	if ( rleaf_rdf_world ) {
		rleaf_log( "debug", "Freeing librdf world." );
		// librdf_free_world( rleaf_rdf_world );
		rleaf_rdf_world = NULL;
	} else {
		rleaf_log( "debug", "librdf world was NULL, so not trying to free it." );
	}
}


/*
 * Log handler function for transforming rdflib log messages into Redleaf ones.
 */
static int
rleaf_rdflib_log_handler( void *user_data, librdf_log_message *message ) {
	const char *level    = rleaf_loglevels[ librdf_log_message_level(message) ];
	const char *facility = rleaf_logfacility[ librdf_log_message_facility(message) ];
	const char *msg      = librdf_log_message_message( message );
	raptor_locator *loc  = librdf_log_message_locator( message );
	char *location       = NULL;
	size_t bufsize   = 0;

	if ( loc ) {
		/* The first call sizes the string */
		bufsize = raptor_locator_format( location, 0, loc );
		location = ALLOCA_N( char, bufsize + 1 );
		raptor_locator_format( location, bufsize, loc );

		rleaf_log( level, "{%s} %s at %s", facility, msg, location );
	} else {
		rleaf_log( level, "{%s} %s", facility, msg );
	}

	return 1;
}


/*
 *  call-seq:
 *     Redleaf.generate_id   -> symbol
 *
 *  Generate a unique ID (for anonymous bnodes) and return it as a Symbol.
 */
static VALUE
rleaf_redleaf_generate_id( VALUE klass ) {
	librdf_node *bnode = librdf_new_node_from_blank_identifier( rleaf_rdf_world, NULL );
	unsigned char *genid = librdf_node_get_blank_identifier( bnode );
	ID id = rb_intern( (char *)genid );

	return ID2SYM( id );
}


/*
 *
 */
static VALUE
rleaf_redleaf_make_literal_string( VALUE mod, VALUE obj ) {
	librdf_node *node;
	unsigned char *literal;
	VALUE literal_string;

	if ( TYPE(obj) == T_STRING ) {
		/* FIXME: Doesn't handle language tags */
		literal_string = rb_funcall( obj, rb_intern("dump"), 0 );
	}

	else {
		node = rleaf_value_to_librdf_node( obj );
		literal = librdf_node_to_string( node );
		literal_string = rb_str_new2( (char *)literal );

		xfree( literal );
	}

	OBJ_INFECT( literal_string, obj );
	return literal_string;
}




/* --------------------------------------------------------------
 * Initializer
 * -------------------------------------------------------------- */

void Init_redleaf_ext( void ) {
	rleaf_mRedleaf = rb_define_module( "Redleaf" );

	/* version constants */
	rb_define_const( rleaf_mRedleaf, "LIBRDF_SHORT_COPYRIGHT",
		rb_str_new2(librdf_short_copyright_string) );
	rb_define_const( rleaf_mRedleaf, "LIBRDF_COPYRIGHT",
		rb_str_new2(librdf_copyright_string) );
	rb_define_const( rleaf_mRedleaf, "LIBRDF_VERSION_STRING",
		rb_str_new2(librdf_version_string) );

	rb_define_const( rleaf_mRedleaf, "LIBRDF_VERSION_MAJOR",   INT2FIX(librdf_version_major) );
	rb_define_const( rleaf_mRedleaf, "LIBRDF_VERSION_MINOR",   INT2FIX(librdf_version_minor) );
	rb_define_const( rleaf_mRedleaf, "LIBRDF_VERSION_RELEASE", INT2FIX(librdf_version_release) );
	rb_define_const( rleaf_mRedleaf, "LIBRDF_VERSION_DECIMAL", INT2FIX(librdf_version_decimal) );

	rleaf_mRedleafNodeUtils = rb_define_module_under( rleaf_mRedleaf, "NodeUtils" );
	rleaf_cRedleafNamespace = rb_define_class_under( rleaf_mRedleaf, "Namespace", rb_cObject );

	rleaf_eRedleafError =
		rb_define_class_under( rleaf_mRedleaf, "Error", rb_eRuntimeError );
	rleaf_eRedleafFeatureError =
		rb_define_class_under( rleaf_mRedleaf, "FeatureError", rleaf_eRedleafError );
	rleaf_eRedleafStoreCreationError =
		rb_define_class_under( rleaf_mRedleaf, "StoreCreationError", rleaf_eRedleafError );
	rleaf_eRedleafParseError =
		rb_define_class_under( rleaf_mRedleaf, "ParseError", rleaf_eRedleafError );

	/* Get references to class objects we'll use a lot */
	rb_require( "uri" );
	rleaf_rb_cURI = rb_const_get( rb_cObject, rb_intern("URI") );

	/* Set the ID of the placeholder for anonymous bnodes */
	rleaf_anon_bnodeid = rb_intern( "_" );

	/* Set up the world and the finalizer for it */
	rleaf_rdf_world = librdf_new_world();
	librdf_world_open( rleaf_rdf_world );
	rb_set_end_proc( rleaf_redleaf_finalizer, 0 );

	/* Hook up the Redland global logger function to Redleaf's Logger instance */
	librdf_world_set_logger( rleaf_rdf_world, NULL, rleaf_rdflib_log_handler );

	/* Set up the XSD type URI constants */
	rleaf_xsd_string_typeuri  =
		librdf_new_uri( rleaf_rdf_world, (unsigned char *)XSD_URI("string") );
	rleaf_xsd_float_typeuri   =
		librdf_new_uri( rleaf_rdf_world, (unsigned char *)XSD_URI("float") );
	rleaf_xsd_decimal_typeuri =
		librdf_new_uri( rleaf_rdf_world, (unsigned char *)XSD_URI("decimal") );
	rleaf_xsd_integer_typeuri =
		librdf_new_uri( rleaf_rdf_world, (unsigned char *)XSD_URI("integer") );
	rleaf_xsd_boolean_typeuri =
		librdf_new_uri( rleaf_rdf_world, (unsigned char *)XSD_URI("boolean") );

	/* Initialize all the other classes */
	rleaf_init_redleaf_store();
	rleaf_init_redleaf_graph();
	rleaf_init_redleaf_parser();
	rleaf_init_redleaf_statement();
	rleaf_init_redleaf_queryresult();

	/* Define some constants */
	rb_define_const( rleaf_mRedleaf, "DEFAULT_STORE_CLASS", DEFAULT_STORE_CLASS );

	/* Add Redleaf module functions */
	rb_define_module_function( rleaf_mRedleaf, "make_literal_string",
		rleaf_redleaf_make_literal_string, 1 );
	rb_define_module_function( rleaf_mRedleaf, "generate_id", rleaf_redleaf_generate_id, 0 );

	rb_require( "redleaf" );
	rb_require( "redleaf/exceptions" );
}

