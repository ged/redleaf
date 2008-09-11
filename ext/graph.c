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
static rleaf_GRAPH *
rleaf_graph_alloc( VALUE storeobj ) {
	rleaf_GRAPH *ptr = ALLOC( rleaf_GRAPH );
	rleaf_STORE *store = rleaf_get_store( storeobj );
	
	/* :TODO: Figure out what the options argument of librdf_new_model does and support it. */
	if ( !store->storage )
		rb_raise( rb_eArgError, "Ack! Tried to create a graph with an uninitialized %s 0x%x", 
		rb_class2name(CLASS_OF(storeobj)), storeobj );

	ptr->store = storeobj;
	ptr->model = librdf_new_model( rleaf_rdf_world, store->storage, NULL );

	rleaf_log( "debug", "initialized a rleaf_GRAPH <%p>", ptr );
	return ptr;
}


/*
 * GC Mark function
 */
static void 
rleaf_graph_gc_mark( rleaf_GRAPH *ptr ) {
	rleaf_log( "debug", "in mark function for RedLeaf::Graph %p", ptr );
	
	if ( ptr ) {
		rleaf_log( "debug", "marking a rleaf_GRAPH <%p>", ptr );
		rb_gc_mark( ptr->store );
	}
	
	else {
		rleaf_log( "debug", "not marking an unallocated rleaf_GRAPH" );
	}
}



/*
 * GC Free function
 */
static void 
rleaf_graph_gc_free( rleaf_GRAPH *ptr ) {
	rleaf_log( "debug", "in free function of Redleaf::Graph <%p>", ptr );

	if ( ptr->model ) {
		librdf_free_model( ptr->model );

		ptr->model = NULL;
		ptr->store = Qnil;

		rleaf_log( "debug", "Freeing rleaf_GRAPH <%p>", ptr );
		xfree( ptr );
		ptr = NULL;
	}

	else {
		rleaf_log( "warn", "not freeing an uninitialized rleaf_GRAPH" );
	}
}


/*
 * Object validity checker. Returns the data pointer.
 */
static rleaf_GRAPH *
check_graph( VALUE self ) {
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
rleaf_GRAPH *
rleaf_get_graph( VALUE self ) {
	rleaf_GRAPH *stmt = check_graph( self );

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
static VALUE 
rleaf_redleaf_graph_s_allocate( VALUE klass ) {
	rleaf_log( "debug", "wrapping an uninitialized Redleaf::Graph pointer." );
	return Data_Wrap_Struct( klass, rleaf_graph_gc_mark, rleaf_graph_gc_free, 0 );
}


/* --------------------------------------------------------------
 * Instance methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Graph.new()          -> graph
 *     Redleaf::Graph.new( store )   -> graph
 *
 *  Create a new Redleaf::Graph object. If the optional +store+ object is
 *  given, it is used as the backing store for the graph. If none is specified
 *  a new Redleaf::MemoryHashStore is used.
 *
 */
static VALUE 
rleaf_redleaf_graph_initialize( int argc, VALUE *argv, VALUE self ) {
	rleaf_log_with_context( self, "debug", "Initializing %s 0x%x", rb_class2name(CLASS_OF(self)), self );

	if ( !check_graph(self) ) {
		rleaf_GRAPH *graph;
		VALUE store = Qnil;

		/* Default the store if one isn't given */
		if ( rb_scan_args(argc, argv, "01", &store) == 0 ) {
			rleaf_log_with_context( self, "debug", "Creating a new default store for graph 0x%x", self );
			store = rb_class_new_instance( 0, NULL, DEFAULT_STORE_CLASS );
		}

		DATA_PTR( self ) = graph = rleaf_graph_alloc( store );
		
	} else {
		rb_raise( rb_eRuntimeError,
				  "Cannot re-initialize a graph once it's been created." );
	}

	return self;
}


/*
 *  call-seq:
 *     graph.size   => fixnum
 *
 * Return the number of statements in the graph. If the underlying store doesn't support
 * fetching the size of the graph, the return value will be negative.
 *
 */
static VALUE
rleaf_redleaf_graph_size( VALUE self ) {
	rleaf_GRAPH *graph = rleaf_get_graph( self );
	int size = librdf_model_size( graph->model );
	
	return INT2FIX( size );
}


/*
 *  call-seq:
 *     graph.store   -> a_store
 *
 *  Return the Redleaf::Store associated with the receiver.
 *  
 */
static VALUE
rleaf_redleaf_graph_store( VALUE self ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	return ptr->store;
}


/*
 *  call-seq:
 *     graph.store = new_store
 *
 *  Associate the given +new_store+ with the receiver, breaking the association between
 *  it and any previous Store.
 *  
 */
static VALUE
rleaf_redleaf_graph_store_eq( VALUE self, VALUE storeobj ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	
	if ( rb_obj_is_kind_of(storeobj, rleaf_cRedleafStore) )
		rb_funcall( storeobj, rb_intern("graph="), 1, self );
	
	ptr->store = storeobj;
	
	return storeobj;
}


/*
 * Redleaf Graph class
 */
void 
rleaf_init_redleaf_graph( void ) {
	rleaf_log( "debug", "Initializing Redleaf::Graph" );

#ifdef FOR_RDOC
	rleaf_mRedleaf = rb_define_module( "Redleaf" );
#endif

	rleaf_cRedleafGraph = rb_define_class_under( rleaf_mRedleaf, "Graph", rb_cObject );
	rb_define_alloc_func( rleaf_cRedleafGraph, rleaf_redleaf_graph_s_allocate );
	
	rb_define_method( rleaf_cRedleafGraph, "initialize", rleaf_redleaf_graph_initialize, -1 );

	rb_define_method( rleaf_cRedleafGraph, "size", rleaf_redleaf_graph_size, 0 );
	rb_define_method( rleaf_cRedleafGraph, "store", rleaf_redleaf_graph_store, 0 );
	rb_define_method( rleaf_cRedleafGraph, "store=", rleaf_redleaf_graph_store_eq, 1 );
	
}

