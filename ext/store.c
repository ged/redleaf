/* 
 * Redleaf::Store -- RDF persistent storage classes
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
VALUE rleaf_cRedleafStore;
VALUE rleaf_cRedleafHashesStore;

static VALUE rleaf_redleaf_store_graph_eq( VALUE, VALUE );


/* --------------------------------------------------
 *	Memory-management functions
 * -------------------------------------------------- */

/*
 * Allocation function
 */
static rleaf_STORE *
rleaf_store_alloc( const char *backend, const char *name, const char *optstring ) {
	librdf_storage *storage = NULL;
	rleaf_STORE *ptr = ALLOC( rleaf_STORE );
	
	if ( (storage = librdf_new_storage( rleaf_rdf_world, backend, name, optstring )) == 0 )
		rb_raise( rleaf_eRedleafError, 
			"Could not create a new storage with: backend=\"%s\", name=\"%s\", optstring=\"%s\"", 
			backend, name, optstring );

	ptr->storage = storage;
	ptr->graph   = Qnil;

	// rleaf_log( "debug", "alloc'ed a rleaf_STORE <%p> with storage <%p>", ptr, ptr->storage );
	return ptr;
}


/*
 * GC Mark function
 */
static void 
rleaf_store_gc_mark( rleaf_STORE *ptr ) {
	if ( ptr && ptr->graph ) rb_gc_mark( ptr->graph );
}



/*
 * GC Free function
 */
static void
rleaf_store_gc_free( rleaf_STORE *ptr ) {
	if ( ptr && rleaf_rdf_world ) {

		/* Not sure if I need to break the graph<->storage link here, and if I do, how. [MG] */
		if ( ptr->storage ) {
			librdf_storage_close( ptr->storage );
			librdf_free_storage( ptr->storage );
		}
		
		ptr->graph   = Qnil;
		ptr->storage = NULL;
		
		xfree( ptr );
		ptr = NULL;
	}
}


/*
 * Object validity checker. Returns the data pointer.
 */
static rleaf_STORE *
check_store( VALUE self ) {
	// rleaf_log_with_context( self, "debug", "checking a %s object <0x%x>.", rb_class2name(CLASS_OF(self)), self );
	Check_Type( self, T_DATA );

    if ( !IsStore(self) ) {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected a Redleaf::Store)",
				  rb_class2name(CLASS_OF( self )) );
    }
	
	return DATA_PTR( self );
}


/*
 * Fetch the data pointer and check it for sanity.
 */
rleaf_STORE *
rleaf_get_store( VALUE self ) {
	rleaf_STORE *store = check_store( self );

	if ( !store ) rb_fatal( "Use of uninitialized Redleaf::Store" );

	return store;
}


/* --------------------------------------------------------------
 * Utility functions
 * -------------------------------------------------------------- */

/*
 * Make a librdf-style option string out of a Ruby Hash. The returned pointer will need to be
 * freed by the caller.
 */
static char *
rleaf_optstring_from_rubyhash( VALUE opthash ) {
	VALUE rb_optstring = rb_funcall( rleaf_cRedleafStore, rb_intern("make_optstring"), 1, opthash );
	char *optstring = ALLOC_N( char, RSTRING(rb_optstring)->len + 1 );
	
	strncpy( optstring, (const char *)RSTRING(rb_optstring)->ptr, RSTRING(rb_optstring)->len + 1 );
	optstring[ RSTRING(rb_optstring)->len ] = '\0';
	
	return optstring;
}



/* --------------------------------------------------------------
 * Class methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Store.allocate   -> store
 *
 *  Allocate a new Redleaf::Store object.
 *
 */
static VALUE 
rleaf_redleaf_store_s_allocate( VALUE klass ) {
	if ( klass == rleaf_cRedleafStore ) {
		rb_raise( rb_eRuntimeError, "cannot allocate a Redleaf::Store, as it is an abstract class" );
	}

	return Data_Wrap_Struct( klass, rleaf_store_gc_mark, rleaf_store_gc_free, 0 );
}


