/* 
 * Redleaf::QueryResult -- RDF queryresult object class
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


/* --------------------------------------------------------------
 * Declarations
 * -------------------------------------------------------------- */
VALUE rleaf_cRedleafQueryResult;
VALUE rleaf_cRedleafBindingQueryResult;
VALUE rleaf_cRedleafBooleanQueryResult;
VALUE rleaf_cRedleafGraphQueryResult;
VALUE rleaf_cRedleafSyntaxQueryResult;


/*
 * GC Mark function
 */
static void 
rleaf_queryresult_gc_mark( librdf_query_results *ptr ) {
	rleaf_log( "debug", "in mark function for RedLeaf::QueryResult %p", ptr );
	
	if ( ptr ) {
		rleaf_log( "debug", "marking graph of rleaf_STORE <%p>", ptr );
	}
	
	else {
		rleaf_log( "debug", "not marking graph for uninitialized rleaf_STORE" );
	}
}



/*
 * GC Free function
 */
static void
rleaf_queryresult_gc_free( librdf_query_results *ptr ) {
	if ( ptr && rleaf_rdf_world ) {
		rleaf_log( "debug", "in free function of Redleaf::QueryResult <%p>", ptr );

		librdf_free_query_results( ptr );
		ptr = NULL;
	}

	else {
		rleaf_log( "warn", "not freeing an uninitialized Redleaf::QueryResult" );
	}
}


/*
 * Object validity checker. Returns the data pointer.
 */
static librdf_query_results *
check_queryresult( VALUE self ) {
	Check_Type( self, T_DATA );

    if ( !IsQueryResult(self) ) {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected a Redleaf::QueryResult)",
				  rb_class2name(CLASS_OF( self )) );
    }
	
	return DATA_PTR( self );
}


/*
 * Fetch the data pointer and check it for sanity.
 */
librdf_query_results *
rleaf_get_queryresult( VALUE self ) {
	librdf_query_results *res = check_queryresult( self );

	if ( !res ) rb_raise( rb_eRuntimeError, "uninitialized QueryResult" );

	return res;
}


/*
 * Constructor for Redleaf::Graph#execute_query
 */
VALUE
rleaf_new_queryresult( VALUE graph, librdf_query_results *res ) {
	VALUE result_class = Qnil, result = Qnil;
	
	/* Check the result type, create the appropriate result object based on the
	   type of response (is_bindings(), is_graph(), is_boolean(), etc.) */
	if ( librdf_query_results_is_bindings(res) ) {
		rleaf_log( "debug", "  result is a `bindings` result." );
		result_class = rleaf_cRedleafBindingQueryResult;
	}
	
	else if ( librdf_query_results_is_graph(res) ) {
		rleaf_log( "debug", "  result is a `graph` result." );
		result_class = rleaf_cRedleafGraphQueryResult;
	}
	
	else if ( librdf_query_results_is_boolean(res) ) {
		rleaf_log( "debug", "  result is a `boolean` result." );
		result_class = rleaf_cRedleafBooleanQueryResult;
	}
	
	else if ( librdf_query_results_is_syntax(res) ) {
		rleaf_log( "debug", "  result is a `syntax` result." );
		result_class = rleaf_cRedleafSyntaxQueryResult;
	}
	
	else {
		rb_fatal( "Unhandled query result %p", res );
	}

	result = Data_Wrap_Struct( result_class, 
		rleaf_queryresult_gc_mark, rleaf_queryresult_gc_free, res );
	rb_obj_call_init( result, 1, &graph );

	return result;
}


/* --------------------------------------------------------------
 * Class methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::QueryResult.allocate( librdf_query_results* )   -> queryresult
 *
 *  Allocate a new Redleaf::QueryResult object that will wrap the given query 
 *  results pointer.
 *
 */
static VALUE 
rleaf_redleaf_queryresult_s_allocate( VALUE klass ) {
	rb_raise( rb_eRuntimeError, "cannot allocate a %s directly.", rb_class2name(klass) );
	return Qnil;
}


