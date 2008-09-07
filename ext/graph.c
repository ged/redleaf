/* 
 * Redleaf::Graph -- RDF Graph (Model) class
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

VALUE rleaf_cRedleafGraph;


/* --------------------------------------------------
 *	Memory-management functions
 * -------------------------------------------------- */

/*
 * Allocation function
 */
static librdf_model *rleaf_graph_alloc() {
	librdf_storage *storage = NULL;
	librdf_model *ptr = NULL;
	
	storage = librdf_new_storage( rleaf_rdf_world, "hashes", NULL, "hash-type='memory'" );
	librdf_new_model( rleaf_rdf_world, storage, "" );

	rleaf_log( "debug", "initialized a librdf_model <%p>", ptr );
	return ptr;
}


/*
 * GC Mark function
 */
static void rleaf_graph_gc_mark( librdf_model *ptr ) {
	rleaf_log( "debug", "in mark function for RedLeaf::Graph %p", ptr );
	
	if ( ptr ) {
		rleaf_log( "debug", "marked" );
	}
	
	else {
		rleaf_log( "debug", "not marked" );
	}
}



/*
 * GC Free function
 */
static void rleaf_graph_gc_free( librdf_model *ptr ) {
	if ( ptr ) {
		rleaf_log( "debug", "in free function of Redleaf::Graph <%p>", ptr );
		librdf_free_model( ptr );
		
		ptr = NULL;
	}

	else {
		rleaf_log( "warn", "not freeing an uninitialized Redleaf::Graph" );
	}
}


/*
 * Object validity checker. Returns the data pointer.
 */
static librdf_model *check_graph( VALUE self ) {
	rleaf_log( "debug", "checking a Redleaf::Graph object (%d).", self );
	Check_Type( self, T_DATA );

    if ( !IsGraph(self) ) {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected Redleaf::Graph)",
				  rb_class2name(CLASS_OF( self )) );
    }
	
	return DATA_PTR( self );
}


/*
 * Fetch the data pointer and check it for sanity.
 */
static librdf_model *get_graph( VALUE self ) {
	librdf_model *stmt = check_graph( self );

	rleaf_log( "debug", "fetching a Graph <%p>.", stmt );
	if ( !stmt )
		rb_raise( rb_eRuntimeError, "uninitialized Graph" );

	return stmt;
}


/* --------------------------------------------------------------
 * Class methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Graph.allocate   -> graph
 *
 *  Allocate a new Redleaf::Graph object.
 *
 */
static VALUE rleaf_redleaf_graph_s_allocate( VALUE klass ) {
	rleaf_log( "debug", "wrapping an uninitialized Redleaf::Graph pointer." );
	return Data_Wrap_Struct( klass, rleaf_graph_gc_mark, rleaf_graph_gc_free, 0 );
}


/* --------------------------------------------------------------
 * Instance methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Graph.new()                               -> graph
 *     Redleaf::Graph.new( subject, predicate, object )   -> graph
 *
 *  Create a new Redleaf::Graph object. If the optional +subject+ (a URI or nil), 
 *  +predicate+ (a URI), and +object+ (a URI, nil, or any immediate Ruby object) are given, 
 *  the graph will be initialized with them.
 *
 */
static VALUE rleaf_redleaf_graph_initialize( int argc, VALUE *argv, VALUE self ) {
	if ( !check_graph(self) ) {
		librdf_model *stmt;
		VALUE subject = Qnil, predicate = Qnil, object = Qnil;

		DATA_PTR( self ) = stmt = rleaf_graph_alloc();
		
	} else {
		rb_raise( rb_eRuntimeError,
				  "Cannot re-initialize a graph once it's been created." );
	}

	return self;
}



/*
 * Redleaf Graph class
 */
void rleaf_init_redleaf_graph( void ) {
#ifdef FOR_RDOC
	rleaf_mRedleaf = rb_define_module( "Redleaf" );
#endif

	rleaf_cRedleafGraph = rb_define_class_under( rleaf_mRedleaf, "Graph", rb_cObject );
	
	rleaf_log( "debug", "Initializing Redleaf::Graph" );
}

