/* 
 * Redleaf::Statement -- RDF statement class
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

VALUE rleaf_cRedleafStatement;


/* --------------------------------------------------------------
 * Predeclarations
 * -------------------------------------------------------------- */

static VALUE rleaf_redleaf_statement_s_allocate( VALUE );

static VALUE rleaf_redleaf_statement_subject_eq( VALUE, VALUE );
static VALUE rleaf_redleaf_statement_predicate_eq( VALUE, VALUE );
static VALUE rleaf_redleaf_statement_object_eq( VALUE, VALUE );


/* --------------------------------------------------
 *	Memory-management functions
 * -------------------------------------------------- */

/*
 * Allocation function
 */
static librdf_statement *
rleaf_statement_alloc() {
	librdf_statement *ptr = librdf_new_statement( rleaf_rdf_world );
	// rleaf_log( "debug", "initialized a librdf_statement <%p>", ptr );
	return ptr;
}


/*
 * GC Mark function
 */
static void 
rleaf_statement_gc_mark( librdf_statement *ptr ) {
	// rleaf_log( "debug", "in mark function for RedLeaf::Statement %p", ptr );
	
	if ( ptr ) {
		// rleaf_log( "debug", "marked" );
	}
	
	else {
		rleaf_log( "debug", "not marked" );
	}
}



/*
 * GC Free function
 */
static void 
rleaf_statement_gc_free( librdf_statement *ptr ) {
	if ( ptr && rleaf_rdf_world ) {
		// rleaf_log( "debug", "in free function of Redleaf::Statement <%p>", ptr );
		librdf_free_statement( ptr );
		ptr = NULL;
	}

	else {
		rleaf_log( "warn", "not freeing an uninitialized Redleaf::Statement" );
	}
}


/*
 * Object validity checker. Returns the data pointer.
 */
static librdf_statement *
check_statement( VALUE self ) {
	// rleaf_log_with_context( self, "debug", "checking a Redleaf::Statement object (%d).", self );
	Check_Type( self, T_DATA );

    if ( !IsStatement(self) ) {
		rb_raise( rb_eTypeError, "wrong argument type %s (expected Redleaf::Statement)",
				  rb_class2name(CLASS_OF( self )) );
    }
	
	return DATA_PTR( self );
}


/*
 * Fetch the data pointer and check it for sanity.
 */
librdf_statement *
rleaf_get_statement( VALUE self ) {
	librdf_statement *stmt = check_statement( self );

	// rleaf_log_with_context( self, "debug", "fetching a Statement <%p>.", stmt );
	if ( !stmt )
		rb_raise( rb_eRuntimeError, "uninitialized Statement" );

	return stmt;
}


/* --------------------------------------------------------------
 * Utility functions
 * -------------------------------------------------------------- */

/*
 * Copy the given +statement+ and create a new Redleaf::Statement to wrap it.
 */
VALUE
rleaf_librdf_statement_to_value( librdf_statement *statement ) {
	VALUE object = rleaf_redleaf_statement_s_allocate( rleaf_cRedleafStatement );
	librdf_statement *stmt = librdf_new_statement_from_statement( statement );
	
	DATA_PTR( object ) = stmt;
	return rb_funcall( object, rb_intern("initialize"), 0 );
}


/*
 * Convert the given object to a librdf_statement and return a pointer to it. The caller is
 * reponsible for managing the new statement and its nodes.
 */
