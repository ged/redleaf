/* 
 * Redleaf::Graph -- RDF Graph (Model) class
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
		rb_raise( rb_eArgError, "Ack! Tried to create a graph with an uninitialized %s", 
		          rb_obj_classname(storeobj) );

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
	if ( ptr && ptr->store ) rb_gc_mark( ptr->store );
}



/*
 * GC Free function
 */
static void 
rleaf_graph_gc_free( rleaf_GRAPH *ptr ) {
	if ( ptr->model && rleaf_rdf_world ) {
		/* Not sure if I need to break the graph<->storage link here, and if I do, how. [MG] */
		librdf_free_model( ptr->model );

		ptr->model = NULL;
		ptr->store = Qnil;

		xfree( ptr );
		ptr = NULL;
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
				  rb_obj_classname( self ) );
    }
	
	return DATA_PTR( self );
}


/*
 * Fetch the data pointer and check it for sanity.
 */
rleaf_GRAPH *
rleaf_get_graph( VALUE self ) {
	rleaf_GRAPH *graph = check_graph( self );

	if ( !graph )
		rb_fatal( "Use of uninitialized Graph." );

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
 *  library.
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


/*
 *  call-seq:
 *     Redleaf::Graph.serializers   -> hash
 *
 *  Return a Hash of supported serializers from the underlying Redland library.
 *
 *     Redleaf::Parser.serializers
 *     # => { "rss-1.0"       => "RSS 1.0",
 *     #      "rdfxml"        => "RDF/XML",
 *     #      "json-triples"  => "RDF/JSON Triples",
 *     #      "rdfxml-abbrev" => "RDF/XML (Abbreviated)",
 *     #      "rdfxml-xmp"    => "RDF/XML (XMP Profile)",
 *     #      "turtle"        => "Turtle",
 *     #      "ntriples"      => "N-Triples",
 *     #      "json"          => "RDF/JSON Resource-Centric",
 *     #      "dot"           => "GraphViz DOT format",
 *     #      "atom"          => "Atom 1.0" }
 */
static VALUE
rleaf_redleaf_graph_s_serializers( VALUE klass ) {
	const char *name, *desc;
	unsigned int counter = 0;
	VALUE rhash = rb_hash_new();
	
	rleaf_log( "debug", "Enumerating serializers." );
	while( (librdf_serializer_enumerate(rleaf_rdf_world, counter, &name, &desc)) == 0 ) {
		// rleaf_log( "debug", "  serializer [%d]: name = '%s', desc = '%s'", counter, name, desc );
		rb_hash_aset( rhash, rb_str_new2(name), rb_str_new2(desc) );
		counter++;
	}
	rleaf_log( "debug", "  got %d serializers.", counter );
	
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
	if ( !check_graph(self) ) {
		rleaf_GRAPH *graph;
		VALUE store = Qnil;

		/* Default the store if one isn't given */
		if ( rb_scan_args(argc, argv, "01", &store) == 0 ) {
			rleaf_log_with_context( self, "debug", "Creating a new default store for graph 0x%x", self );
			store = rb_class_new_instance( 0, NULL, DEFAULT_STORE_CLASS );
		}

		if ( !IsStore(store) )
			rb_raise( rb_eTypeError, "wrong argument type %s (expected a Redleaf::Store)",
				rb_obj_classname(store) );

		DATA_PTR( self ) = graph = rleaf_graph_alloc( store );
		
	} else {
		rb_raise( rleaf_eRedleafError,
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
	librdf_stream *statements = librdf_model_as_stream( ptr->model );
	
	rleaf_log_with_context( self, "debug", "Duping %s 0x%x", rb_obj_classname(self), self );
	
	dup_ptr->store = ptr->store;
	dup_ptr->model = librdf_new_model_from_model( ptr->model );
	if ( ! dup_ptr->model ) {
		librdf_free_stream( statements );
		xfree( dup_ptr );
		rb_raise( rleaf_eRedleafError, "couldn't create new model from model <%p>", ptr->model );
	}
	
	if ( (librdf_model_add_statements(dup_ptr->model, statements)) != 0 ) {
		librdf_free_stream( statements );
		librdf_free_model( dup_ptr->model );
		xfree( dup_ptr );
		rb_raise( rleaf_eRedleafError, "couldn't add statements from the original model" );
	}

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
			self, rb_obj_classname(storeobj), storeobj );
		rb_funcall( storeobj, rb_intern("graph="), 1, self );
	} else {
		rb_raise( rb_eArgError, "cannot convert %s to Redleaf::Store", 
			rb_obj_classname(storeobj) );
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
		rleaf_log( "debug", "  adding statement %d: %s", i,
		           RSTRING_PTR(rb_inspect(statement)) );
		
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
					rb_obj_classname(statement) );
			stmt_ptr = rleaf_get_statement( statement );
			break;
		
			default:
			rb_raise( rb_eArgError, "can't convert %s into Redleaf::Statement",
				rb_obj_classname(statement) );
		}
	
		if ( librdf_model_add_statement(ptr->model, stmt_ptr) != 0 )
			rb_raise( rleaf_eRedleafError, "could not add statement %s to graph",
			 	RSTRING_PTR(rb_inspect(statement)) );
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
		RSTRING_PTR(rb_inspect(statement)) );
	search_statement = rleaf_value_to_librdf_statement( statement );
 	stream = librdf_model_find_statements( ptr->model, search_statement );

	if ( !stream ) {
		librdf_free_statement( search_statement );
		rb_raise( rleaf_eRedleafError, "could not create a stream when removing %s from %s",
		 	RSTRING_PTR(rb_inspect(statement)),
			RSTRING_PTR(rb_inspect(self)) );
	}

	while ( ! librdf_stream_end(stream) ) {
		if ( (stmt = librdf_stream_get_object( stream )) == NULL ) break;

		count++;
		rb_ary_push( rval, rleaf_librdf_statement_to_value(stmt) );

		if ( librdf_model_remove_statement(ptr->model, stmt) != 0 ) {
			librdf_free_stream( stream );
			librdf_free_statement( search_statement );
			rb_raise( rleaf_eRedleafError, "failed to remove statement from model" );
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

	rleaf_log_with_context( self, "debug", "searching for statements matching {%s, %s, %s}",
		RSTRING_PTR(rb_inspect(subject)),
		RSTRING_PTR(rb_inspect(predicate)),
		RSTRING_PTR(rb_inspect(object)) );

	subject_node   = rleaf_value_to_subject_node( subject );
	predicate_node = rleaf_value_to_predicate_node( predicate );
	object_node    = rleaf_value_to_object_node( object );

	search_statement = librdf_new_statement_from_nodes( rleaf_rdf_world, subject_node, predicate_node, object_node );
	if ( !search_statement )
		rb_raise( rleaf_eRedleafError, "could not create a statement from nodes [%s, %s, %s]",
			RSTRING_PTR(rb_inspect(subject)),
			RSTRING_PTR(rb_inspect(predicate)),
			RSTRING_PTR(rb_inspect(object)) );

 	stream = librdf_model_find_statements( ptr->model, search_statement );
	if ( !stream ) {
		librdf_free_statement( search_statement );
		rb_raise( rleaf_eRedleafError, "could not create a stream when searching" );
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
		RSTRING_PTR(rb_inspect(statement)) );
	stmt = rleaf_value_to_librdf_statement( statement );

	/* According to the Redland docs, this is a better way to test this than 
	   librdf_model_contains_statement if the model has contexts. Since we want
	   to support contexts, it's easier just to assume that they're always enabled.
	 */
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
		rb_raise( rleaf_eRedleafError, "Failed to create stream for graph" );
	
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
 *  added to the graph (if the underlying store supports ).
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
		rb_raise( rleaf_eRedleafError, "failed to create a parser." );

	rdfuri = rleaf_object_to_librdf_uri( uri );
	
	if ( librdf_parser_parse_into_model(parser, rdfuri, NULL, ptr->model) != 0 )
		rb_raise( rleaf_eRedleafError, "failed to load %s into %s",
		librdf_uri_as_string(rdfuri), RSTRING_PTR(rb_inspect( self )) );

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
			count, RSTRING_PTR(rb_inspect(context)) );
		
		rb_ary_push( rval, context );
		librdf_iterator_next( iter );
	}
	librdf_free_iterator( iter );

	return rval;
}