/*
 *  call-seq:
 *     Redleaf::QueryResult.formatters   -> hash
 *
 *  Return a Hash of supported QueryResult formatters (the keys of which are valid)
 *  arguments to #format.
 *
 *     Redleaf::QueryResult.formatters
 *     # => {
 *       "xml" => {
 *         :uri => #<URI::HTTP:0x197648 URL:http://www.w3.org/2005/sparql-results#>,
 *         :label => "SPARQL Query Results Format 2007-06-14",
 *         :mimetype => "application/sparql-results+xml"
 *       },
 *       "json" => {
 *         :uri => #<URI::HTTP:0x1973fa URL:http://www.w3.org/2001/sw/DataAccess/json-sparql/>,
 *         :label => "JSON",
 *         :mimetype => "text/json"
 *       }
 *     }
 */
static VALUE
rleaf_redleaf_queryresult_s_formatters( VALUE klass ) {
	VALUE formatters = rb_hash_new();
	int i = 0;
	const char *name, *label, *mime_string;
	const unsigned char *uri_string;

	rleaf_log( "debug", "Finding result formatters." );
	while ( (librdf_query_results_formats_enumerate(rleaf_rdf_world, i, 
		&name, &label, &uri_string, &mime_string)) == 0 )
	{
		rleaf_log( "debug", "  adding format #%d '%s' => ( '%s', '%s', '%s' )", 
			i, name, label, uri_string, mime_string );
		VALUE subhash  = rb_hash_new();
		VALUE namestr  = name ? rb_str_new2( name ) : Qnil;
		VALUE labelstr = label ? rb_str_new2( label ) : Qnil;
		VALUE mimetype = mime_string ? rb_str_new2( mime_string ) : Qnil;
		VALUE uri = Qnil;

		if ( uri_string ) {
			rleaf_log( "debug", "  got a non-null uri_string, converting it to a URI." );
			uri = rb_funcall( rleaf_rb_cURI, rb_intern("parse"), 1, 
				rb_str_new2((const char *)uri_string) );
		}

		rleaf_log( "debug", "  setting up the subhash." );
		rb_hash_aset( subhash, ID2SYM(rb_intern("label")), labelstr );
		rb_hash_aset( subhash, ID2SYM(rb_intern("uri")), uri );
		rb_hash_aset( subhash, ID2SYM(rb_intern("mimetype")), mimetype );
		
		rleaf_log( "debug", "  adding the subhash to the rval." );
		rb_hash_aset( formatters, namestr, subhash );
		i++;
	}
	rleaf_log( "debug", "Done. Found %d result formatters.", i );

	return formatters;
}


/* --------------------------------------------------------------
 * Instance methods
 * -------------------------------------------------------------- 
 */

/*
 * Redleaf::QueryResult
 */

/*
 *  call-seq:
 *     queryresult.each { block }
 *
 *  Virtual method -- this should be overridden in all concrete subclasses.
 *
 */
static VALUE
rleaf_redleaf_queryresult_each( VALUE self ) {
	rb_raise( rb_eNotImpError, "no implementation of #each defined for %s", 
		rb_class2name(CLASS_OF(self)) );
	return Qnil;
}


/*
 * Redleaf::BindingQueryResult
 */

/*
 *  call-seq:
 *     result.bindings   -> array
 *
 *  Return an Array of the bindings (columns) that are in the rows of the result set.
 *
 *     result = graph.query( 'SELECT ?s ?p ?o WHERE { ?s ?p ?o }' )
 *     result.bindings
 *     # => [ :s, :p, :o ]
 */
static VALUE
rleaf_redleaf_bindingsqueryresult_bindings( VALUE self ) {
	librdf_query_results *res = rleaf_get_queryresult( self );
	int i, bindcount = librdf_query_results_get_bindings_count( res );
	VALUE rval = rb_ary_new();
	
	rleaf_log_with_context( self, "debug", "Fetching %d bindings.", bindcount );
	
	for ( i = 0; i < bindcount; i++ ) {
		const char *name = librdf_query_results_get_binding_name( res, i );
		rb_ary_push( rval, ID2SYM(rb_intern(name)) );
	}
	
	return rval;
}


