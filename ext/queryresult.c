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


/* --------------------------------------------------
 *	Memory-management functions
 * -------------------------------------------------- */

/*
 * Allocation function
 */
static librdf_query_results *
rleaf_queryresult_alloc() {
	return NULL;
}


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

		xfree( ptr );
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
	rleaf_log_with_context( self, "debug", "checking a %s object <0x%x>.", rb_class2name(CLASS_OF(self)), self );
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

	rleaf_log_with_context( self, "debug", "fetched a QueryResult <0x%x>.", self );
	if ( !res )
		rb_raise( rb_eRuntimeError, "uninitialized QueryResult" );

	return res;
}


/* --------------------------------------------------------------
 * Class methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::QueryResult.allocate   -> queryresult
 *
 *  Allocate a new Redleaf::QueryResult object.
 *
 */
static VALUE 
rleaf_redleaf_queryresult_s_allocate( VALUE klass ) {
	if ( klass == rleaf_cRedleafQueryResult ) {
		rb_raise( rb_eRuntimeError, "cannot allocate a Redleaf::QueryResult, as it is an abstract class" );
	}

	return Data_Wrap_Struct( klass, rleaf_queryresult_gc_mark, rleaf_queryresult_gc_free, 0 );
}


/*
 *  call-seq:
 *     Redleaf::QueryResult.formats   -> hash
 *
 *  Return a Hash of possible query result types.
 *
 *     Redleaf::QueryResult.formats
 *     # => {}
 */
static VALUE
rleaf_redleaf_queryresult_s_formats( VALUE klass ) {
	VALUE formats = rb_hash_new();
	int i = 0;
	const char *name, *label, *mime_string;
	const unsigned char *uri_string;

	while ( (librdf_query_results_formats_enumerate(rleaf_rdf_world, i, &name, &label, &uri_string, &mime_string)) == 0 ) {
		VALUE subhash  = rb_hash_new();
		VALUE namestr  = name ? rb_str_new2( name ) : Qnil;
		VALUE labelstr = label ? rb_str_new2( label ) : Qnil;
		VALUE mimetype = mime_string ? rb_str_new2( mime_string ) : Qnil;
		VALUE uri = Qnil;

		if ( uri_string ) {
			VALUE argv[1] = { rb_str_new2(label) };
			uri = rb_funcall( rleaf_rb_cURI, rb_intern("parse"), 1, &argv );
		}

		rb_hash_aset( subhash, ID2SYM(rb_intern("label")), labelstr );
		rb_hash_aset( subhash, ID2SYM(rb_intern("uri")), uri );
		rb_hash_aset( subhash, ID2SYM(rb_intern("mimetype")), mimetype );
		
		rb_hash_aset( formats, namestr, subhash );
		i++;
	}

	return formats;
}


/* --------------------------------------------------------------
 * Instance methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::QueryResult.new                -> queryresult
 *     Redleaf::QueryResult.new( config={} )   -> queryresult
 *
 *  Create a new Redleaf::QueryResult object. .
 *
 */
static VALUE 
rleaf_redleaf_queryresult_initialize( int argc, VALUE *argv, VALUE self ) {
	return self;
}



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
	rb_define_alloc_func( rleaf_cRedleafQueryResult, rleaf_redleaf_queryresult_s_allocate );

	/* Class methods */
	rb_define_singleton_method( rleaf_cRedleafQueryResult, "formats", rleaf_redleaf_queryresult_s_formats, 0 );

	/* Instance methods */
	rb_define_method( rleaf_cRedleafQueryResult, "initialize", rleaf_redleaf_queryresult_initialize, -1 );


}

