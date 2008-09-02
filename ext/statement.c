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

static VALUE rleaf_redleaf_statement_subject_eq( VALUE, VALUE );
static VALUE rleaf_redleaf_statement_predicate_eq( VALUE, VALUE );
static VALUE rleaf_redleaf_statement_object_eq( VALUE, VALUE );


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
		
		ptr = NULL;
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
	librdf_statement *stmt = check_statement( self );

	rleaf_log( "debug", "fetching a Statement <%p>.", stmt );
	if ( !stmt )
		rb_raise( rb_eRuntimeError, "uninitialized Statement" );

	return stmt;
}


/*
 * Convert the given resource librdf_node to a Ruby URI object and return it.
 */
static VALUE rleaf_librdf_uri_node_to_object( librdf_node *node ) {
	VALUE node_object = Qnil;
	librdf_uri *uri;
	const unsigned char *uristring;

	rleaf_log( "debug", "trying to convert node %p to a URI object", node );
	if ( (uri = librdf_node_get_uri( node )) == NULL )
		rb_fatal( "Null pointer from node_get_uri in rleaf_librdf_node_to_uri" );
	uristring = librdf_uri_as_string( uri );

	rleaf_log( "debug", "converting %s to a URI object", uristring );
	node_object = rb_funcall( rb_cURI, rb_intern("parse"), 1,
		rb_str_new2((const char *)uristring) );
	
	return node_object;
}


/*
 * Convert the given literal librdf_node to a Ruby object and return it.
 */
static VALUE rleaf_librdf_literal_node_to_object( librdf_node *node ) {
	VALUE node_object = Qnil;
	librdf_uri *uri;
	VALUE literalstring, uristring;

	uri = librdf_node_get_literal_value_datatype_uri( node );
	literalstring = rb_str_new2( (char *)librdf_node_get_literal_value(node) );

	/* Plain literal -> String */
	if ( uri == NULL ) {
		rleaf_log( "debug", "Converting plain literal %s to a String.", literalstring );
		node_object = literalstring;
	}
	
	/* Typed literal */
	else {
		uristring = rb_str_new2( (char *)librdf_uri_to_string(uri) );
		node_object = rb_funcall( rleaf_cRedleafStatement, 
			rb_intern("make_typed_literal_object"), 2, uristring, literalstring );
	}
	
	return node_object;
}


/*
 * Convert the given librdf_node to a Ruby object and return it as a VALUE.
 */
static VALUE rleaf_librdf_node_to_value( librdf_node *node ) {
	VALUE node_object = Qnil;
	librdf_node_type nodetype = librdf_node_get_type( node );

	switch( nodetype ) {

	  /* URI node => URI */
	  case LIBRDF_NODE_TYPE_RESOURCE:
		node_object = rleaf_librdf_uri_node_to_object( node );
		break;

	  /* Blank node => nil */
	  case LIBRDF_NODE_TYPE_BLANK:
		node_object = Qnil;
		break;

	  /* Literal => <ruby object> */
	  case LIBRDF_NODE_TYPE_LITERAL:
		node_object = rleaf_librdf_literal_node_to_object( node );
		break;
		
	  default:
		rb_fatal( "Unknown node type %d encountered when converting a node.", nodetype );
	}

	return node_object;
}

/*
 * Convert the given Ruby +object+ (VALUE) to a librdf_node.
 */
