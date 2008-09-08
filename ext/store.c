/* 
 * Redleaf::Store -- RDF persistent storage classes
 * $Id: store.c 18 2008-08-19 02:39:46Z deveiant $
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

VALUE rleaf_cRedleafStore;


/* --------------------------------------------------
 *	Memory-management functions
 * -------------------------------------------------- */

/*
 * Allocation function
 */
static librdf_storage *
rleaf_store_alloc( const char *backend, const char *name, const char *optstring ) {
	librdf_storage *ptr = librdf_new_storage( rleaf_rdf_world, backend, name, optstring );

	rleaf_log( "debug", "initialized a librdf_storage <%p>", ptr );
	return ptr;
}


/*
 * GC Mark function
 */
static void rleaf_store_gc_mark( librdf_storage *ptr ) {
	rleaf_log( "debug", "in mark function for RedLeaf::Store %p", ptr );
	
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
static void rleaf_store_gc_free( librdf_storage *ptr ) {
	if ( ptr ) {
		rleaf_log( "debug", "in free function of Redleaf::Store <%p>", ptr );
		librdf_free_storage( ptr );
		
		ptr = NULL;
	}

	else {
		rleaf_log( "warn", "not freeing an uninitialized Redleaf::Store" );
	}
}


/*
 * Object validity checker. Returns the data pointer.
 */
static librdf_storage *check_store( VALUE self ) {
	rleaf_log( "debug", "checking a %s object (%d).", rb_class2name(CLASS_OF(self)), self );
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
static librdf_storage *get_store( VALUE self ) {
	librdf_storage *stmt = check_store( self );

	rleaf_log( "debug", "fetching a Store <%p>.", stmt );
	if ( !stmt )
		rb_raise( rb_eRuntimeError, "uninitialized Store" );

	return stmt;
}


/* --------------------------------------------------------------
 * Utility functions
 * -------------------------------------------------------------- */

/*
 * Make a librdf-style option string out of a Ruby Hash. The returned pointer will need to be
 * freed by the caller.
 */
static char *rleaf_optstring_from_rubyhash( VALUE opthash ) {
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
static VALUE rleaf_redleaf_store_s_allocate( VALUE klass ) {
	if ( klass == rleaf_cRedleafStore ) {
		rb_raise( rb_eRuntimeError, "cannot allocate a Redleaf::Store, as it is an abstract class" );
	}

	rleaf_log( "debug", "wrapping an uninitialized %s pointer.", rb_class2name(klass) );
	return Data_Wrap_Struct( klass, rleaf_store_gc_mark, rleaf_store_gc_free, 0 );
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
static VALUE rleaf_redleaf_store_initialize( int argc, VALUE *argv, VALUE self ) {
	if ( !check_store(self) ) {
		librdf_storage *store;
		VALUE backend = Qnil, name = Qnil, opthash = Qnil;
		const char *backendname = NULL, *storename = NULL;
		char *optstring = NULL;

		if ( rb_scan_args(argc, argv, "02", &name, &opthash) > 2 )
			rb_raise( rb_eArgError, "wrong number of arguments (%d for 1)", argc );
		if ( TYPE(opthash) != T_HASH )
			rb_raise( rb_eArgError, "cannot convert %s to Hash", rb_class2name(CLASS_OF(opthash)) );

		/* Get the backend name */
		backend = rb_ivar_get( CLASS_OF(self), rb_intern("@backend") );
		backendname = rb_id2name( rb_to_id(backend) );
		storename = StringValuePtr( name );

		/* Make the option string */
		optstring = rleaf_optstring_from_rubyhash( opthash );
		rleaf_log( "debug", "Got backend = '%s', name = '%s', optstring = '%s'", 
		           backendname, storename, optstring );

		DATA_PTR( self ) = store = rleaf_store_alloc( backendname, storename, optstring );

		xfree( optstring );
		
	} else {
		rb_raise( rb_eRuntimeError,
				  "Cannot re-initialize a store once it's been created." );
	}

	return self;
}


/*
 *  call-seq:
 *     store.has_contexts?   => true or false
 *
 *  Return +true+ if the backend of the receiver supports contexts and the receiver has them 
 *  enabled.
 *
 */
static VALUE rleaf_redleaf_store_has_contexts_p( VALUE self ) {
	librdf_storage *store = get_store( self );
	
	rleaf_log_with_context( self, "debug", "Checking for contexts in %s:%p", 
		rb_class2name(CLASS_OF(self)), store );
	
	/* Suggested by laalto on irc://freenode.net/#redland */
	if ( librdf_storage_get_contexts(store) == NULL ) {
		return Qfalse;
	} else {
		return Qtrue;
	}
}


/*
 * Redleaf Store class
 */
void rleaf_init_redleaf_store( void ) {
	rleaf_log( "debug", "Initializing Redleaf::Store" );

#ifdef FOR_RDOC
	rleaf_mRedleaf = rb_define_module( "Redleaf" );
#endif

	rb_require( "redleaf/store" );
	rleaf_cRedleafStore = rb_define_class_under( rleaf_mRedleaf, "Store", rb_cObject );

	rb_define_alloc_func( rleaf_cRedleafStore, rleaf_redleaf_store_s_allocate );
	
	rb_define_method( rleaf_cRedleafStore, "initialize", rleaf_redleaf_store_initialize, -1 );

	rb_define_method( rleaf_cRedleafStore, "has_contexts?", rleaf_redleaf_store_has_contexts_p, 0 );
}