/*
 *  call-seq:
 *     result.each {|row| }
 *
 *  Iterate over each row of the results, yielding a Hash of the bindings from the
 *  query.
 *
 *     DC = Redleaf::Constants::CommonNamespaces::DC
 *     
 *     graph.load( )
 *     result = graph.query( 'SELECT ?s ?o WHERE { ?s dc:author ?o }, :dc => DC )
 *     result.each {|row| p row }
 */
static VALUE
rleaf_redleaf_bindingsqueryresult_each( VALUE self ) {
	librdf_query_results *res = rleaf_get_queryresult( self );
	VALUE rows = rb_ivar_get( self, rb_intern("@rows") );

	if ( !rb_block_given_p() )
		rb_raise( rb_eLocalJumpError, "no block given" );

	/* If @rows is nil and there are results to fetch, fetch each row from 
	   Redland, yield it, and cache it for later. */
	if ( rows == Qnil && !librdf_query_results_finished(res) ) {
		rleaf_log_with_context( self, "debug", "Building result rows." );
		rows = rb_ary_new();
		
		int i, j, count = librdf_query_results_get_count( res );
		int bindcount = librdf_query_results_get_bindings_count( res );
	
		for ( i = 0; i < count; i++ ) {
			VALUE row = rb_hash_new();
			rleaf_log_with_context( self, "debug", "Fetching result %d/%d:", i + 1, count );
		
			for ( j = 0; j < bindcount; j++ ) {
				const char *name = librdf_query_results_get_binding_name( res, j );
				librdf_node *value = librdf_query_results_get_binding_value( res, j );

				rleaf_log_with_context( self, "debug", "  binding :%s => %s",
					name, librdf_node_to_string(value) );
				rb_hash_aset( row, ID2SYM(rb_intern(name)), rleaf_librdf_node_to_value(value) );
				
				xfree( value );
			}
			
			rb_ary_push( rows, row );
			librdf_query_results_next( res );
		}
	} else {
		rleaf_log_with_context( self, "debug", "Reusing previously-fetched rows." );
	}

	return Qnil;
}


/*
 * Redleaf::GraphQueryResult
 */

/*
 * Redleaf::BooleanQueryResult
 */

/*
 * Redleaf::SyntaxQueryResult
 */




/*
 * Redleaf QueryResult class
 */