/*
 *  call-seq:
 *     graph.serialized_as( format )   -> string
 *
 *  Return the graph serialized to a String in the specified +format+. Valid +format+s are keys
 *  of the Hash returned by ::serializers.
 *
 */
static VALUE
rleaf_redleaf_graph_serialized_as( VALUE self, VALUE format ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_serializer *serializer;
	size_t length = 0;
	const char *formatname;
	unsigned char *serialized;
	
	formatname = StringValuePtr( format );
	rleaf_log_with_context( self, "debug", "trying to serialize as '%s'", formatname );
	
	if ( !RTEST(rb_funcall(CLASS_OF(self), rb_intern("valid_format?"), 1, format)) )
		rb_raise( rleaf_eRedleafFeatureError, "unsupported serialization format '%s'", formatname );
	
	rleaf_log_with_context( self, "debug", "valid format '%s' specified.", formatname );
	serializer = librdf_new_serializer( rleaf_rdf_world, formatname, NULL, NULL );
	if ( !serializer )
		rb_raise( rleaf_eRedleafError, "could not create a '%s' serializer", formatname );

	/* :TODO: Support for the 'baseuri' argument? */
	serialized = librdf_serializer_serialize_model_to_counted_string( serializer, NULL, ptr->model, &length );
	librdf_free_serializer( serializer );
	
	if ( !serialized )
		rb_raise( rleaf_eRedleafError, "could not serialize model as '%s'", formatname );

	rleaf_log_with_context( self, "debug", "got %d bytes of '%s'", length, formatname );
	return rb_str_new( (char *)serialized, length );
}


