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
librdf_uri *rleaf_contexts_feature;


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
	// rleaf_log_with_context( self, "debug", "checking a Redleaf::Graph object (%d).", self );
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

	// rleaf_log_with_context( self, "debug", "fetching a Graph <%p>.", graph );
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


/*
 *  call-seq:
 *     Redleaf::Graph.model_types   -> hash
 *
 *  Return a hash describing all model types supported by the underlying Redland 
 *  library (I think?). :TODO: Figure out what this is returning.
 *
 */
static VALUE
rleaf_redleaf_graph_s_model_types( VALUE klass ) {
	const char *name, *label;
	unsigned int counter = 0;
	VALUE rhash = rb_hash_new();
	
	rleaf_log( "debug", "Enumerating graphs." );
	while( (librdf_model_enumerate(rleaf_rdf_world, counter, &name, &label)) == 0 ) {
		rleaf_log( "debug", "  graph [%d]: name = '%s', label = '%s'", counter, name, label );
		rb_hash_aset( rhash, rb_str_new2(name), rb_str_new2(label) );
		counter++;
	}
	rleaf_log( "debug", "  got stuff for %d graphs.", counter );
	
	return rhash;
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
 *     graph.dup   -> graph
 *
 *  Duplicate the receiver and return the copy.
 *
 */
static VALUE
rleaf_redleaf_graph_dup( VALUE self ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	VALUE dup = rleaf_redleaf_graph_s_allocate( CLASS_OF(self) );
	rleaf_GRAPH *dup_ptr = ALLOC( rleaf_GRAPH );
	
	rleaf_log_with_context( self, "debug", "Duping %s 0x%x", rb_class2name(CLASS_OF(self)), self );
	
	dup_ptr->store = ptr->store;
	dup_ptr->model = librdf_new_model_from_model( ptr->model );

	DATA_PTR( dup ) = dup_ptr;
	OBJ_INFECT( dup, self );

	return dup;
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
		VALUE stmt_obj = rleaf_librdf_statement_to_value( stmt );
		
		rb_ary_push( statements, stmt_obj );
		librdf_stream_next( stream );
	}
	librdf_free_stream( stream );
	
	return statements;
}


/*
 *  call-seq:
 *     graph.append( *statements )   -> Redleaf::Graph
 *     graph << statement            -> Redleaf::Graph
 *
 *  Append statements to the graph, either as Redleaf::Statements, or valid
 *  triples in Arrays.
 *
 *     require 'redleaf/constants'
 *     incude Redleaf::Constants::CommonNamespaces # (for the FOAF namespace constant)
 *     
 *     MY_FOAF = Redleaf::Namspace.new( 'http://deveiate.org/foaf.xml#' )
 *     michael = MY_FOAF[:me]
 *     knows   = FOAF[:knows]
 *
 *     graph = Redleaf::Graph.new
 *
 *     statement1 = Redleaf::Statement.new( :mahlon, knows, michael )
 *     statement2 = [ michael, knows, :mahlon ]
 *     graph.append( statement1, statement2 )
 *     
 *     statement3 = [ michael, RDF[:type], FOAF[:Person] ]
 *     graph << statement3
 */
