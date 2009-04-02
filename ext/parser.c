/* 
 * Redleaf::Parser -- RDF parser class
 * $Id$
 * --
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

VALUE rleaf_cRedleafParser;


/* --------------------------------------------------
 *	Memory-management functions
 * -------------------------------------------------- */

/*
 * Allocation function
 */
static librdf_parser *
rleaf_parser_alloc( const char *name ) {
	librdf_parser *ptr = librdf_new_parser( rleaf_rdf_world, name, NULL, NULL );
	return ptr;
}


/*
 * GC Mark function
static void 
rleaf_parser_gc_mark( librdf_parser *ptr ) {}
 */



/*
 * GC Free function
 */
static void 
rleaf_parser_gc_free( librdf_parser *ptr ) {
	if ( ptr && rleaf_rdf_world ) {
		librdf_free_parser( ptr );
		ptr = NULL;
	}
}


/*
 * Object validity checker. Returns the data pointer.
 */
static librdf_parser *
check_parser( VALUE self ) {
	rleaf_log_with_context( self, "debug", "checking a Redleaf::Parser object (%d).", self );
	Check_Type( self, T_DATA );

    if ( !IsParser(self) ) {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected Redleaf::Parser)",
				  rb_obj_classname( self ) );
    }
	
	return DATA_PTR( self );
}


/*
 * Fetch the data pointer and check it for sanity.
 */
librdf_parser *
rleaf_get_parser( VALUE self ) {
	librdf_parser *parser = check_parser( self );

	rleaf_log_with_context( self, "debug", "fetching a Parser <%p>.", parser );
	if ( !parser )
		rb_fatal( "Use of uninitialized Parser" );

	return parser;
}



/* --------------------------------------------------------------
 * Class methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Parser.allocate   -> parser
 *
 *  Virtual method: Allocate a new instance of a subclass of Redleaf::Parser.
 *
 */
static VALUE 
rleaf_redleaf_parser_s_allocate( VALUE klass ) {
	return Data_Wrap_Struct( klass, NULL, rleaf_parser_gc_free, 0 );
}


/*
 *  call-seq:
 *     Redleaf::Parser.features   -> hash
 *
 *  Return a Hash of supported features from the underlying Redland library.
 *
 *     Redleaf::Parser.features
 *     # => {"raptor"       => "", 
 *           "grddl"        => "Gleaning Resource Descriptions from Dialects of Languages", 
 *           "rdfxml"       => "RDF/XML",
 *           "guess"        => "Pick the parser to use using content type and URI", 
 *           "rdfa"         => "RDF/A via librdfa",
 *           "trig"         => "TriG - Turtle with Named Graphs", 
 *           "turtle"       => "Turtle Terse RDF Triple Language",
 *           "ntriples"     => "N-Triples", 
 *           "rss-tag-soup" => "RSS Tag Soup"}
 */
static VALUE
rleaf_redleaf_parser_s_features( VALUE klass ) {
	VALUE features = rb_hash_new();
	int i = 0;
	const char *name, *label;

	while ( (librdf_parser_enumerate(rleaf_rdf_world, i, &name, &label)) == 0 ) {
		VALUE namestr = name ? rb_str_new2( name ) : rb_str_new( NULL, 0 );
		VALUE labelstr = label ? rb_str_new2( label ) : rb_str_new( NULL, 0 );
		
		rb_hash_aset( features, namestr, labelstr );
		i++;
	}

	return features;
}


/*
	-- Redleaf::Parser.guess_type( mimetype=nil, buffer=nil, uri=nil )
	-- Redleaf::Parser.guess_type_from_buffer( buffer )
	-- Redleaf::Parser.guess_type_from_mimetype( mimetype )
	-- Redleaf::Parser.guess_type_from_uri( uri )
	const char* librdf_parser_guess_name( const char *mime_type, unsigned char *buffer,
										  unsigned char *identifier );
 */

/*
 *  call-seq:
 *     Redleaf::Parser.guess_type( mimetype=nil, buffer=nil, uri=nil )   -> string
 *
 *  Guess the type of parser required given one or more of a +mimetype+, a +buffer+ containing
 *  RDF content, and/or an RDF +uri+.
 *
 */
static VALUE
rleaf_redleaf_parser_s_guess_type( int argc, VALUE *argv, VALUE self ) {
	VALUE mimeobj = Qnil, bufobj = Qnil, uriobj = Qnil;
	unsigned char *buffer = NULL, *uri = NULL;
	const char  *mimetype = NULL, *guess;
	
	rb_scan_args( argc, argv, "03", &mimeobj, &bufobj, &uriobj );
	
	if ( mimeobj ) {
		mimetype = (const char *)RSTRING_PTR(rb_obj_as_string(mimeobj));
	}
	if ( bufobj ) {
		buffer = (unsigned char *)RSTRING_PTR(rb_obj_as_string(bufobj));
	}
	if ( uriobj ) {
		uri = (unsigned char *)RSTRING_PTR(rb_obj_as_string(uriobj));
	}
	
	guess = librdf_parser_guess_name( mimetype, buffer, uri );

	if ( guess == NULL ) return Qnil;
	
	return rb_str_new2( guess );
}


/* --------------------------------------------------------------
 * Instance methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Parser.new()         -> parser
 *
 *  Initialize an instance of a subclass of Redleaf::Parser.
 *
 */