/*
 *  call-seq:
 *     graph.execute_query( qstring, language=:sparql, limit=nil, offset=nil ) -> queryresult
 *
 *  Run the query in the given query string (+qstring+) against the graph. The query +language+ 
 *  specifies the query language, and +limit+, and +offset+ can be used to limit the results. The
 *  #query method is the public interface to this method.
 *
 */
static VALUE
rleaf_redleaf_graph_execute_query( int argc, VALUE *argv, VALUE self ) {
	rleaf_log_with_context( self, "debug", "Called eq with %d args.", argc );
	rleaf_GRAPH *ptr = rleaf_get_graph( self );

	VALUE qstring, language, limit, offset, base;
	const char *qlang_name = NULL;
	librdf_uri *qlang_uri = NULL, *base_uri = NULL;
	librdf_query *query;
	librdf_query_results *res;

	rb_scan_args( argc, argv, "14", &qstring, &language, &limit, &offset, &base );
	rleaf_log_with_context(
		self,
		"debug",
		"Executing query=%s (%s) with offset=%s, limit=%s, and base=%s",
		RSTRING_PTR(rb_inspect( qstring )),
		RSTRING_PTR(rb_inspect( language )),
		RSTRING_PTR(rb_inspect( limit )),
		RSTRING_PTR(rb_inspect( offset )),
		RSTRING_PTR(rb_inspect( base ))
	  );

	/* Set the query language, from a URI or a language name string */
	if ( RTEST(language) && IsURI(language) )
		qlang_uri = rleaf_object_to_librdf_uri( language );
	
	else if ( language != Qnil ) {
		VALUE langstring = rb_obj_as_string( language );
		qlang_name = (const char *)(RSTRING_PTR(langstring));
	}

	/* Set the baseuri if one is specified */
	if ( RTEST(base) ) {
		VALUE basestr = rb_obj_as_string( base );
		base_uri = librdf_new_uri( rleaf_rdf_world, (const unsigned char *)(RSTRING_PTR(basestr)) );
		if ( !base_uri ) {
			if ( qlang_uri ) librdf_free_uri( qlang_uri );
			rb_raise( rleaf_eRedleafError, "Couldn't make a librdf_uri out of %s",
				RSTRING_PTR(basestr) );
		}
	}
	
	/* Make the query object */
	rleaf_log_with_context( self, "debug", "  creating a new '%s' query: %s", 
		qlang_name, RSTRING_PTR(qstring) );
	query = librdf_new_query( rleaf_rdf_world, qlang_name, qlang_uri, 
		(unsigned char *)(StringValuePtr(qstring)), base_uri );
	if ( !query ) {
		if ( qlang_uri ) librdf_free_uri( qlang_uri );
		if ( base_uri ) librdf_free_uri( base_uri );
		rb_raise( rleaf_eRedleafError, "Failed to create query %s", RSTRING_PTR(qstring) );
	}
	
	/* Check for a non-nil limit and offset, setting them in the query object if they exist. */
	if ( RTEST(limit) ) {
		rleaf_log_with_context( self, "debug", "  setting limit to %d", FIX2INT(limit) );
		librdf_query_set_limit( query, FIX2INT(limit) );
	}
	if ( RTEST(offset) ) {
		rleaf_log_with_context( self, "debug", "  setting offset to %d", FIX2INT(offset) );
		librdf_query_set_offset( query, FIX2INT(offset) );
	}

	/* Run the query against the model */
	rleaf_log_with_context( self, "debug", "  executing query <%p> against model <%p>", query, ptr->model );
	res = librdf_model_query_execute( ptr->model, query );
	
	if ( qlang_uri ) librdf_free_uri( qlang_uri );
	if ( base_uri ) librdf_free_uri( base_uri );

	if ( !res )
		rb_raise( rleaf_eRedleafError, "Execution of query failed." );
	
	return rleaf_new_queryresult( self, res );
}


