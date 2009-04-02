/* 
 * Node utility functions
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


/*
 * Convert the given resource librdf_node to a Ruby URI object and return it.
 */
VALUE 
rleaf_librdf_uri_node_to_object( librdf_node *node ) {
	VALUE node_object = Qnil;
	librdf_uri *uri;
	const unsigned char *uristring = NULL;

	if ( !librdf_node_is_resource(node) )
		rb_raise( rleaf_eRedleafError, "cannot convert a non-resource to a URI" );
	if ( (uri = librdf_node_get_uri( node )) == NULL )
		rb_raise( rleaf_eRedleafError, "unable to fetch a uri from resource node" );
	if ( (uristring = librdf_uri_as_string( uri )) == NULL )
		rb_raise( rleaf_eRedleafError, "unable to fetch a string from uri" );

	// rleaf_log( "debug", "converting %s to a URI object", uristring );
	node_object = rb_funcall( rleaf_rb_cURI, rb_intern("parse"), 1,
		rb_str_new2((const char *)uristring) );
	
	return node_object;
}


/*
 * Convert the given Ruby URI object to a librdf_uri and return it. The caller must
 * free the returned pointer.
 * 
 * The caller is responsible for catching the ArgumentError that results if the
 * +uriobj+ can't be converted.
 */
librdf_uri *
rleaf_object_to_librdf_uri( VALUE uriobj ) {
	librdf_uri *uri;
	VALUE uristring = rb_obj_as_string( uriobj );
	
	uri = librdf_new_uri( rleaf_rdf_world, (const unsigned char *)StringValuePtr(uristring) );
	if ( !uri )
		rb_raise( rleaf_eRedleafError, "Couldn't make a librdf_uri out of %s", 
			RSTRING_PTR(rb_inspect( uriobj )) );

	return uri;
}


/*
 * Convert the given literal librdf_node to a Ruby object and return it.
 */
VALUE 
rleaf_librdf_literal_node_to_object( librdf_node *node ) {
	VALUE node_object = Qnil;
	librdf_uri *uri;
	VALUE literalstring, uristring;

	uri = librdf_node_get_literal_value_datatype_uri( node );
	literalstring = rb_str_new2( (char *)librdf_node_get_literal_value(node) );

	/* Plain literal -> String */
	if ( uri == NULL ) {
		// rleaf_log( "debug", "Converting plain literal %s to a String.", literalstring );
		node_object = literalstring;
	}
	
	/* Typed literal */
	else {
		uristring = rb_str_new2( (char *)librdf_uri_to_string(uri) );
		node_object = rb_funcall( rleaf_mRedleafNodeUtils, 
			rb_intern("make_typed_literal_object"), 2, uristring, literalstring );
	}
	
	return node_object;
}


/*
 * Convert the given librdf_node to a Ruby object and return it as a VALUE.
 */