static VALUE 
rleaf_redleaf_parser_initialize( VALUE self ) {
	rleaf_log_with_context( self, "debug", "Initializing %s 0x%x", rb_obj_classname(self), self );

	if ( !check_parser(self) ) {
		librdf_parser *parser;
		VALUE type = Qnil;
		const char *typename;

		/* Get the backend name */
		type = rb_funcall( CLASS_OF(self), rb_intern("validated_parser_type"), 0 );
		typename = StringValuePtr( type );
		
		DATA_PTR( self ) = parser = rleaf_parser_alloc( typename );
		
	} else {
		rb_raise( rleaf_eRedleafError,
				  "Cannot re-initialize a parser once it's been created." );
	}

	return self;
}


/*
 *  call-seq:
 *     parser.accept_header   -> string
 *
 *  Return an HTTP Accept header value for the parser. 
 *
 *     Redleaf::Parser.new.accept_header
 *     # => "application/rdf+xml, text/rdf;q=0.6"
 */
static VALUE
rleaf_redleaf_parser_accept_header( VALUE self ) {
	librdf_parser *parser = rleaf_get_parser( self );
	VALUE header;
	char *rawheader;
	
	rawheader = librdf_parser_get_accept_header( parser );
	header = rb_str_new2( rawheader );
	xfree( rawheader );
	
	return header;
}


/*
 *  call-seq:
 *     parser.parse( string )   -> graph
 *
 *  Parse the content in the specified +string+ and return a Redleaf::Graph containing any
 *  resulting statements.
 *
 */
static VALUE
rleaf_redleaf_parser_parse( int argc, VALUE *argv, VALUE self ) {
	librdf_parser *parser = rleaf_get_parser( self );
	VALUE graphobj;
	rleaf_GRAPH *graph;
	unsigned char *string, *error_count_string;
	VALUE content = Qnil, baseuriobj = Qnil;
	VALUE parser_type = rb_funcall( CLASS_OF(self), rb_intern("parser_type"), 0, NULL );
	librdf_uri  *baseuri, *error_count_feature;
	librdf_node *error_count_node;
	long error_count = 0;

	if ( rb_scan_args(argc, argv, "11", &content, &baseuriobj) > 1 ) {
		baseuri = rleaf_object_to_librdf_uri( baseuriobj );
	} else {
		baseuri = NULL;
	}

	string = (unsigned char *)RSTRING_PTR( content );
	graphobj = rb_class_new_instance( 0, NULL, rleaf_cRedleafGraph );
	graph = rleaf_get_graph( graphobj );

	rleaf_log_with_context( self, "debug", "parsing %d bytes as %s",
		RSTRING_LEN(content), RSTRING_PTR(rb_obj_as_string(parser_type)) );
	if ( (librdf_parser_parse_string_into_model(parser, string, baseuri, graph->model)) != 0 )
		rb_raise( rleaf_eRedleafParseError, "failed to parse" );

	error_count_feature = librdf_new_uri( rleaf_rdf_world, 
		(unsigned char *)LIBRDF_PARSER_FEATURE_ERROR_COUNT );
	error_count_node = librdf_parser_get_feature( parser, error_count_feature );

	/* FIXME: I feel like there has to be a better way to do this, but I can't see what it 
	   is currently. Need to ask dajobe for advice. */
	error_count_string = librdf_node_to_string( error_count_node );
	error_count = strtol( (char *)error_count_string, NULL, 0 );
	xfree( error_count_string );

	librdf_free_node( error_count_node );
	librdf_free_uri( error_count_feature );
	if ( baseuri ) librdf_free_uri( baseuri );

	if ( error_count ) {
		rb_raise( rleaf_eRedleafParseError, "%ld errors", error_count );
	} else {
		return graphobj;
	}
}



/*
 * 
 */
void rleaf_init_redleaf_parser( void ) {
	rleaf_log( "debug", "Initializing Redleaf::Parser" );

#ifdef FOR_RDOC
	rleaf_mRedleaf = rb_define_module( "Redleaf" );
#endif

	rleaf_cRedleafParser = rb_define_class_under( rleaf_mRedleaf, "Parser", rb_cObject );


	/* Class methods */
	rb_define_alloc_func( rleaf_cRedleafParser, rleaf_redleaf_parser_s_allocate );
	
	rb_define_singleton_method( rleaf_cRedleafParser, "features", 
		rleaf_redleaf_parser_s_features, 0 );
	rb_define_singleton_method( rleaf_cRedleafParser, "guess_type", 
		rleaf_redleaf_parser_s_guess_type, -1 );

	/* Instance methods */
	rb_define_method( rleaf_cRedleafParser, "initialize", rleaf_redleaf_parser_initialize, 0 );
	rb_define_method( rleaf_cRedleafParser, "accept_header", rleaf_redleaf_parser_accept_header, 0 );
	rb_define_method( rleaf_cRedleafParser, "accept_header", rleaf_redleaf_parser_accept_header, 0 );

	/* TODO: support IOs as well as Strings? */
	rb_define_method( rleaf_cRedleafParser, "parse", rleaf_redleaf_parser_parse, -1 );
	
	/*

	FUTURE WORK (maybe?):

	-- #namespaces_seen_count
	int librdf_parser_get_namespaces_seen_count( librdf_parser *parser );

	-- #namespace_seen_prefixes
	const char* librdf_parser_get_namespaces_seen_prefix( librdf_parser *parser, int offset );
	
	-- #namespace_seen_uris
	librdf_uri* librdf_parser_get_namespaces_seen_uri( librdf_parser *parser, int offset );

	-- #filter_uri {|uri| return true if the parser should fetch }
	librdf_uri_filter_func librdf_parser_get_uri_filter( librdf_parser *parser, void **user_data_p );
	void librdf_parser_set_uri_filter( librdf_parser *parser, librdf_uri_filter_funcfilter, void *user_data );

	*/
}

