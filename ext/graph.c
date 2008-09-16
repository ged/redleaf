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

	if ( ptr->model && rleaf_rdf_world ) {
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
	rleaf_log_with_context( self, "debug", "checking a Redleaf::Graph object (%d).", self );
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
	rleaf_GRAPH *graph = check_graph( self );

	rleaf_log_with_context( self, "debug", "fetching a Graph <%p>.", graph );
	if ( !graph )
		rb_raise( rb_eRuntimeError, "uninitialized Graph" );

	return graph;
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
	
	if ( storeobj == Qnil ) {
		rleaf_log_with_context( self, "info", 
			"Graph <0x%x>'s store cleared. Setting it to a new %s.",
		 	self, rb_class2name(DEFAULT_STORE_CLASS) );
		storeobj = rb_class_new_instance( 0, NULL, DEFAULT_STORE_CLASS );
	} 

	if ( rb_obj_is_kind_of(storeobj, rleaf_cRedleafStore) ) {
		rleaf_log_with_context( self, "info", "Graph <0x%x>'s store is now %s <0x%x>", 
			self, rb_class2name(CLASS_OF(storeobj)), storeobj );
		rb_funcall( storeobj, rb_intern("graph="), 1, self );
	} else {
		rb_raise( rb_eArgError, "cannot convert %s to Redleaf::Store", 
			rb_class2name(CLASS_OF(storeobj)) );
	}
	
	ptr->store = storeobj;
	
	return storeobj;
}


/*
 *  call-seq:
 *     graph.statements   -> array
 *
 *  Return an Array of all the statements in the graph.
 *
 */
static VALUE 
rleaf_redleaf_graph_statements( VALUE self ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_stream *stream = librdf_model_as_stream( ptr->model );
	VALUE statements = rb_ary_new();
	
	rleaf_log_with_context( self, "debug", 
		"Creating statement objects for %d statements in Graph <0x%x>.",
		librdf_model_size(ptr->model), self );
	while ( ! librdf_stream_end(stream) ) {
		librdf_statement *stmt = librdf_stream_get_object( stream );
		VALUE stmt_obj = rleaf_statement_to_object( rleaf_cRedleafStatement, stmt );
		
		rb_ary_push( statements, stmt_obj );
		librdf_stream_next( stream );
	}
	librdf_free_stream( stream );
	
	return statements;
}


/*
 *  call-seq:
 *     graph << statement                         -> graph
 *     graph << [ subject, predicate, object ]    -> graph
 *
 *  Append a new statement to the graph, either as a Redleaf::Statement, or a valid triple
 *  in an Array.
 *  
 *     require 'redleaf/constants'
 *     incude Redleaf::Constants::CommonNamespaces # (for the FOAF namespace constant)
 *     
 *     michael = URI.parse( 'mailto:ged@FaerieMUD.org' )
 *     knows   = FOAF[:knows]
 *     mahlon  = URI.parse( 'mailto:mahlon@martini.nu' )
 *
 *     # The long way
 *     graph = Redleaf::Graph.new
 *     statement1 = Redleaf::Statement.new( mahlon, knows, michael )
 *     statement2 = Redleaf::Statement.new( michael, knows, mahlon )
 *     graph << stmt1 << stmt2
 *     graph.size  # => 2
 *
 *     # The shorthand way
 *     graph << [ mahlon, knows, michael ] << [ michael, knows, mahlon ]
 *
 */
static VALUE 
rleaf_redleaf_graph_append( VALUE self, VALUE statement ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_statement *stmt_ptr = NULL;

	/* Check argument to see if it's an array or statement, error otherwise */
	switch ( TYPE(statement) ) {
		case T_ARRAY:
		if ( RARRAY_LEN(statement) != 3 )
			rb_raise( rb_eArgError, "Statement must have three elements." );
		statement = rb_class_new_instance( 3, RARRAY_PTR(statement), rleaf_cRedleafStatement );
		// fallthrough -- :FIXME: this is really clumsy. It creates a statement
		// object just to get the node-normalization and error-checking. Really should
		// factor out the node conversions to the Redleaf module or maybe a mixin.
		
		case T_DATA:
		if ( CLASS_OF(statement) != rleaf_cRedleafStatement )
			rb_raise( rb_eArgError, "can't convert %s into Redleaf::Statement", 
				rb_class2name(CLASS_OF(statement)) );
		stmt_ptr = rleaf_get_statement( statement );
		break;
		
		default:
		rb_raise( rb_eArgError, "can't convert %s into Redleaf::Statement",
			rb_class2name(CLASS_OF(statement)) );
	}
	
	if ( librdf_model_add_statement(ptr->model, stmt_ptr) != 0 )
		rb_raise( rb_eRuntimeError, "could not add statement to graph 0x%x", self );
	
	return self;
}


/*
 *  call-seq:
 *     graph.parse( uri )   -> fixnum
 *
 *  Parse the RDF at the specified +uri+ into the receiving graph. Returns the number of statements
 *  added to the graph.
 *
 *     graph = Redleaf::Graph.new
 *     graph.parse( "http://bigasterisk.com/foaf.rdf" )
 *     graph.parse( "http://www.w3.org/People/Berners-Lee/card.rdf" )
 *     graph.parse( "http://danbri.livejournal.com/data/foaf" ) 
 *     
 *     graph.size
 */
static VALUE
rleaf_redleaf_graph_parse( VALUE self, VALUE uri ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_parser *parser = NULL;
	librdf_uri *rdfuri = NULL;
	int statement_count = librdf_model_size( ptr->model );
	
	if ( (parser = librdf_new_parser( rleaf_rdf_world, NULL, NULL, NULL )) == NULL )
		rb_raise( rb_eRuntimeError, "failed to create a parser." );
	if ( (rdfuri = librdf_new_uri( rleaf_rdf_world, (unsigned char *)StringValuePtr(uri) )) == NULL )
		rb_raise( rb_eRuntimeError, "failed to create a uri object from %s", 
			RSTRING(rb_inspect(uri))->ptr );
	
	if ( librdf_parser_parse_into_model(parser, rdfuri, NULL, ptr->model) != 0 )
		rb_raise( rb_eRuntimeError, "failed to parse %s into Model <0x%x>",
		librdf_uri_as_string(rdfuri), self );

	return INT2FIX( librdf_model_size(ptr->model) - statement_count );
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

	rb_define_method( rleaf_cRedleafGraph, "statements", rleaf_redleaf_graph_statements, 0 );

	rb_define_method( rleaf_cRedleafGraph, "<<", rleaf_redleaf_graph_append, 1 );
	
	rb_define_method( rleaf_cRedleafGraph, "parse", rleaf_redleaf_graph_parse, 1 );
}