/*
 *  call-seq:
 *     Redleaf::Store.backends   -> hash
 *
 *  Return a Hash of supported backends from the underlying Redland library.
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
rleaf_redleaf_store_s_backends( VALUE klass ) {
	VALUE backends = rb_hash_new();
	int i = 0;
	const char *name, *label;

	while ( (librdf_storage_enumerate(rleaf_rdf_world, i, &name, &label)) == 0 ) {
		VALUE namestr = name ? rb_str_new2( name ) : rb_str_new( NULL, 0 );
		VALUE labelstr = label ? rb_str_new2( label ) : rb_str_new( NULL, 0 );
		
		rb_hash_aset( backends, namestr, labelstr );
		i++;
	}

	return backends;
}


/* --------------------------------------------------------------
 * Instance methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Store.new                -> store
 *     Redleaf::Store.new( config={} )   -> store
 *
 *  Create a new Redleaf::Store object. .
 *
 */
static VALUE 
rleaf_redleaf_store_initialize( int argc, VALUE *argv, VALUE self ) {
	rleaf_log_with_context( self, "debug", "Initializing 0x%x", self );

	if ( !check_store(self) ) {
		rleaf_STORE *store;
		VALUE backend = Qnil, name = Qnil, opthash = Qnil;
		const char *backendname = NULL, *storename = NULL;
		char *optstring = NULL;

		switch ( rb_scan_args(argc, argv, "02", &name, &opthash) ) {
			case 0:
			rleaf_log_with_context( self, "debug", "No-arg constructor called." );
			opthash = rb_hash_new();
			break;

			case 1:
			rleaf_log_with_context( self, "debug", "One-arg constructor called: %s.",
				RSTRING(rb_inspect(name))->ptr );
			if ( TYPE(name) == T_HASH ) {
				rleaf_log_with_context( self, "debug", "Argument was a opthash; swapping it." );
				opthash = name;
				name = Qnil;
			} else {
				opthash = rb_hash_new();
			}
			break;
			
			case 2:
			rleaf_log_with_context( self, "debug", "Two-arg constructor called: %s, %s.",
				RSTRING(rb_inspect(name))->ptr, RSTRING(rb_inspect(opthash))->ptr );
			break;
			
			default:
			rb_raise( rb_eArgError, "wrong number of arguments (%d for 1)", argc );
		}
		
		if ( TYPE(opthash) != T_HASH )
			rb_raise( rb_eArgError, "cannot convert %s to Hash", rb_class2name(CLASS_OF(opthash)) );

		/* Get the backend name */
		backend = rb_funcall( CLASS_OF(self), rb_intern("validated_backend"), 0 );
		backendname = rb_id2name( rb_to_id(backend) );

		if ( name == Qnil ) {
			storename = NULL;
			rb_iv_set( self, "@name", Qnil );
		}
		else {
			storename = StringValuePtr( name );
			rb_iv_set( self, "@name", name );
		}

		rb_iv_set( self, "@opthash", opthash );

		/* Make the option string */
		optstring = rleaf_optstring_from_rubyhash( opthash );
		rleaf_log_with_context( self, "debug", 
			"Got backend = \"%s\", name = \"%s\", optstring = \"%s\"", 
			backendname, storename, optstring );
		
		DATA_PTR( self ) = store = rleaf_store_alloc( backendname, storename, optstring );
		xfree( optstring );

	} else {
		rb_raise( rleaf_eRedleafError,
				  "Cannot re-initialize a store once it's been created." );
	}

	return self;
}


/*
 *  call-seq:
 *     store.has_contexts?   -> true or false
 *
 *  Return +true+ if the backend of the receiver supports contexts and the receiver has them 
 *  enabled.
 *
 */
static VALUE 
rleaf_redleaf_store_has_contexts_p( VALUE self ) {
	rleaf_STORE *store = rleaf_get_store( self );
	librdf_iterator *contexts;

	if ( store->graph == Qnil )
		rb_raise( rleaf_eRedleafError, "Storage has not yet been associated with a graph." );
	
	rleaf_log_with_context( self, "debug", "Checking for contexts in %s:%p", 
		rb_class2name(CLASS_OF(self)), store );
	
	/* Suggested by laalto on irc://freenode.net/#redland */
	if ( (contexts = librdf_storage_get_contexts( store->storage )) == NULL ) {
		return Qfalse;
	} else {
		librdf_free_iterator( contexts );
		return Qtrue;
	}
}


/*
 *  call-seq:
 *     store.graph   -> graph
 *
 *  Return the Redleaf::Graph associated with this Store, creating one if one if necessary.
 *
 */