static librdf_node *rleaf_value_to_librdf_node( VALUE object ) {
	VALUE str, typeuristr, converted_pair;
	VALUE inspected_object = rb_inspect( object );
	librdf_uri *typeuri;
	
	/* :TODO: how to set language? is_xml flag? */

	rleaf_log( "debug", "Converting %s to a librdf_node.", RSTRING(inspected_object)->ptr );
	switch( TYPE(object) ) {
		
		/* nil -> bnode */
		case T_NIL:
		return librdf_new_node_from_blank_identifier( rleaf_rdf_world, NULL );
		
		/* String -> plain literal */
		case T_STRING:
		str = object;
		typeuri = XSD_STRING_TYPE;
		break;
		
		/* Float -> xsd:float */
		case T_FLOAT:
		str = rb_funcall( object, rb_intern("to_s"), 0 );
		typeuri = XSD_FLOAT_TYPE;
		break;

		/* Bignum -> xsd:decimal */
		case T_BIGNUM:
		str = rb_funcall( object, rb_intern("to_s"), 0 );
		typeuri = XSD_DECIMAL_TYPE;
		break;

		/* Fixnum -> xsd:integer */
		case T_FIXNUM:
		str = rb_funcall( object, rb_intern("to_s"), 0 );
		typeuri = XSD_INTEGER_TYPE;
		break;
		
		/* TrueClass/FalseClass -> xsd:boolean */
		case T_TRUE:
		case T_FALSE:
		str = rb_funcall( object, rb_intern("to_s"), 0 );
		typeuri = XSD_BOOLEAN_TYPE;
		break;
		
		/* URI -> librdf_uri */
		case T_OBJECT:
		if ( rb_obj_is_kind_of(object, rb_cURI) ) {
			rleaf_log( "debug", "Converting URI object to librdf_uri node" );
			str = rb_funcall( object, rb_intern("to_s"), 0 );
			return librdf_new_node_from_uri_string( rleaf_rdf_world, (unsigned char*)RSTRING(str)->ptr );
		}
		/* fallthrough */
		
		/* Delegate anything else to Redleaf::object_to_node */
		default:
		converted_pair = rb_funcall( rleaf_cRedleafStatement, rb_intern("object_to_node"), 1, object );
		str = rb_ary_entry( converted_pair, 0 );
		typeuristr = rb_ary_entry( converted_pair, 1 );
		typeuri = librdf_new_uri( rleaf_rdf_world, (unsigned char*)RSTRING(typeuristr)->ptr );
	}
	
	return librdf_new_node_from_typed_counted_literal( 
		rleaf_rdf_world,
		(unsigned char *)RSTRING(str)->ptr,
		RSTRING(str)->len,
		NULL,
		0,
		typeuri );
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
		librdf_statement *stmt;
		VALUE subject = Qnil, predicate = Qnil, object = Qnil;

		// if ( argc > 3 ) rb_raise( rb_eArgError, "wrong number of arguments (%d for 3)", argc );
	
		DATA_PTR( self ) = stmt = rleaf_statement_alloc();
		rb_scan_args( argc, argv, "03", &subject, &predicate, &object );
		
		if ( argc >= 1 ) rleaf_redleaf_statement_subject_eq( self, subject );
		if ( argc >= 2 ) rleaf_redleaf_statement_predicate_eq( self, predicate );
		if ( argc == 3 ) rleaf_redleaf_statement_object_eq( self, object );
		
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
	librdf_statement *stmt = get_statement( self );

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
static VALUE rleaf_redleaf_statement_subject( VALUE self ) {
	librdf_statement *stmt = get_statement( self );
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
static VALUE rleaf_redleaf_statement_subject_eq( VALUE self, VALUE new_subject ) {
	librdf_node *node;
	librdf_statement *stmt = get_statement( self );
	
	if ( new_subject == Qnil || rb_obj_is_kind_of(new_subject, rb_cURI) ) {
		node = rleaf_value_to_librdf_node( new_subject );
		librdf_statement_set_subject( stmt, node );
	} else {
		rb_raise( rb_eArgError, "Subject must be blank or a URI" );
	}

	return new_subject;
}


/*
 *  call-seq:
 *     statement.predicate   -> URI or nil
 *
 *  Return the predicate (node) of the statement.
 *
 */
static VALUE rleaf_redleaf_statement_predicate( VALUE self ) {
	librdf_statement *stmt = get_statement( self );
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
static VALUE rleaf_redleaf_statement_predicate_eq( VALUE self, VALUE new_predicate ) {
	librdf_node *node;
	librdf_statement *stmt = get_statement( self );
	
	if ( rb_obj_is_kind_of(new_predicate, rb_cURI) ) {
		node = rleaf_value_to_librdf_node( new_predicate );
		librdf_statement_set_predicate( stmt, node );
	} else {
		rb_raise( rb_eArgError, "Predicate must be a URI" );
	}

	return new_predicate;
}


/*
 *  call-seq:
 *     statement.object   -> URI or nil
 *
 *  Return the object (node) of the statement.
 *
 */
static VALUE rleaf_redleaf_statement_object( VALUE self ) {
	librdf_statement *stmt = get_statement( self );
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
static VALUE rleaf_redleaf_statement_object_eq( VALUE self, VALUE new_object ) {
	librdf_node *node;
	librdf_statement *stmt = get_statement( self );
	
	node = rleaf_value_to_librdf_node( new_object );
	librdf_statement_set_object( stmt, node );

	return new_object;
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
	rb_define_method( rleaf_cRedleafStatement, "predicate=", rleaf_redleaf_statement_predicate_eq, 1 );
	rb_define_method( rleaf_cRedleafStatement, "object", rleaf_redleaf_statement_object, 0 );
	rb_define_method( rleaf_cRedleafStatement, "object=", rleaf_redleaf_statement_object_eq, 1 );


	
}

