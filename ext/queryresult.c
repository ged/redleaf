/* 
 * Redleaf::QueryResult -- RDF queryresult object class
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
static void 
rleaf_queryresult_gc_mark( librdf_query_results *ptr ) {}
 */



/*
 * GC Free function
 */
static void
rleaf_queryresult_gc_free( librdf_query_results *ptr ) {
	if ( ptr && rleaf_rdf_world ) {
		librdf_free_query_results( ptr );
		ptr = NULL;
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

	if ( !res ) rb_fatal( "Use of uninitialized QueryResult" );

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
		rleaf_log_with_context( graph, "debug", "  result is a `bindings` result." );
		result_class = rleaf_cRedleafBindingQueryResult;
	}
	
	else if ( librdf_query_results_is_graph(res) ) {
		rleaf_log_with_context( graph, "debug", "  result is a `graph` result." );
		result_class = rleaf_cRedleafGraphQueryResult;
	}
	
	else if ( librdf_query_results_is_boolean(res) ) {
		rleaf_log_with_context( graph, "debug", "  result is a `boolean` result." );
		result_class = rleaf_cRedleafBooleanQueryResult;
	}
	
	else if ( librdf_query_results_is_syntax(res) ) {
		rleaf_log_with_context( graph, "debug", "  result is a `syntax` result." );
		result_class = rleaf_cRedleafSyntaxQueryResult;
	}
	
	else {
		rb_fatal( "Unhandled query result %p", res );
	}

	result = Data_Wrap_Struct( result_class, NULL, rleaf_queryresult_gc_free, res );
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
 *  call-seq:
 *     queryresult.formatted_as( formaturi )   -> string
 *
 *  Return the query results as a String in the format specified by the +formaturi+. You can get 
 *  the format URI from the Redleaf::QueryResult.formatters hash.
 *
 *     formaturi = Redleaf::QueryResult.formatters['json'][:uri]
 *     result.formatted_as( formaturi )
 *     # => ...
 */
static VALUE
rleaf_redleaf_queryresult_formatted_as( VALUE self, VALUE format ) {
	librdf_query_results *res = rleaf_get_queryresult( self );
	librdf_uri *formaturi = NULL;
	unsigned char *result = NULL;
	size_t length = 0;
	VALUE rval;

	if ( !IsURI(format) )
		rb_raise( rb_eArgError, "cannot convert %s to a URI", rb_class2name(CLASS_OF( format )) );
		
	rleaf_log_with_context( self, "debug", "Serializing a %s as %s",
		rb_class2name(CLASS_OF( self )), RSTRING_PTR(rb_obj_as_string(format)) );
	formaturi = rleaf_object_to_librdf_uri( format );
	result = librdf_query_results_to_counted_string( res, formaturi, NULL, &length );
	librdf_free_uri( formaturi ); 
	
	if ( !result )
		rb_raise( rleaf_eRedleafError, "Could not fetch results as %s", librdf_uri_as_string(formaturi) );
	
	rval = rb_str_new( (char *)result, length );
	xfree( result );
	
	return rval;
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
 *     result.rows   -> array
 *
 *  Return the result rows as an Array of Hashes.
 *
 */
static VALUE
rleaf_redleaf_bindingsqueryresult_rows( VALUE self ) {
	librdf_query_results *res = rleaf_get_queryresult( self );
	VALUE rows = rb_ivar_get( self, rb_intern("@rows") );

	/* If @rows is nil and there are results to fetch, fetch each row from 
	   Redland, yield it, and cache it for later. */
	if ( rows == Qnil ) {
		int i;

		rleaf_log_with_context( self, "debug", "Building result rows." );
		rows = rb_ary_new();
	
		/* Make a row for each result */
		while( !librdf_query_results_finished(res) ) {
			int bindcount = librdf_query_results_get_bindings_count( res );
			VALUE row = rb_hash_new();
			rleaf_log_with_context( self, "debug", "Fetching result %d:", librdf_query_results_get_count(res) );
		
			/* Make an entry in the row for each binding */
			for ( i = 0; i < bindcount; i++ ) {
				const char *name = librdf_query_results_get_binding_name( res, i );
				librdf_node *value = librdf_query_results_get_binding_value( res, i );

				if ( value ) {
					rleaf_log_with_context( self, "debug", "  binding :%s => %s",
						name, librdf_node_to_string(value) );
					rb_hash_aset( row, ID2SYM(rb_intern(name)), rleaf_librdf_node_to_value(value) );
					librdf_free_node( value );
				} else {
					rb_hash_aset( row, ID2SYM(rb_intern(name)), Qnil );
				}
			}
			
			rb_ary_push( rows, row );
			librdf_query_results_next( res );
		}
		
		rb_ivar_set( self, rb_intern("@rows"), rows );
	} else {
		rleaf_log_with_context( self, "debug", "Reusing previously-fetched rows." );
	}

	return rows;
}


/*
 *  call-seq:
 *     result.length   -> fixnum
 *
 *  Return the number of rows in the result.
 *
 */
static VALUE
rleaf_redleaf_bindingsqueryresult_length( VALUE self ) {
	VALUE rows = rleaf_redleaf_bindingsqueryresult_rows( self );
	Check_Type( rows, T_ARRAY );
	return INT2NUM( RARRAY_LEN(rows) );
}


/*
 * Redleaf::GraphQueryResult
 */

/*
 *  call-seq:
 *     result.graph   -> graph
 *
 *  Return the Redleaf::Graph formed by taking each query solution in the solution sequence, 
 *  substituting for the variables in the graph template, and combining the triples 
 *  into a single RDF graph by set union.
 *
 */
static VALUE
rleaf_redleaf_graphqueryresult_graph( VALUE self ) {
	librdf_query_results *res = rleaf_get_queryresult( self );
	VALUE graphobj = rb_ivar_get( self, rb_intern("@graph") );

	if ( !RTEST(graphobj) ) {
		rleaf_GRAPH *graph;
		librdf_stream *stream;

	 	graphobj = rb_class_new_instance( 0, NULL, rleaf_cRedleafGraph );
		graph = rleaf_get_graph( graphobj );

		if ( (stream = librdf_query_results_as_stream(res)) ) {
			librdf_model_add_statements( graph->model, stream );
			librdf_free_stream( stream );
		} else {
			rleaf_log_with_context( self, "info", "Query resulted in an empty graph." );
		}

		rb_ivar_set( self, rb_intern("@graph"), graphobj );
	}
	
	return graphobj;
}


/*
 *  call-seq:
 *     result.length   -> fixnum
 *
 *  Return the number of statements in the result graph.
 */
static VALUE
rleaf_redleaf_graphqueryresult_length( VALUE self ) {
	VALUE graphobj = rleaf_redleaf_graphqueryresult_graph( self );
	return rb_funcall( graphobj, rb_intern("length"), 0 );
}




/*
 * Redleaf::BooleanQueryResult
 */
static VALUE
rleaf_redleaf_booleanqueryresult_value( VALUE self ) {
	librdf_query_results *res = rleaf_get_queryresult( self );
	int value = librdf_query_results_get_boolean( res );
	
	if ( value < 0 ) rb_raise( rleaf_eRedleafError, "couldn't fetch boolean result" );
	rleaf_log_with_context( self, "debug", "Boolean result is: %d", value );
	
	return value ? Qtrue : Qfalse;
}



/*
 * Redleaf::SyntaxQueryResult
 */




/*
 * Redleaf QueryResult class
 */
void
rleaf_init_redleaf_queryresult( void ) {
	rleaf_log( "debug", "Initializing Redleaf::QueryResult" );
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
	rb_define_method( rleaf_cRedleafQueryResult, "formatted_as", rleaf_redleaf_queryresult_formatted_as, 1 );

	/*

	-- #write( io )/#write( filename ) -- Blocking?
	int librdf_query_results_to_file_handle( librdf_query_results *query_results, FILE *handle, librdf_uri *format_uri, librdf_uri *base_uri );
	int librdf_query_results_to_file( librdf_query_results *query_results, const char *name, librdf_uri *format_uri, librdf_uri *base_uri );

	*/


	/*
	 * Redleaf::BindingQueryResult
	 */
	rb_define_method( rleaf_cRedleafBindingQueryResult, "bindings", 
		rleaf_redleaf_bindingsqueryresult_bindings, 0 );
	rb_define_method( rleaf_cRedleafBindingQueryResult, "length", 
		rleaf_redleaf_bindingsqueryresult_length, 0 );
	rb_define_alias ( rleaf_cRedleafBindingQueryResult, "size", "length" );
	rb_define_method( rleaf_cRedleafBindingQueryResult, "rows", 
		rleaf_redleaf_bindingsqueryresult_rows, 0 );

	/*
	 * Redleaf::GraphQueryResult
	 */
	rb_define_method( rleaf_cRedleafGraphQueryResult, "length", 
		rleaf_redleaf_graphqueryresult_length, 0 );
	rb_define_method( rleaf_cRedleafGraphQueryResult, "graph", 
		rleaf_redleaf_graphqueryresult_graph, 0 );

	/*
	 * Redleaf::BooleanQueryResult
	 */
	rb_define_method( rleaf_cRedleafBooleanQueryResult, "value", 
		rleaf_redleaf_booleanqueryresult_value, 0 );
	rb_define_alias ( rleaf_cRedleafBooleanQueryResult, "to_bool", "value" );

	/*
	 * Redleaf::SyntaxQueryResult
	 */
	
}