void
rleaf_init_redleaf_queryresult( void ) {
	rleaf_log( "debug", "Initializing Redleaf::QueryResult" );

#ifdef FOR_RDOC
	rleaf_mRedleaf = rb_define_module( "Redleaf" );
#endif

	rb_require( "redleaf/queryresult" );

	/* Redleaf::QueryResult */
	rleaf_cRedleafQueryResult = rb_define_class_under( rleaf_mRedleaf, "QueryResult", rb_cObject );
	rleaf_cRedleafBindingQueryResult = rb_define_class_under( rleaf_mRedleaf, 
		"BindingQueryResult", rleaf_cRedleafQueryResult );
	rleaf_cRedleafBooleanQueryResult = rb_define_class_under( rleaf_mRedleaf, 
		"BooleanQueryResult", rleaf_cRedleafQueryResult );
	rleaf_cRedleafGraphQueryResult = rb_define_class_under( rleaf_mRedleaf, 
		"GraphQueryResult", rleaf_cRedleafQueryResult );
	rleaf_cRedleafSyntaxQueryResult = rb_define_class_under( rleaf_mRedleaf, 
		"SyntaxQueryResult", rleaf_cRedleafQueryResult );

	/* include Enumerable */
	rb_include_module( rleaf_cRedleafQueryResult, rb_mEnumerable );
	
	/*
	 * Redleaf::QueryResult
	 */
	rb_define_alloc_func( rleaf_cRedleafQueryResult, rleaf_redleaf_queryresult_s_allocate );

	/* Class methods */
	rb_define_singleton_method( rleaf_cRedleafQueryResult, "formatters", 
		rleaf_redleaf_queryresult_s_formatters, 0 );

	/* Instance methods */
	rb_define_method( rleaf_cRedleafQueryResult, "each", rleaf_redleaf_queryresult_each, 0 );


	/*

	-- #write( io )/#write( filename ) -- Blocking?
	int librdf_query_results_to_file_handle( librdf_query_results *query_results, FILE *handle, librdf_uri *format_uri, librdf_uri *base_uri );
	int librdf_query_results_to_file( librdf_query_results *query_results, const char *name, librdf_uri *format_uri, librdf_uri *base_uri );

	void librdf_free_query_results( librdf_query_results *query_results );

	int librdf_query_results_is_bindings( librdf_query_results *query_results );
	int librdf_query_results_is_boolean( librdf_query_results *query_results );
	int librdf_query_results_is_graph( librdf_query_results *query_results );
	int librdf_query_results_is_syntax( librdf_query_results *query_results );

	-- #to_json/#to_xml/#to_mimetype
	unsigned char* librdf_query_results_to_string( librdf_query_results *query_results, librdf_uri *format_uri, librdf_uri *base_uri);
	librdf_query_results_formatter* librdf_new_query_results_formatter( librdf_query_results *query_results, const char *name, librdf_uri *uri );
	librdf_query_results_formatter* librdf_new_query_results_formatter_by_mime_type( librdf_query_results *query_results,const char *mime_type );
	void librdf_free_query_results_formatter( librdf_query_results_formatter *formatter );
	int librdf_query_results_formats_check( librdf_world *world, const char *name, librdf_uri *uri, const char *mime_type );
	int librdf_query_results_formats_enumerate( librdf_world *world, unsigned int counter, const char **name, const char **label, unsigned char **uri_string, const char **mime_type );
	int librdf_query_results_formatter_write( raptor_iostream *iostr, librdf_query_results_formatter *formatter, librdf_query_results *results, librdf_uri *base_uri );

	*/


	/*
	 * Redleaf::BindingQueryResult
	 */
	rb_define_method( rleaf_cRedleafBindingQueryResult, "bindings", 
		rleaf_redleaf_bindingsqueryresult_bindings, 0 );
	rb_define_method( rleaf_cRedleafBindingQueryResult, "each", 
		rleaf_redleaf_bindingsqueryresult_each, 0 );

	/*

	-- #bindings
	int librdf_query_results_get_bindings( librdf_query_results *query_results, const char ***names, librdf_node **values );

	-- #each {|row| }
	librdf_node* librdf_query_results_get_binding_value( librdf_query_results *query_results, int offset );
	const char* librdf_query_results_get_binding_name( librdf_query_results *query_results, int offset );

	-- #method_missing( binding )
	librdf_node* librdf_query_results_get_binding_value_by_name( librdf_query_results *query_results, const char *name );

	-- #bindings_count (?)
	int librdf_query_results_get_bindings_count( librdf_query_results *query_results );

	*/
	

	/*
	 * Redleaf::GraphQueryResult
	 */

	/*
	-- Redleaf::GraphQueryResult#each {|stmt| }
	librdf_stream* librdf_query_results_as_stream( librdf_query_results *query_results );
	int librdf_query_results_get_count( librdf_query_results *query_results );
	int librdf_query_results_next( librdf_query_results *query_results );
	int librdf_query_results_finished( librdf_query_results *query_results );
	*/


	/*
	 * Redleaf::BooleanQueryResult
	 */

	/*
	
	-- #true?/false?
	-- #to_bool
	int librdf_query_results_get_boolean( librdf_query_results *query_results );

	*/
	

	/*
	 * Redleaf::SyntaxQueryResult
	 */

	/*
	-- #true?/false?
	-- #to_bool
	int librdf_query_results_get_boolean( librdf_query_results *query_results );
	*/
	
}