/*
 *  call-seq:
 *     graph.subjects( predicate, object )   -> [ nodes ]
 *
 *  Return an Array of subject nodes from the graph that have the specified +predicate+ and +object+.
 *
 */
static VALUE 
rleaf_redleaf_graph_subjects( VALUE self, VALUE predicate, VALUE object ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *arc, *target;
	librdf_iterator *iter;
	VALUE rval = rb_ary_new();
	
	arc = rleaf_value_to_predicate_node( predicate );
	target = rleaf_value_to_object_node( object );
	
	iter = librdf_model_get_sources( ptr->model, arc, target );
	if ( !iter ) {
		librdf_free_node( arc );
		librdf_free_node( target );
		rb_raise( rleaf_eRedleafError, "failed to get sources for {? -%s-> %s}",
			RSTRING_PTR(rb_inspect(predicate)),
			RSTRING_PTR(rb_inspect(object)) );
	}

	while ( ! librdf_iterator_end(iter) ) {
		librdf_node *source = librdf_iterator_get_object( iter );
		VALUE subject = rleaf_librdf_node_to_value( source );
		
		rb_ary_push( rval, subject );
		librdf_iterator_next( iter );
	}
	librdf_free_iterator( iter );
	
	return rval;
}


/*
 *  call-seq:
 *     graph.subject( predicate, object )   -> nodes
 *
 *  Return one subject of a statement with the specified +predicate+ and +object+.
 *  
 */
static VALUE 
rleaf_redleaf_graph_subject( VALUE self, VALUE predicate, VALUE object ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *source, *arc, *target;
	VALUE rval = Qnil;
	
	arc = rleaf_value_to_predicate_node( predicate );
	target = rleaf_value_to_object_node( object );
	
	source = librdf_model_get_source( ptr->model, arc, target );
	
	librdf_free_node( arc );
	librdf_free_node( target );
	
	if ( source ) {
		rval = rleaf_librdf_node_to_value( source );
		librdf_free_node( source );
	}
	
	return rval;
}