librdf_statement *
rleaf_value_to_librdf_statement( VALUE object ) {
	librdf_node *subject_node = NULL, *predicate_node = NULL, *object_node = NULL;
	librdf_statement *stmt_copy = NULL;

	if ( TYPE(object) == T_ARRAY ) {
		rleaf_log( "debug", "creating a new librdf_statement from a triple" );

		if ( RARRAY(object)->len != 3 )
			rb_raise( rb_eArgError, "wrong number of elements for triple (%d for 3)",
			          RARRAY(object)->len );

		subject_node   = rleaf_value_to_subject_node( RARRAY(object)->ptr[0] );
		predicate_node = rleaf_value_to_predicate_node( RARRAY(object)->ptr[1] );
		object_node    = rleaf_value_to_object_node( RARRAY(object)->ptr[2] );

		stmt_copy = librdf_new_statement_from_nodes( rleaf_rdf_world, 
			subject_node, predicate_node, object_node );
	}
	
	else if ( rb_obj_is_kind_of(object, rleaf_cRedleafStatement) ) {
		rleaf_log( "debug", "extracting a copy of a librdf_statement from a %s",
		           rb_class2name(CLASS_OF(object)) );

		stmt_copy = librdf_new_statement_from_statement( check_statement(object) );
	}
	
	else {
		rb_raise( rb_eArgError, "can't convert a %s to a statement", 
		          rb_class2name(CLASS_OF(object)) );
	}
	
	if ( stmt_copy == NULL )
		rb_raise( rb_eRuntimeError, "failed to create a new librdf_statement from nodes" );

	return stmt_copy;
}


/* --------------------------------------------------------------
 * Class methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Statement.allocate   -> statement
 *
 *  Allocate a new Redleaf::Statement object.
 *
 */
static VALUE
rleaf_redleaf_statement_s_allocate( VALUE klass ) {
	return Data_Wrap_Struct( klass, rleaf_statement_gc_mark, rleaf_statement_gc_free, 0 );
}


/* --------------------------------------------------------------
 * Instance methods
 * -------------------------------------------------------------- */

/*
 *  call-seq:
 *     Redleaf::Statement.new()                               -> statement
 *     Redleaf::Statement.new( subject, predicate, object )   -> statement
 *
 *  Create a new Redleaf::Statement object. If the optional +subject+ (a URI or nil), 
 *  +predicate+ (a URI), and +object+ (a URI, nil, or any immediate Ruby object) are given, 
 *  the statement will be initialized with them.
 *
 */
static VALUE 
rleaf_redleaf_statement_initialize( int argc, VALUE *argv, VALUE self ) {
	if ( !check_statement(self) ) {
		librdf_statement *stmt;
		VALUE subject = Qnil, predicate = Qnil, object = Qnil;

		rb_scan_args( argc, argv, "03", &subject, &predicate, &object );

		DATA_PTR( self ) = stmt = rleaf_statement_alloc();
		
		if ( argc >= 1 ) rleaf_redleaf_statement_subject_eq( self, subject );
		if ( argc >= 2 ) rleaf_redleaf_statement_predicate_eq( self, predicate );
		if ( argc == 3 ) rleaf_redleaf_statement_object_eq( self, object );
	}

	return self;
}


/*
 *  call-seq:
 *     statement.clear   -> nil
 *
 *  Clear all nodes from the statement.
 *
 */
static VALUE 
rleaf_redleaf_statement_clear( VALUE self ) {
	librdf_statement *stmt = rleaf_get_statement( self );

	librdf_statement_clear( stmt );

	return Qnil;
}


/*
 *  call-seq:
 *     statement.subject   -> URI or nil
 *
 *  Return the subject (node) of the statement.
 *
 */
static VALUE 
rleaf_redleaf_statement_subject( VALUE self ) {
	librdf_statement *stmt = rleaf_get_statement( self );
	librdf_node *node;
	
	if ( (node = librdf_statement_get_subject( stmt )) == NULL )
		return Qnil;

	return rleaf_librdf_node_to_value( node );
}


/*
 *  call-seq:
 *     statement.subject= uri_or_nil
 *
 *  Set the subject (node) of the statement.
 *
 */
static VALUE 
rleaf_redleaf_statement_subject_eq( VALUE self, VALUE new_subject ) {
	librdf_node *node = NULL;
	librdf_statement *stmt = rleaf_get_statement( self );
	
	node = rleaf_value_to_subject_node( new_subject );
	librdf_statement_set_subject( stmt, node );

	return new_subject;
}


/*
 *  call-seq:
 *     statement.predicate   -> URI or nil
 *
 *  Return the predicate (node) of the statement.
 *
 */
static VALUE 
rleaf_redleaf_statement_predicate( VALUE self ) {
	librdf_statement *stmt = rleaf_get_statement( self );
	librdf_node *node;
	
	if ( (node = librdf_statement_get_predicate( stmt )) == NULL )
		return Qnil;

	return rleaf_librdf_node_to_value( node );
}


