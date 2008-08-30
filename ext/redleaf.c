/* 
 * Redleaf -- an RDF library for Ruby
 * $Id$
 * 
 * Authors
 * 
 * - Michael Granger <ged@FaerieMUD.org>
 * - Mahlon Smith <mahlon@martini.nu>
 * 
 * Copyright (c) 2008, Michael Granger and Mahlon Smith
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
VALUE rb_cURI = Qnil;

librdf_world *rleaf_rdf_world = NULL;

const librdf_uri *rleaf_xsd_string_typeuri;
const librdf_uri *rleaf_xsd_float_typeuri;
const librdf_uri *rleaf_xsd_decimal_typeuri;
const librdf_uri *rleaf_xsd_integer_typeuri;
const librdf_uri *rleaf_xsd_boolean_typeuri;


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
static void rleaf_redleaf_finalizer( VALUE unused ) {
	if ( rleaf_rdf_world ) {
		rleaf_log( "debug", "Freeing librdf world." );
		// librdf_free_world( rleaf_rdf_world );
		rleaf_rdf_world = NULL;
	} else {
		rleaf_log( "debug", "librdf world was NULL, so not trying to free it." );
	}
}


/* 
 * Map a librdf log level enum value onto a level name suitable for passing to the Logger.
 */
static const char *rleaf_message_level_name( librdf_log_level level ) {
	switch( level ) {
		case LIBRDF_LOG_NONE:
		case LIBRDF_LOG_DEBUG:
		return "debug";
		
		case LIBRDF_LOG_INFO:
		return "info";
		
		case LIBRDF_LOG_WARN:
		return "warn";
		
		case LIBRDF_LOG_ERROR:
		return "error";
		
		case LIBRDF_LOG_FATAL:
		return "fatal";
		
		default:
		return "debug";
	}
}



/* 
 * Log handler function for transforming rdflib log messages into Redleaf ones.
 */
static int rleaf_rdflib_log_handler( void *user_data, librdf_log_message *message ) {
	librdf_log_level level = librdf_log_message_level( message );
	/* librdf_log_facility facility = librdf_log_message_facility( message ); */
	const char *msg = librdf_log_message_message( message );

	rleaf_log( rleaf_message_level_name(level), msg );

	return 1;
}




/* --------------------------------------------------------------
 * Initializer
 * -------------------------------------------------------------- */

void Init_redleaf_ext( void ) {
	/* Load the Redland module from the Ruby source */
	rb_require( "redleaf" );
	rleaf_mRedleaf = rb_define_module( "Redleaf" );

	/* Get references to class objects we'll use a lot */
	rb_require( "uri" );
	rb_cURI = rb_const_get( rb_cObject, rb_intern("URI") );

	/* Set up the world and the finalizer for it */
	rleaf_rdf_world = librdf_new_world();
	librdf_world_open( rleaf_rdf_world );
	rb_set_end_proc( rleaf_redleaf_finalizer, 0 ); 

	/* Hook up the Redland global logger function to Redleaf's Logger instance */
	librdf_world_set_logger( rleaf_rdf_world, NULL, rleaf_rdflib_log_handler );

	/* Set up the XSD type URI constants */
	rleaf_xsd_string_typeuri  = librdf_new_uri( rleaf_rdf_world, (unsigned char *)XSD_URI("string") );
	rleaf_xsd_float_typeuri   = librdf_new_uri( rleaf_rdf_world, (unsigned char *)XSD_URI("float") );
	rleaf_xsd_decimal_typeuri = librdf_new_uri( rleaf_rdf_world, (unsigned char *)XSD_URI("decimal") );
	rleaf_xsd_integer_typeuri = librdf_new_uri( rleaf_rdf_world, (unsigned char *)XSD_URI("integer") );
	rleaf_xsd_boolean_typeuri = librdf_new_uri( rleaf_rdf_world, (unsigned char *)XSD_URI("boolean") );

	/* Initialize all the other classes */
	rleaf_init_redleaf_graph();
	rleaf_init_redleaf_parser();
	rleaf_init_redleaf_statement();
}