/*
 *  call-seq:
 *     graph.predicates( subject, object )   -> [ nodes ]
 *
 *  Return an Array of predicate nodes from the graph that have the specified +subject+ and +object+.
 *
 */
static VALUE 
rleaf_redleaf_graph_predicates( VALUE self, VALUE subject, VALUE object ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *source, *target;
	librdf_iterator *iter;
	VALUE rval = rb_ary_new();
	
	source = rleaf_value_to_subject_node( subject );
	target = rleaf_value_to_object_node( object );
	
	iter = librdf_model_get_arcs( ptr->model, source, target );
	if ( !iter ) {
		librdf_free_node( source );
		librdf_free_node( target );
		rb_raise( rleaf_eRedleafError, "failed to get arcs for: {%s -?-> %s}",
			RSTRING_PTR(rb_inspect(subject)),
			RSTRING_PTR(rb_inspect(object)) );
	}

	while ( ! librdf_iterator_end(iter) ) {
		librdf_node *source = librdf_iterator_get_object( iter );
		VALUE predicate = rleaf_librdf_node_to_value( source );
		
		rb_ary_push( rval, predicate );
		librdf_iterator_next( iter );
	}
	librdf_free_iterator( iter );
	
	return rval;
}


/*
 *  call-seq:
 *     graph.predicate( subject, object )   -> nodes
 *
 *  Return one predicate of a statement with the specified +subject+ and +object+.
 *  
 */
static VALUE 
rleaf_redleaf_graph_predicate( VALUE self, VALUE subject, VALUE object ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *source, *arc, *target;
	VALUE rval = Qnil;
	
	source = rleaf_value_to_subject_node( subject );
	target = rleaf_value_to_object_node( object );
	
	arc = librdf_model_get_arc( ptr->model, source, target );
	
	librdf_free_node( source );
	librdf_free_node( target );
	
	if ( arc ) {
		rval = rleaf_librdf_node_to_value( arc );
		librdf_free_node( arc );
	}
	
	return rval;
}



/*
 *  call-seq:
 *     graph.objects( subject, predicate )   -> [ nodes ]
 *
 *  Return an Array of object nodes from the graph that have the specified +subject+ and +predicate+.
 *
 */
static VALUE 
rleaf_redleaf_graph_objects( VALUE self, VALUE subject, VALUE predicate ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *source, *arc;
	librdf_iterator *iter;
	VALUE rval = rb_ary_new();
	
	source = rleaf_value_to_subject_node( subject );
	arc = rleaf_value_to_predicate_node( predicate );
	
	iter = librdf_model_get_targets( ptr->model, source, arc );
	if ( !iter ) {
		librdf_free_node( source );
		librdf_free_node( arc );
		rb_raise( rleaf_eRedleafError, "failed to get targets for: {%s -?-> %s}",
			RSTRING_PTR(rb_inspect(subject)),
			RSTRING_PTR(rb_inspect(predicate)) );
	}

	while ( ! librdf_iterator_end(iter) ) {
		librdf_node *source = librdf_iterator_get_object( iter );
		VALUE object = rleaf_librdf_node_to_value( source );
		
		rb_ary_push( rval, object );
		librdf_iterator_next( iter );
	}
	librdf_free_iterator( iter );
	
	return rval;
}


/*
 *  call-seq:
 *     graph.object( subject, predicate )   -> nodes
 *
 *  Return one object of a statement with the specified +subject+ and +predicate+.
 *  
 */
static VALUE 
rleaf_redleaf_graph_object( VALUE self, VALUE subject, VALUE predicate ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *source, *target, *arc;
	VALUE rval = Qnil;
	
	source = rleaf_value_to_subject_node( subject );
	arc = rleaf_value_to_predicate_node( predicate );
	
	target = librdf_model_get_target( ptr->model, source, arc );
	
	librdf_free_node( source );
	librdf_free_node( arc );
	
	if ( target ) {
		rval = rleaf_librdf_node_to_value( target );
		librdf_free_node( target );
	}
	
	return rval;
}