static VALUE
rleaf_redleaf_store_graph( VALUE self ) {
	rleaf_STORE *store = rleaf_get_store( self );
	VALUE graph = Qnil;
	
	/* Auto-create a new graph for the store and assign it if it doesn't already have one. */
	if ( store->graph == Qnil ) {
		graph = rb_class_new_instance( 1, &self, rleaf_cRedleafGraph );
		return rleaf_redleaf_store_graph_eq( self, graph );
	}
		
	return store->graph;
}


/*
 *  call-seq:
 *     store.graph = newgraph
 *
 *  Set the store's graph to +newgraph+.
 *
 */
static VALUE
rleaf_redleaf_store_graph_eq( VALUE self, VALUE graphobj ) {
	rleaf_STORE *store = rleaf_get_store( self );
	rleaf_GRAPH *graph = rleaf_get_graph( graphobj );
	
	/* If there was already a graph associated with this store, tell it that its store 
	   is going away and break the association. */
	if ( store->graph != Qnil ) {
		rleaf_log_with_context( self, "info", "disassociating current graph <0x%x> from %s <0x%x>",
			store->graph, rb_class2name(CLASS_OF(self)), self );
		rb_funcall( store->graph, rb_intern("store="), 1, Qnil );
		store->graph = Qnil;

		if ( librdf_storage_close(store->storage) != 0 )
			rb_fatal( "librdf_storage_close failed on rleaf_STORE <%p>.", store );
	}

	rleaf_log_with_context( self, "debug", "Associating rleaf_STORE <%p> with rleaf_GRAPH <%p>", store, graph );
	if ( librdf_storage_open(store->storage, graph->model) != 0 )
		rb_fatal( "librdf_storage_open failed on rleaf_STORE <%p> for rleaf_GRAPH <%p>", store, graph );

	store->graph = graphobj;
	graph->store = self;

	return graphobj;
}


/*
 *  call-seq:
 *     store.sync   -> true
 *
 *  Synchronizes the store to the underlying storage implementation. Raises a RuntimeError if the
 *  sync fails.
 *
 */
static VALUE
rleaf_redleaf_store_sync( VALUE self ) {
	rleaf_STORE *store = rleaf_get_store( self );
	
	if ( librdf_storage_sync(store->storage) == 0 )
		rb_raise( rleaf_eRedleafError, "Failed to sync to the underlying storage." );
	
	return Qtrue;
}



/*
 * Redleaf Store class
 */
void
rleaf_init_redleaf_store( void ) {
	rleaf_log( "debug", "Initializing Redleaf::Store" );

#ifdef FOR_RDOC
	rleaf_mRedleaf = rb_define_module( "Redleaf" );
#endif

	rb_require( "redleaf/store" );

	/* Redleaf::Store */
	rleaf_cRedleafStore = rb_define_class_under( rleaf_mRedleaf, "Store", rb_cObject );
	rb_define_alloc_func( rleaf_cRedleafStore, rleaf_redleaf_store_s_allocate );

	rb_define_singleton_method( rleaf_cRedleafStore, "backends", rleaf_redleaf_store_s_backends, 0 );
	
	rb_define_method( rleaf_cRedleafStore, "initialize", rleaf_redleaf_store_initialize, -1 );

	/* attr_reader :name */
	rb_attr( rleaf_cRedleafStore, rb_intern("name"), 1, 0, Qtrue );
	/* attr_reader :opthash */
	rb_attr( rleaf_cRedleafStore, rb_intern("opthash"), 1, 0, Qtrue );

	rb_define_method( rleaf_cRedleafStore, "has_contexts?", rleaf_redleaf_store_has_contexts_p, 0 );
	rb_define_method( rleaf_cRedleafStore, "graph", rleaf_redleaf_store_graph, 0 );
	rb_define_method( rleaf_cRedleafStore, "graph=", rleaf_redleaf_store_graph_eq, 1 );
	rb_define_method( rleaf_cRedleafStore, "sync", rleaf_redleaf_store_sync, 0 );

	
	/* Redleaf::HashesStore -- the default concrete Store class */
	rb_require( "redleaf/store/hashes" );
	rleaf_cRedleafHashesStore = 
		rb_define_class_under( rleaf_mRedleaf, "HashesStore", rleaf_cRedleafStore );

}