/*
 *  call-seq:
 *     statement.predicate= uri_or_nil
 *
 *  Set the predicate (node) of the statement.
 *
 */
static VALUE 
rleaf_redleaf_statement_predicate_eq( VALUE self, VALUE new_predicate ) {
	librdf_node *node = NULL;
	librdf_statement *stmt = rleaf_get_statement( self );
	
	node = rleaf_value_to_predicate_node( new_predicate );
	librdf_statement_set_predicate( stmt, node );

	return new_predicate;
}


/*
 *  call-seq:
 *     statement.object   -> URI or nil
 *
 *  Return the object (node) of the statement.
 *
 */
static VALUE 
rleaf_redleaf_statement_object( VALUE self ) {
	librdf_statement *stmt = rleaf_get_statement( self );
	librdf_node *node;
	
	if ( (node = librdf_statement_get_object( stmt )) == NULL )
		return Qnil;

	return rleaf_librdf_node_to_value( node );
}


/*
 *  call-seq:
 *     statement.object= uri_or_nil
 *
 *  Set the object (node) of the statement.
 *
 */
static VALUE 
rleaf_redleaf_statement_object_eq( VALUE self, VALUE new_object ) {
	librdf_node *node;
	librdf_statement *stmt = rleaf_get_statement( self );
	
	node = rleaf_value_to_object_node( new_object );
	librdf_statement_set_object( stmt, node );

	return new_object;
}


/* 
 * call-seq:
 *    statement.complete?   -> true or false
 * 
 * Check if statement is a complete and legal RDF triple. Checks that
 * all subject, predicate, object fields are present and they have the
 * allowed node types.
 * 
 */
static VALUE 
rleaf_redleaf_statement_complete_p( VALUE self ) {
	librdf_statement *stmt = rleaf_get_statement( self );
	
	if ( librdf_statement_is_complete(stmt) ) {
		return Qtrue;
	} else {
		return Qfalse;
	}
}


/* 
 * call-seq:
 *    statement.to_s   -> string
 * 
 * Format the librdf_statement as a string. 
 * 
 */
static VALUE 
rleaf_redleaf_statement_to_s( VALUE self ) {
	librdf_statement *stmt = rleaf_get_statement( self );
	unsigned char *string;
	VALUE rb_string;
	
	string = librdf_statement_to_string( stmt );
	rb_string = rb_str_new2( (char *)string );
	xfree( string );
	
	return rb_string;
}


/* 
 * call-seq:
 *    statement.eql?( other_statement )   -> true or false
 * 
 * Returns true if the receiver is equal to +other_statement+.
 * 
 */
static VALUE 
rleaf_redleaf_statement_eql_p( VALUE self, VALUE other ) {
	librdf_statement *stmt = rleaf_get_statement( self );
	librdf_statement *other_stmt;

	rleaf_log_with_context( self, "info", "Comparing %s with %s for equality.",
		RSTRING(rb_inspect(self))->ptr, RSTRING(rb_inspect(other))->ptr );

	if ( CLASS_OF(other) != CLASS_OF(self) ) return Qfalse;

	other_stmt = rleaf_get_statement( other );

	/* Statements with incomplete nodes can't be equal to any other statement */
	if ( !librdf_statement_is_complete(stmt) || !librdf_statement_is_complete(other_stmt) ) {
		rleaf_log_with_context( self, "debug", 
			"one of the statements is incomplete: returning false" );
		return Qfalse;
	}

	if ( librdf_statement_equals(stmt, other_stmt) ) {
		rleaf_log_with_context( self, "debug", "statements are equal: returning true" );
		return Qtrue;
	} else {
		rleaf_log_with_context( self, "debug", "statements are not equal: returning false" );
		return Qfalse;
	}
}


/* 
 * call-seq:
 *    statement === other_statement   -> true or false
 * 
 * Case equality: Returns true if the receiver matches +other_statement+, where some parts of the
 * receiving statement - subject, predicate or object - can be empty (NULL). Empty parts match 
 * against any value, parts with values must match exactly.
 * 
 */