/*
 *  call-seq:
 *     graph.predicates_about( subject )   -> nodes
 *
 *  Returns an Array of predicates (URI objects) that point from the specified +subject+.
 *
 */
static VALUE 
rleaf_redleaf_graph_predicates_about( VALUE self, VALUE subject ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *source;
	librdf_iterator *iter;
	VALUE rval = rb_ary_new();

	rleaf_log_with_context( self, "debug", "fetching predicates about %s",
		RSTRING_PTR(rb_inspect( subject )) );
	
	source = rleaf_value_to_subject_node( subject );
	iter = librdf_model_get_arcs_out( ptr->model, source );
	
	if ( !iter ) {
		librdf_free_node( source );
		rb_raise( rleaf_eRedleafError, "could not get arcs out for %s", 
		          RSTRING_PTR(rb_inspect(subject)) );
	}
	
	while ( ! librdf_iterator_end(iter) ) {
		librdf_node *arc = librdf_iterator_get_object( iter );
		VALUE predicate;
		
		if ( !arc ) {
			librdf_free_iterator( iter );
			librdf_free_node( source );
			rb_raise( rleaf_eRedleafError, "iterator returned NULL arc" );
		}

		predicate = rleaf_librdf_node_to_value( arc );
		
		rb_ary_push( rval, predicate );
		librdf_iterator_next( iter );
	}
	librdf_free_iterator( iter );
	librdf_free_node( source );
	
	return rval;
}


/*
 *  call-seq:
 *     graph.has_predicate_about?( subject, predicate )   -> true or false
 *
 *  Returns +true+ if the graph has at least one statement with the specified +subject+ and
 *  +predicate+.
 *
 */
static VALUE
rleaf_redleaf_graph_has_predicate_about_p( VALUE self, VALUE subject, VALUE predicate ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *source, *arc;
	VALUE rval = Qfalse;

	rleaf_log_with_context( self, "debug", "checking for presence of a %s predicate about %s",
		RSTRING_PTR(rb_inspect( predicate )), RSTRING_PTR(rb_inspect( subject )) );
	
	source = rleaf_value_to_subject_node( subject );
	arc = rleaf_value_to_predicate_node( predicate );

	if ( librdf_model_has_arc_out(ptr->model, source, arc) != 0 )
		rval = Qtrue;

	librdf_free_node( arc );
	librdf_free_node( source );
	
	return rval;
}


/*
 *  call-seq:
 *     graph.predicates_entailing( object )   -> nodes
 *
 *  Returns an Array of predicates (URI objects) that point to the specified +object+.
 *
 */
static VALUE 
rleaf_redleaf_graph_predicates_entailing( VALUE self, VALUE object ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *target;
	librdf_iterator *iter;
	VALUE rval = rb_ary_new();
	
	target = rleaf_value_to_subject_node( object );
	iter = librdf_model_get_arcs_in( ptr->model, target );
	
	if ( !iter ) {
		librdf_free_node( target );
		rb_raise( rleaf_eRedleafError, "could not get arcs in for %s",
		          RSTRING_PTR(rb_inspect(object)) );
	}
	
	while ( ! librdf_iterator_end(iter) ) {
		librdf_node *arc = librdf_iterator_get_object( iter );
		VALUE predicate;
		
		if ( !arc ) {
			librdf_free_iterator( iter );
			rb_raise( rleaf_eRedleafError, "iterator returned NULL arc" );
		}

		predicate = rleaf_librdf_node_to_value( arc );
		
		rb_ary_push( rval, predicate );
		librdf_iterator_next( iter );
	}
	librdf_free_iterator( iter );
	
	return rval;
}


/*
 *  call-seq:
 *     graph.has_predicate_entailing?( predicate, object )   -> true or false
 *
 *  Returns +true+ if the graph has at least one statement with the specified +predicate+
 *  and +object+.
 *
 */