static VALUE
rleaf_redleaf_graph_append( int argc, VALUE *argv, VALUE self ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_statement *stmt_ptr = NULL;
	VALUE statement = Qnil;
	int i = 0;

	rleaf_log_with_context( self, "debug", "Adding %d statements.", argc );

	for ( i = 0; i < argc; i++ ) {
		statement = argv[i];
		rleaf_log_with_context( self, "debug", "  adding statement %d: %s", i, RSTRING(rb_inspect(statement))->ptr );
		
		/* Check argument to see if it's an array or statement, error otherwise */
		switch ( TYPE(statement) ) {
			case T_ARRAY:
			if ( RARRAY_LEN(statement) != 3 )
				rb_raise( rb_eArgError, "Statement must have three elements." );
			statement = rb_class_new_instance( 3, RARRAY_PTR(statement), rleaf_cRedleafStatement );
			/* fallthrough */
		
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
	}
	
	return self;
}


/*
 *  call-seq:
 *     graph.remove( statement )   -> array
 *
 *  Removes one or more statements from the graph that match the specified +statement+ 
 *  (either a Redleaf::Statement or a valid triple in an Array) and returns any that 
 *  were removed.
 *
 *  Any +nil+ values in the statement will match any value.
 *
 *     # Set a new home page for the Redleaf project, preserving the old one
 *     # as the 'old_homepage'
 *     stmt = graph.remove([ :Redleaf, DOAP[:homepage], nil ])
 *     stmt.predicate = DOAP[:old_homepage]
 *     graph.append( stmt )
 *     graph.append([ :Redleaf, DOAP[:homepage], 
 *                    URL.parse('http://deveiate.org/projects/Redleaf') ])
 */
static VALUE
rleaf_redleaf_graph_remove( VALUE self, VALUE statement ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_statement *search_statement, *stmt;
	librdf_stream *stream;
	int count = 0;
	VALUE rval = rb_ary_new();

	rleaf_log_with_context( self, "debug", "removing statements matching %s",
		RSTRING(rb_inspect(statement))->ptr );
	search_statement = rleaf_value_to_librdf_statement( statement );
 	stream = librdf_model_find_statements( ptr->model, search_statement );

	if ( !stream ) {
		librdf_free_statement( search_statement );
		rb_raise( rb_eRuntimeError, "could not create a stream when removing %s from %s",
		 	RSTRING(rb_inspect(statement))->ptr,
			RSTRING(rb_inspect(self))->ptr );
	}

	while ( ! librdf_stream_end(stream) ) {
		if ( (stmt = librdf_stream_get_object( stream )) == NULL ) break;

		count++;
		rb_ary_push( rval, rleaf_librdf_statement_to_value(stmt) );

		if ( librdf_model_remove_statement(ptr->model, stmt) != 0 ) {
			librdf_free_stream( stream );
			librdf_free_statement( search_statement );
			rb_raise( rb_eRuntimeError, "failed to remove statement from model" );
		}
		
		librdf_stream_next( stream );
	}

	rleaf_log_with_context( self, "debug", "removed %d statements", count );

	librdf_free_stream( stream );
	librdf_free_statement( search_statement );

	return rval;
}


/*
 *  call-seq:
 *     graph.search( subject, predicate, object )   -> array
 *     graph[ subject, predicate, object ]          -> array
 *
 *  Search for statements in the graph with the specified +subject+, +predicate+, and +object+ and
 *  return them. If +subject+, +predicate+, or +object+ are nil, they will match any value.
 *
 *     # Match any statements about authors
 *     graph.load( 'http://deveiant.livejournal.com/data/foaf' )
 *
 *     # 
 *     graph[ nil, FOAF[:knows], nil ]  # => [...]
 */
static VALUE
rleaf_redleaf_graph_search( VALUE self, VALUE subject, VALUE predicate, VALUE object ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *subject_node, *predicate_node, *object_node;
	librdf_statement *search_statement, *stmt;
	librdf_stream *stream;
	int count = 0;
	VALUE rval = rb_ary_new();

	rleaf_log_with_context( self, "debug", "searching for statements matching [%s, %s, %s]",
		RSTRING(rb_inspect(subject))->ptr,
		RSTRING(rb_inspect(predicate))->ptr,
		RSTRING(rb_inspect(object))->ptr );

	subject_node   = rleaf_value_to_subject_node( subject );
	predicate_node = rleaf_value_to_predicate_node( predicate );
	object_node    = rleaf_value_to_object_node( object );

	search_statement = librdf_new_statement_from_nodes( rleaf_rdf_world, subject_node, predicate_node, object_node );
	if ( !search_statement )
		rb_raise( rb_eRuntimeError, "could not create a statement from nodes [%s, %s, %s]",
			RSTRING(rb_inspect(subject))->ptr,
			RSTRING(rb_inspect(predicate))->ptr,
			RSTRING(rb_inspect(object))->ptr );

 	stream = librdf_model_find_statements( ptr->model, search_statement );
	if ( !stream ) {
		librdf_free_statement( search_statement );
		rb_raise( rb_eRuntimeError, "could not create a stream when searching" );
	}

	while ( ! librdf_stream_end(stream) ) {
		stmt = librdf_stream_get_object( stream );
		if ( !stmt ) break;

		count++;
		rb_ary_push( rval, rleaf_librdf_statement_to_value(stmt) );
		librdf_stream_next( stream );
	}

	rleaf_log_with_context( self, "debug", "found %d statements", count );

	librdf_free_stream( stream );
	librdf_free_statement( search_statement );

	return rval;
}


/*
 *  call-seq:
 *     graph.include?( statement )    -> true or false
 *     graph.contains?( statement )   -> true or false
 *
 *  Return +true+ if the receiver contains the specified +statement+, which can be either a
 *  Redleaf::Statement object or a valid triple in an Array.
 *
 */
static VALUE
rleaf_redleaf_graph_include_p( VALUE self, VALUE statement ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_statement *stmt;
	librdf_stream *stream;
	VALUE rval = Qfalse;

	rleaf_log_with_context( self, "debug", "checking for statement matching %s",
		RSTRING(rb_inspect(statement))->ptr );
	stmt = rleaf_value_to_librdf_statement( statement );

	/* According to the Redland docs, this is a better way to test this than 
	   librdf_model_contains_statement if the model has contexts. */
	stream = librdf_model_find_statements( ptr->model, stmt );
	if ( stream != NULL && !librdf_stream_end(stream) ) rval = Qtrue;

	librdf_free_stream( stream );
	librdf_free_statement( stmt );

	return rval;
}


/*
 *  call-seq:
 *     graph.each_statement {|statement| block }   -> graph
 *     graph.each {|statement| block }             	-> graph
 *
 *  Call +block+ once for each statement in the graph.
 *
 */
static VALUE
rleaf_redleaf_graph_each_statement( VALUE self ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_stream *stream;
	librdf_statement *stmt;
	
	stream = librdf_model_as_stream( ptr->model );
	if ( !stream )
		rb_raise( rb_eRuntimeError, "Failed to create stream for graph" );
	
	while ( ! librdf_stream_end(stream) ) {
		stmt = librdf_stream_get_object( stream );
		if ( !stmt ) break;

		rb_yield( rleaf_librdf_statement_to_value(stmt) );
		librdf_stream_next( stream );
	}

	librdf_free_stream( stream );
	
	return self;
}


/*
 *  call-seq:
 *     graph.load( uri )   -> Fixnum
 *
 *  Parse the RDF at the specified +uri+ into the receiving graph. Returns the number of statements
 *  added to the graph.
 *
 *     graph = Redleaf::Graph.new
 *     graph.load( "http://bigasterisk.com/foaf.rdf" )
 *     graph.load( "http://www.w3.org/People/Berners-Lee/card.rdf" )
 *     graph.load( "http://danbri.livejournal.com/data/foaf" ) 
 *     
 *     graph.size
 */
static VALUE
rleaf_redleaf_graph_load( VALUE self, VALUE uri ) {
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
		rb_raise( rb_eRuntimeError, "failed to load %s into Model <0x%x>",
		librdf_uri_as_string(rdfuri), self );

	return INT2FIX( librdf_model_size(ptr->model) - statement_count );
}


/*
 *  call-seq:
 *     graph.supports_contexts?   -> true or false
 *
 *  Returns +true+ if the receiving model supports contexts.
 *
 */
static VALUE
rleaf_redleaf_graph_supports_contexts_p( VALUE self ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *rval;
	const char *literal_rval;
	
	rval = librdf_model_get_feature( ptr->model, rleaf_contexts_feature );
	if ( rval == NULL ) return Qfalse;

	literal_rval = (const char *)librdf_node_get_literal_value( rval );
	if ( strncmp(literal_rval, "1", 1) == 0 )
		return Qtrue;
	else
		return Qfalse;
}


/*
 *  call-seq:
 *     graph.contexts   -> array
 *
 *  Returns an Array of URIs describing the contexts in the receiving graph.
 *
 */
static VALUE
rleaf_redleaf_graph_contexts( VALUE self ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_iterator *iter;
	librdf_node *context_node;
	VALUE context = Qnil;
	VALUE rval = rb_ary_new();
	int count = 0;
	
	if ( (iter = librdf_model_get_contexts(ptr->model)) == NULL ) {
		rleaf_log_with_context( self, "info", "couldn't fetch a context iterator; "
			"contexts not supported?" );
		return rval;
	}

	rleaf_log_with_context( self, "debug", "iterating over contexts for graph 0x%x", self );

	while ( ! librdf_iterator_end(iter) ) {
		context_node = librdf_iterator_get_context( iter );
		context = rleaf_librdf_uri_node_to_object( context_node );
		rleaf_log_with_context( self, "debug", "  context %d: %s",
			count, RSTRING(rb_inspect(context))->ptr );
		
		rb_ary_push( rval, context );
		librdf_iterator_next( iter );
	}
	librdf_free_iterator( iter );

	return rval;
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

	rleaf_contexts_feature = librdf_new_uri( rleaf_rdf_world, 
		(unsigned char *)LIBRDF_MODEL_FEATURE_CONTEXTS );

	/* Class methods */
	rleaf_cRedleafGraph = rb_define_class_under( rleaf_mRedleaf, "Graph", rb_cObject );
	rb_define_alloc_func( rleaf_cRedleafGraph, rleaf_redleaf_graph_s_allocate );
	
	rb_define_singleton_method( rleaf_cRedleafGraph, "model_types", 
		rleaf_redleaf_graph_s_model_types, 0 );

	/* Instance methods */
	rb_define_method( rleaf_cRedleafGraph, "initialize", rleaf_redleaf_graph_initialize, -1 );
	rb_define_method( rleaf_cRedleafGraph, "dup", rleaf_redleaf_graph_dup, 0 );

	rb_define_method( rleaf_cRedleafGraph, "store", rleaf_redleaf_graph_store, 0 );
	rb_define_method( rleaf_cRedleafGraph, "store=", rleaf_redleaf_graph_store_eq, 1 );

	rb_define_method( rleaf_cRedleafGraph, "size", rleaf_redleaf_graph_size, 0 );
	rb_define_method( rleaf_cRedleafGraph, "statements", rleaf_redleaf_graph_statements, 0 );

	rb_define_method( rleaf_cRedleafGraph, "append", rleaf_redleaf_graph_append, -1 );
	rb_define_alias ( rleaf_cRedleafGraph, "<<", "append" );
	rb_define_method( rleaf_cRedleafGraph, "remove", rleaf_redleaf_graph_remove, 1 );
	rb_define_alias ( rleaf_cRedleafGraph, "delete", "remove" );
	
	rb_define_method( rleaf_cRedleafGraph, "search", rleaf_redleaf_graph_search, 3 );
	rb_define_alias ( rleaf_cRedleafGraph, "[]", "search" );
	rb_define_method( rleaf_cRedleafGraph, "include?", rleaf_redleaf_graph_include_p, 1 );
	rb_define_alias ( rleaf_cRedleafGraph, "contains?", "include?" );
	
	rb_define_method( rleaf_cRedleafGraph, "each_statement", rleaf_redleaf_graph_each_statement, 0 );
	rb_define_alias ( rleaf_cRedleafGraph, "each", "each_statement" );
	
	rb_define_method( rleaf_cRedleafGraph, "load", rleaf_redleaf_graph_load, 1 );

	rb_define_method( rleaf_cRedleafGraph, "supports_contexts?", 
		rleaf_redleaf_graph_supports_contexts_p, 0 );
	rb_define_alias ( rleaf_cRedleafGraph, "contexts_enabled?", "supports_contexts?" );

	rb_define_method( rleaf_cRedleafGraph, "contexts", rleaf_redleaf_graph_contexts, 0 );

	
	/*

	-- #has_predicate_in?( object, url )/#has_arc_in?( object, url )
	int librdf_model_has_arc_in(librdf_model *model, librdf_node *node, librdf_node *property);

	-- #has_predicate_out?( subject, url )/#has_arc_out?( subject, url )
	int librdf_model_has_arc_out(librdf_model *model, librdf_node *node, librdf_node *property);

	-- #subjects( predicate, object )/#sources( predicate, object )
	librdf_iterator* librdf_model_get_sources(librdf_model* model, librdf_node* arc, librdf_node* target)

	-- #predicates( subject, object )/#arcs( subject, object )
	librdf_iterator* librdf_model_get_arcs(librdf_model* model, librdf_node* source, librdf_node* target)

	-- #objects( subject, predicate )/#targets( subject, predicate )
	librdf_iterator* librdf_model_get_targets(librdf_model* model, librdf_node* source, librdf_node* arc)

	-- #subject( predicate, object )/#source( predicate, object )
	librdf_node* librdf_model_get_source(librdf_model* model, librdf_node* arc, librdf_node* target)

	-- #predicate( subject, object )/#arc( subject, object )
	librdf_node* librdf_model_get_arc(librdf_model* model, librdf_node* source, librdf_node* target)

	-- #object( subject, predicate )/#target( subject, predicate )
	librdf_node* librdf_model_get_target(librdf_model* model, librdf_node* source, librdf_node* arc)

	-- #marshal_dump
	-- #marshal_load
	librdf_stream* librdf_model_as_stream(librdf_model* model)

	-- #arcs_in( object )
	librdf_iterator* librdf_model_get_arcs_in(librdf_model* model, librdf_node* node)

	-- #arcs_out( subject )
	librdf_iterator* librdf_model_get_arcs_out(librdf_model* model, librdf_node* node)

	-- #query( string, ... )
	librdf_query_results* librdf_model_query_execute( librdf_model *model, librdf_query *query );

	-- #sync
	void librdf_model_sync(librdf_model* model)

	-- #to_s
	-- Maybe methods like: #as_ntriples, #as_rdfxml, etc? that use the mime_type parameter.
	unsigned char* librdf_model_to_counted_string( librdf_model *model, librdf_uri *uri, const char *name, const char *mime_type, librdf_uri *type_uri, size_t *string_length_p );
	unsigned char* librdf_model_to_string( librdf_model *model, librdf_uri *uri, const char *name, const char *mime_type, librdf_uri *type_uri );
	
	
	--------------------------------------------------------------
	Transactions                                                  
	--------------------------------------------------------------
	-- #transaction { block }
	int librdf_model_transaction_commit( librdf_model *model );
	void* librdf_model_transaction_get_handle( librdf_model *model );
	int librdf_model_transaction_rollback( librdf_model *model );
	int librdf_model_transaction_start( librdf_model *model );
	int librdf_model_transaction_start_with_handle( librdf_model *model, void *handle );
	

	--------------------------------------------------------------
	Contexts                                                      
	--------------------------------------------------------------

	-- 
	int librdf_model_context_add_statement(librdf_model* model, librdf_node* context, librdf_statement* statement)
	int librdf_model_context_add_statements(librdf_model* model, librdf_node* context, librdf_stream* stream)
	int librdf_model_context_remove_statement(librdf_model* model, librdf_node* context, librdf_statement* statement)
	int librdf_model_context_remove_statements(librdf_model* model, librdf_node* context)
	librdf_stream* librdf_model_context_as_stream(librdf_model* model, librdf_node* context)
	int librdf_model_contains_context( librdf_model *model, librdf_node *context );
	librdf_stream* librdf_model_find_statements_in_context( librdf_model *model, librdf_statement *statement, librdf_node *context_node );

	*/
}