static VALUE 
rleaf_redleaf_statement_threequal_op( VALUE self, VALUE other ) {
	librdf_statement *stmt = rleaf_get_statement( self );
	librdf_statement *other_stmt;

	if ( CLASS_OF(other) != CLASS_OF(self) ) return Qfalse;

	other_stmt = rleaf_get_statement( other );
	
	if ( librdf_statement_match(stmt, other_stmt) ) {
		return Qtrue;
	} else {
		return Qfalse;
	}
}


/*
 *  call-seq:
 *     marshal_dump   => string
 *
 *  (Marshal API) Serialize the object to a String.
 *
 */
static VALUE 
rleaf_redleaf_statement_marshal_dump( VALUE self ) {
	librdf_statement *stmt = rleaf_get_statement( self );
	unsigned char *buf = NULL;
	size_t buflen = librdf_statement_encode( stmt, NULL, 0 );

	buf = ALLOCA_N( unsigned char, buflen + 1 );
	librdf_statement_encode( stmt, buf, buflen );

	return rb_str_new( (char *)buf, buflen );
}


/*
 *  call-seq:
 *     marshal_load( data )
 *
 *  (Marshal API) Deserialize the object state in +data+ back into the receiver.
 *
 */
static VALUE 
rleaf_redleaf_statement_marshal_load( VALUE self, VALUE data ) {

	if ( !check_statement(self) ) {
		VALUE datastring = StringValue( data );
		librdf_statement *stmt;

		DATA_PTR( self ) = stmt = rleaf_statement_alloc();
		
		if ( librdf_statement_decode(stmt, (unsigned char *)RSTRING(datastring)->ptr,
		     RSTRING(datastring)->len) == 0 )
			rb_raise( rb_eRuntimeError, "librdf_statement_decode() failed." );
	
	} else {
		rb_raise( rb_eRuntimeError,
				  "Cannot load marshalled data into a statement once it's been created." );
	}

	return Qtrue;
}



/*
 * Redleaf Statement class
 */
void rleaf_init_redleaf_statement( void ) {
	rb_require( "redleaf/statement" );
	rleaf_cRedleafStatement = rb_define_class_under( rleaf_mRedleaf, "Statement", rb_cObject );
	
	rleaf_log( "debug", "Initializing Redleaf::Statement" );
	
	rb_define_alloc_func( rleaf_cRedleafStatement, rleaf_redleaf_statement_s_allocate );

	rb_define_method( rleaf_cRedleafStatement, "initialize", rleaf_redleaf_statement_initialize, -1 );

	rb_define_method( rleaf_cRedleafStatement, "clear", rleaf_redleaf_statement_clear, 0 );

	rb_define_method( rleaf_cRedleafStatement, "subject", rleaf_redleaf_statement_subject, 0 );
	rb_define_method( rleaf_cRedleafStatement, "subject=", rleaf_redleaf_statement_subject_eq, 1 );
	rb_define_method( rleaf_cRedleafStatement, "predicate", rleaf_redleaf_statement_predicate, 0 );
	rb_define_method( rleaf_cRedleafStatement, "predicate=", 
		rleaf_redleaf_statement_predicate_eq, 1 );
	rb_define_method( rleaf_cRedleafStatement, "object", rleaf_redleaf_statement_object, 0 );
	rb_define_method( rleaf_cRedleafStatement, "object=", rleaf_redleaf_statement_object_eq, 1 );

	rb_define_method( rleaf_cRedleafStatement, "complete?", rleaf_redleaf_statement_complete_p, 0 );

	rb_define_method( rleaf_cRedleafStatement, "to_s", rleaf_redleaf_statement_to_s, 0 );

	rb_define_method( rleaf_cRedleafStatement, "eql?", rleaf_redleaf_statement_eql_p, 1 );
	rb_define_alias( rleaf_cRedleafStatement, "==", "eql?" );
	rb_define_method( rleaf_cRedleafStatement, "===", rleaf_redleaf_statement_threequal_op, 1 );

	rb_define_method( rleaf_cRedleafStatement, "marshal_dump", 
		rleaf_redleaf_statement_marshal_dump, 0 );
	rb_define_method( rleaf_cRedleafStatement, "marshal_load", 
		rleaf_redleaf_statement_marshal_load, 1 );
	
}