static VALUE
rleaf_redleaf_graph_has_predicate_entailing_p( VALUE self, VALUE predicate, VALUE object ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *target, *arc;
	VALUE rval = Qfalse;

	rleaf_log_with_context( self, "debug", "checking for presence of a %s predicate entailing %s",
		RSTRING_PTR(rb_inspect( predicate )), RSTRING_PTR(rb_inspect( object )) );
	
	arc = rleaf_value_to_predicate_node( predicate );
	target = rleaf_value_to_object_node( object );

	if ( librdf_model_has_arc_in(ptr->model, target, arc) != 0 )
		rval = Qtrue;

	librdf_free_node( target );
	librdf_free_node( arc );
	
	return rval;
}


/*
 *  call-seq:
 *     graph.include_subject?( subject )   -> true or false
 *
 *  Returns +true+ if the graph contains any statements with the specified +subject+.
 *
 */
static VALUE
rleaf_redleaf_graph_include_subject_p( VALUE self, VALUE subject ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *source;
	librdf_iterator *iter;
	VALUE rval = Qfalse;

	rleaf_log_with_context( self, "debug", "Checking for statements with %s as the subject",
		RSTRING_PTR(rb_inspect( subject )) );
	
	source = rleaf_value_to_subject_node( subject );
	iter = librdf_model_get_arcs_out( ptr->model, source );
	
	if ( !iter ) {
		librdf_free_node( source );
		rb_raise( rleaf_eRedleafError, "could not get arcs out for %s",
		          RSTRING_PTR(rb_inspect(subject)) );
	}

	/* If it's not empty, there was at least one matching statement. */
	if ( ! librdf_iterator_end(iter) ) rval = Qtrue;

	librdf_free_iterator( iter );
	librdf_free_node( source );
	
	return rval;
}


/*
 *  call-seq:
 *     graph.include_object?( object )   -> true or false
 *
 *  Returns +true+ if the graph contains any statements with the specified +object+.
 *
 */
static VALUE
rleaf_redleaf_graph_include_object_p( VALUE self, VALUE object ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	librdf_node *target;
	librdf_iterator *iter;
	VALUE rval = Qfalse;

	rleaf_log_with_context( self, "debug", "Checking for statements with %s as the object",
		RSTRING_PTR(rb_inspect( object )) );
	
	target = rleaf_value_to_object_node( object );
	iter = librdf_model_get_arcs_in( ptr->model, target );
	
	if ( !iter ) {
		librdf_free_node( target );
		rb_raise( rleaf_eRedleafError, "could not get arcs out for %s",
		          RSTRING_PTR(rb_inspect(object)) );
	}

	/* If it's not empty, there was at least one matching statement. */
	if ( ! librdf_iterator_end(iter) ) rval = Qtrue;

	librdf_free_iterator( iter );
	librdf_free_node( target );
	
	return rval;
}


/*
 *  call-seq:
 *     model.sync
 *
 *  Synchronise the model to the model implementation.
 *
 */