VALUE 
rleaf_librdf_node_to_value( librdf_node *node ) {
	VALUE node_object = Qnil;
	librdf_node_type nodetype = LIBRDF_NODE_TYPE_UNKNOWN;
	unsigned char *bnode_idname = NULL;
	ID bnode_id;

	if ( !node ) rb_fatal( "NULL pointer given to rleaf_librdf_node_to_value()" );
	nodetype = librdf_node_get_type( node );
	
	switch( nodetype ) {

	  /* URI node => URI */
	  case LIBRDF_NODE_TYPE_RESOURCE:
		node_object = rleaf_librdf_uri_node_to_object( node );
		break;

	  /* Blank node => nil */
	  case LIBRDF_NODE_TYPE_BLANK:
		bnode_idname = librdf_node_get_blank_identifier( node );
		if ( bnode_idname ) {
			bnode_id = rb_intern( (char *)bnode_idname );
			node_object = ID2SYM( bnode_id );
		} else {
			node_object = Qnil;
		}
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
librdf_node *
rleaf_value_to_librdf_node( VALUE object ) {
	VALUE str, typeuristr, converted_pair;
	librdf_uri *typeuri;
	ID id;
	
	/* :TODO: how to set language? is_xml flag? */

	// rleaf_log( "debug", "Converting %s to a librdf_node.", RSTRING_PTR(rb_inspect( object )) );
	switch( TYPE(object) ) {
		
		/* nil -> bnode */
		case T_NIL:
		return NULL;
		
		case T_SYMBOL:
		id = SYM2ID( object );
		if ( id == rleaf_anon_bnodeid ) {
			return librdf_new_node_from_blank_identifier( rleaf_rdf_world, NULL );
		} else {
			return librdf_new_node_from_blank_identifier( rleaf_rdf_world, (unsigned char *)rb_id2name(id) );
		}
		
		/* String -> plain literal */
		case T_STRING:
		return librdf_new_node_from_literal( rleaf_rdf_world, (unsigned char *)RSTRING_PTR(object), NULL, 0 );
		break;
		
		/* Float -> xsd:float */
		case T_FLOAT:
		str = rb_obj_as_string( object );
		typeuri = XSD_FLOAT_TYPE;
		break;

		/* Bignum -> xsd:decimal */
		case T_BIGNUM:
		str = rb_obj_as_string( object );
		typeuri = XSD_DECIMAL_TYPE;
		break;

		/* Fixnum -> xsd:integer */
		case T_FIXNUM:
		str = rb_obj_as_string( object );
		typeuri = XSD_INTEGER_TYPE;
		break;
		
		/* TrueClass/FalseClass -> xsd:boolean */
		case T_TRUE:
		case T_FALSE:
		str = rb_obj_as_string( object );
		typeuri = XSD_BOOLEAN_TYPE;
		break;
		
		/* URI -> librdf_uri */
		case T_OBJECT:
		if ( IsURI(object) || IsNamespace(object) ) {
			// rleaf_log( "debug", "Converting %s object to librdf_uri node", 
			//            rb_obj_classname(object) );
			str = rb_obj_as_string( object );
			return librdf_new_node_from_uri_string( rleaf_rdf_world, 
				(unsigned char*)RSTRING_PTR(str) );
		}
		/* fallthrough */
		
		/* Delegate anything else to Redleaf::NodeUtils.make_object_typed_literal */
		default:
		converted_pair = rb_funcall( rleaf_mRedleafNodeUtils, 
			rb_intern("make_object_typed_literal"), 1, object );
		str = rb_ary_entry( converted_pair, 0 );
		typeuristr = rb_obj_as_string( rb_ary_entry(converted_pair, 1) );
		typeuri = librdf_new_uri( rleaf_rdf_world, (unsigned char*)RSTRING_PTR(typeuristr) );
	}
	
	return librdf_new_node_from_typed_counted_literal( 
		rleaf_rdf_world,
		(unsigned char *)RSTRING_PTR(str),
		RSTRING_LEN(str),
		NULL,
		0,
		typeuri );
}


/*
 * Check the given Ruby VALUE for suitability as the subject of a triple and return a 
 * librdf_node pointer to an equivalent node if it is suitable. Raises a
 * ArgumentError if it is not.
 * 
 * The caller is responsible for catching the ArgumentError that results if the
 * +subject+ is invalid.
 */
librdf_node *
rleaf_value_to_subject_node( VALUE subject ) {
	librdf_node *node = NULL;
	
	if ( subject == Qnil || TYPE(subject) == T_SYMBOL || IsURI(subject) || IsNamespace(subject) ) {
		node = rleaf_value_to_librdf_node( subject );
	} 
	
	else if ( TYPE(subject) == T_STRING ) {
		node = librdf_new_node_from_uri_string( rleaf_rdf_world,
			(unsigned char *)RSTRING_PTR(subject) );
	}
	
	else {
		rb_raise( rb_eArgError, "Subject must be blank or a URI" );
	}

	return node;
}


/*
 * Check the given Ruby VALUE for suitability as the predicate of a triple and return a 
 * librdf_node pointer to an equivalent node if it is suitable. Raises a
 * ArgumentError if it is not.
 * 
 * The caller is responsible for catching the ArgumentError that results if the
 * +predicate+ is invalid.
 */
librdf_node *
rleaf_value_to_predicate_node( VALUE predicate ) {
	librdf_node *node = NULL;

	if ( predicate == Qnil || IsURI(predicate) || IsNamespace(predicate) ) {
		node = rleaf_value_to_librdf_node( predicate );
	} 
	
	else if ( TYPE(predicate) == T_STRING ) {
		node = librdf_new_node_from_uri_string( rleaf_rdf_world,
			(unsigned char *)RSTRING_PTR(predicate) );
	}

	else {
		rb_raise( rb_eArgError, "Predicate must be a URI" );
	}

	return node;
}


/*
 * Check the given Ruby VALUE for suitability as the object of a triple and return a 
 * librdf_node pointer to an equivalent node if it is suitable. Raises a
 * ArgumentError if it is not.
 * 
 * The caller is responsible for catching the ArgumentError that results if the
 * +object+ is invalid.
 */
librdf_node *
rleaf_value_to_object_node( VALUE object ) {
	return rleaf_value_to_librdf_node( object );
}


