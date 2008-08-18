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


/* --------------------------------------------------
 *	Memory-management functions
 * -------------------------------------------------- */

/*
 * Allocation function
 */
static librdf_statement *rleaf_statement_alloc() {
	librdf_statement *ptr = librdf_new_statement( rleaf_rdf_world );
	rleaf_log( "debug", "initialized a librdf_statement <%p>", ptr );
	return ptr;
}


/*
 * GC Mark function
 */
static void rleaf_statement_gc_mark( librdf_statement *ptr ) {
		rleaf_log( "debug", "in mark function for RedLeaf::Statement %p", ptr );
	
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
static void rleaf_statement_gc_free( librdf_statement *ptr ) {
	if ( ptr ) {
		rleaf_log( "debug", "in free function of Redleaf::Statement <%p>", ptr );
		librdf_free_statement( ptr );
	}
	
	else {
		rleaf_log( "warn", "not freeing an uninitialized Redleaf::Statement" );
	}
}


/*
 * Object validity checker. Returns the data pointer.
 */
static librdf_statement *check_statement( VALUE self ) {
	rleaf_log( "debug", "checking a Redleaf::Statement object (%d).", self );
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
static librdf_statement *get_statement( VALUE self ) {
	librdf_statement *ptr = check_statement( self );

	rleaf_log( "debug", "fetching a Statement (%p).", ptr );
	if ( !ptr )
		rb_raise( rb_eRuntimeError, "uninitialized Statement" );

	return ptr;
}


/*
 * Convert the given librdf_node to a Ruby object and return it as a VALUE.
 */
static VALUE rleaf_librdf_node_to_value( librdf_node *node ) {
	librdf_node_type nodetype = librdf_node_get_type( node );

	switch( nodetype ) {
		
		/* URI */
		case LIBRDF_NODE_TYPE_RESOURCE:
		break;

	  	case LIBRDF_NODE_TYPE_LITERAL:
		break;
		
	  	case LIBRDF_NODE_TYPE_BLANK:
		break;
		
		default:
		rb_fatal( "Unknown node type %d encountered when converting a node.", nodetype );
	}

	return Qnil;
}

/*
 * Convert the given Ruby +object+ to a librdf_node.
 */
static librdf_node *rleaf_value_to_librdf_node( VALUE object ) {
	librdf_node *node = librdf_new_node_from_blank_identifier( rleaf_rdf_world, NULL );
	
	return node;
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
static VALUE rleaf_redleaf_statement_s_allocate( VALUE klass ) {
	rleaf_log( "debug", "wrapping an uninitialized Redleaf::Statement pointer." );
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
static VALUE rleaf_redleaf_statement_initialize( int argc, VALUE *argv, VALUE self ) {
	if ( !check_statement(self) ) {
		librdf_statement *ptr;
	
		DATA_PTR( self ) = ptr = rleaf_statement_alloc();
		
	} else {
		rb_raise( rb_eRuntimeError,
				  "Cannot re-initialize a statement once it's been created." );
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
static VALUE rleaf_redleaf_statement_clear( VALUE self ) {
	librdf_statement *ptr = get_statement( self );

	librdf_statement_clear( ptr );

	return Qnil;
}


/*
 *  call-seq:
 *     statement.subject   -> URL or nil
 *
 *  Return the subject (node) of the statement.
 *
 */
static VALUE rleaf_redleaf_statement_subject( VALUE self ) {
	return Qnil;
}


/*
 *  call-seq:
 *     statement.predicate   -> URL
 *
 *  Return the predicate (arc) of the statement.
 *
 */
static VALUE rleaf_redleaf_statement_predicate( VALUE self ) {
	return Qnil;
}


/*
 *  call-seq:
 *     statement.object   -> URL or nil
 *
 *  Return the object (node) of the statement.
 *
 */
static VALUE rleaf_redleaf_statement_object( VALUE self ) {
	return Qnil;
}




/*
 * Redleaf Statement class
 */
void rleaf_init_redleaf_statement( void ) {
	rleaf_cRedleafStatement = rb_define_class_under( rleaf_mRedleaf, "Statement", rb_cObject );
	
	rleaf_log( "debug", "Initializing Redleaf::Statement" );
	
	rb_define_alloc_func( rleaf_cRedleafStatement, rleaf_redleaf_statement_s_allocate );

	rb_define_method( rleaf_cRedleafStatement, "initialize", rleaf_redleaf_statement_initialize, -1 );
	rb_define_method( rleaf_cRedleafStatement, "clear", rleaf_redleaf_statement_clear, 0 );

	rb_define_method( rleaf_cRedleafStatement, "subject", rleaf_redleaf_statement_subject, 0 );
	rb_define_method( rleaf_cRedleafStatement, "predicate", rleaf_redleaf_statement_predicate, 0 );
	rb_define_method( rleaf_cRedleafStatement, "object", rleaf_redleaf_statement_object, 0 );

}