static VALUE
rleaf_redleaf_graph_sync( VALUE self ) {
	rleaf_GRAPH *ptr = rleaf_get_graph( self );
	
	rleaf_log_with_context( self, "debug", "Syncing graph 0x%x.", self );

	if ( librdf_model_sync(ptr->model) != 0 ) return Qfalse;
	return Qtrue;
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
	rb_define_singleton_method( rleaf_cRedleafGraph, "serializers", 
		rleaf_redleaf_graph_s_serializers, 0 );

	/* Public instance methods */
	rb_define_method( rleaf_cRedleafGraph, "initialize", rleaf_redleaf_graph_initialize, -1 );
	rb_define_method( rleaf_cRedleafGraph, "dup", rleaf_redleaf_graph_dup, 0 );

	rb_define_method( rleaf_cRedleafGraph, "store", rleaf_redleaf_graph_store, 0 );
	rb_define_method( rleaf_cRedleafGraph, "store=", rleaf_redleaf_graph_store_eq, 1 );

	rb_define_method( rleaf_cRedleafGraph, "size", rleaf_redleaf_graph_size, 0 );
	rb_define_alias ( rleaf_cRedleafGraph, "length", "size" );
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

	rb_define_method( rleaf_cRedleafGraph, "serialized_as", rleaf_redleaf_graph_serialized_as, 1 );

	rb_define_method( rleaf_cRedleafGraph, "execute_query", rleaf_redleaf_graph_execute_query, -1 );
	
	rb_define_method( rleaf_cRedleafGraph, "subjects", rleaf_redleaf_graph_subjects, 2 );
	rb_define_method( rleaf_cRedleafGraph, "subject", rleaf_redleaf_graph_subject, 2 );
	rb_define_method( rleaf_cRedleafGraph, "predicates", rleaf_redleaf_graph_predicates, 2 );
	rb_define_method( rleaf_cRedleafGraph, "predicate", rleaf_redleaf_graph_predicate, 2 );
	rb_define_method( rleaf_cRedleafGraph, "objects", rleaf_redleaf_graph_objects, 2 );
	rb_define_method( rleaf_cRedleafGraph, "object", rleaf_redleaf_graph_object, 2 );

	rb_define_alias( rleaf_cRedleafGraph, "sources", "subjects" );
	rb_define_alias( rleaf_cRedleafGraph, "source", "subject" );
	rb_define_alias( rleaf_cRedleafGraph, "arcs", "predicates" );
	rb_define_alias( rleaf_cRedleafGraph, "arc", "predicate" );
	rb_define_alias( rleaf_cRedleafGraph, "targets", "objects" );
	rb_define_alias( rleaf_cRedleafGraph, "target", "object" );

	rb_define_method( rleaf_cRedleafGraph, "predicates_about", 
		rleaf_redleaf_graph_predicates_about, 1 );
	rb_define_alias( rleaf_cRedleafGraph, "arcs_out", "predicates_about" );

	rb_define_method( rleaf_cRedleafGraph, "has_predicate_about?", 
		rleaf_redleaf_graph_has_predicate_about_p, 2 );
	rb_define_alias( rleaf_cRedleafGraph, "has_arcs_out?", "has_predicate_about?" );
	rb_define_alias( rleaf_cRedleafGraph, "arcs_out?", "has_predicate_about?" );

	rb_define_method( rleaf_cRedleafGraph, "predicates_entailing", 
		rleaf_redleaf_graph_predicates_entailing, 1 );
	rb_define_alias( rleaf_cRedleafGraph, "arcs_in", "predicates_entailing" );

	rb_define_method( rleaf_cRedleafGraph, "has_predicate_entailing?", 
		rleaf_redleaf_graph_has_predicate_entailing_p, 2 );
	rb_define_alias( rleaf_cRedleafGraph, "has_arcs_in?", "has_predicate_entailing?" );
	rb_define_alias( rleaf_cRedleafGraph, "arcs_in?", "has_predicate_entailing?" );

	rb_define_method( rleaf_cRedleafGraph, "include_subject?",
		rleaf_redleaf_graph_include_subject_p, 1 );
	rb_define_method( rleaf_cRedleafGraph, "include_object?",
		rleaf_redleaf_graph_include_object_p, 1 );

	rb_define_method( rleaf_cRedleafGraph, "sync", rleaf_redleaf_graph_sync, 0 );

	/*
	
	FUTURE WORK (0.2.x):
	
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

	-- #context { block }
	int librdf_model_context_add_statement(librdf_model* model, librdf_node* context, librdf_statement* statement)
	int librdf_model_context_add_statements(librdf_model* model, librdf_node* context, librdf_stream* stream)
	int librdf_model_context_remove_statement(librdf_model* model, librdf_node* context, librdf_statement* statement)
	int librdf_model_context_remove_statements(librdf_model* model, librdf_node* context)
	librdf_stream* librdf_model_context_as_stream(librdf_model* model, librdf_node* context)
	int librdf_model_contains_context( librdf_model *model, librdf_node *context );
	librdf_stream* librdf_model_find_statements_in_context( librdf_model *model, librdf_statement *statement, librdf_node *context_node );

	*/
}

