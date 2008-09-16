/* 
 * Redleaf::Parser -- RDF parser class
 * $Id$
 * --
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

VALUE rleaf_cRedleafParser;


/* --------------------------------------------------
 *	Memory-management functions
 * -------------------------------------------------- */

/*
 * Allocation function
 */
static librdf_parser *
rleaf_parser_alloc() {
	librdf_parser *ptr = librdf_new_parser( rleaf_rdf_world, NULL, NULL, NULL );
	rleaf_log( "debug", "initialized a librdf_parser <%p>", ptr );
	return ptr;
}


/*
 * GC Mark function
 */
static void 
rleaf_parser_gc_mark( librdf_parser *ptr ) {
	rleaf_log( "debug", "in mark function for Redleaf::Parser %p", ptr );
	
	if ( ptr ) {
		rleaf_log( "debug", "marking for a librdf_parser <%p>", ptr );
	}
	
	else {
		rleaf_log( "debug", "not marking an unallocated librdf_parser" );
	}
}



/*
 * GC Free function
 */
static void 
rleaf_parser_gc_free( librdf_parser *ptr ) {
	rleaf_log( "debug", "in free function of Redleaf::Parser <%p>", ptr );

	if ( ptr && rleaf_rdf_world ) {
		rleaf_log( "debug", "Freeing librdf_parser <%p>", ptr );
		librdf_free_parser( ptr );
		ptr = NULL;
	}

	else {
		rleaf_log( "warn", "not freeing an uninitialized librdf_parser" );
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
				  rb_class2name(CLASS_OF( self )) );
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
		rb_raise( rb_eRuntimeError, "uninitialized Parser" );

	return parser;
}



/* --------------------------------------------------------------
 * Class methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Parser.allocate   -> parser
 *
 *  Allocate a new Redleaf::Parser object.
 *
 */
static VALUE 
rleaf_redleaf_parser_s_allocate( VALUE klass ) {
	return Data_Wrap_Struct( klass, rleaf_parser_gc_mark, rleaf_parser_gc_free, 0 );
}


/*
 *  call-seq:
 *     Redleaf::Parser.features   -> hash
 *
 *  Return a Hash of supported features from the underlying Redland library.
 *
 *     Redleaf::Parser.features
 *     # => {"raptor"=>"", 
 *           "grddl"=>"Gleaning Resource Descriptions from Dialects of Languages", 
 *           "rdfxml"=>"RDF/XML",
 *           "guess"=>"Pick the parser to use using content type and URI", 
 *           "rdfa"=>"RDF/A via librdfa",
 *           "trig"=>"TriG - Turtle with Named Graphs", 
 *           "turtle"=>"Turtle Terse RDF Triple Language",
 *           "ntriples"=>"N-Triples", 
 *           "rss-tag-soup"=>"RSS Tag Soup"}
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


/* --------------------------------------------------------------
 * Instance methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Parser.new()          -> parser
 *     Redleaf::Parser.new( store )   -> parser
 *
 *  Create a new Redleaf::Parser object. If the optional +store+ object is
 *  given, it is used as the backing store for the parser. If none is specified
 *  a new Redleaf::MemoryHashStore is used.
 *
 */
static VALUE 
rleaf_redleaf_parser_initialize( int argc, VALUE *argv, VALUE self ) {
	rleaf_log_with_context( self, "debug", "Initializing %s 0x%x", rb_class2name(CLASS_OF(self)), self );

	if ( !check_parser(self) ) {
		librdf_parser *parser;

		DATA_PTR( self ) = parser = rleaf_parser_alloc();
		
	} else {
		rb_raise( rb_eRuntimeError,
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
 * 
 */
void rleaf_init_redleaf_parser( void ) {
	rleaf_log( "debug", "Initializing Redleaf::Parser" );

#ifdef FOR_RDOC
	rleaf_mRedleaf = rb_define_module( "Redleaf" );
#endif

	rleaf_cRedleafParser = rb_define_class_under( rleaf_mRedleaf, "Parser", rb_cObject );

	rb_define_singleton_method( rleaf_cRedleafParser, "features", 
		rleaf_redleaf_parser_s_features, 0 );

	rb_define_alloc_func( rleaf_cRedleafParser, rleaf_redleaf_parser_s_allocate );
	
	rb_define_method( rleaf_cRedleafParser, "initialize", rleaf_redleaf_parser_initialize, -1 );
	rb_define_method( rleaf_cRedleafParser, "accept_header", rleaf_redleaf_parser_accept_header, 0 );

	
}

