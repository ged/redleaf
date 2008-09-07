/* 
 * Redleaf -- an RDF library for Ruby
 * $Id$
 * 
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

#ifndef __REDLEAF_H__
#define __REDLEAF_H__

#include <stdio.h>
#include <string.h>

#include <raptor.h>
#include <rasqal.h>
#include <redland.h>

#include "ruby.h"


/* --------------------------------------------------------------
 * Globals
 * -------------------------------------------------------------- */

extern VALUE rleaf_mRedleaf;
extern VALUE rleaf_cRedleafGraph;
extern VALUE rleaf_cRedleafStatement;
extern VALUE rleaf_cRedleafParser;

extern VALUE rb_cURI;

extern librdf_world *rleaf_rdf_world;

extern const librdf_uri *rleaf_xsd_string_typeuri;
extern const librdf_uri *rleaf_xsd_float_typeuri;
extern const librdf_uri *rleaf_xsd_decimal_typeuri;
extern const librdf_uri *rleaf_xsd_integer_typeuri;
extern const librdf_uri *rleaf_xsd_boolean_typeuri;

extern ID rleaf_anon_bnodeid;


/* --------------------------------------------------------------
 * Macros
 * -------------------------------------------------------------- */
#define IsStatement( obj ) rb_obj_is_kind_of( (obj), rleaf_cRedleafStatement )
#define IsGraph( obj ) rb_obj_is_kind_of( (obj), rleaf_cRedleafGraph )
#define IsStore( obj ) rb_obj_is_kind_of( (obj), rleaf_cRedleafStore )


#define XSD_URI_BASE "http://www.w3.org/TR/xmlschema-2/#"
#define XSD_URI(s) XSD_URI_BASE s

#define XSD_STRING_TYPE  (librdf_new_uri_from_uri( (librdf_uri *)rleaf_xsd_string_typeuri ))
#define XSD_FLOAT_TYPE   (librdf_new_uri_from_uri( (librdf_uri *)rleaf_xsd_float_typeuri ))
#define XSD_DECIMAL_TYPE (librdf_new_uri_from_uri( (librdf_uri *)rleaf_xsd_decimal_typeuri ))
#define XSD_INTEGER_TYPE (librdf_new_uri_from_uri( (librdf_uri *)rleaf_xsd_integer_typeuri ))
#define XSD_BOOLEAN_TYPE (librdf_new_uri_from_uri( (librdf_uri *)rleaf_xsd_boolean_typeuri ))

#define STRINGIFY(a) #a

/* --------------------------------------------------------------
 * Function declarations
 * -------------------------------------------------------------- */

#ifdef HAVE_STDARG_PROTOTYPES
#include <stdarg.h>
#define va_init_list(a,b) va_start(a,b)
void rleaf_log_with_context( VALUE context, const char *level, const char *fmt, ... );
void rleaf_log( const char *level, const char *fmt, ... );
#else
#include <varargs.h>
#define va_init_list(a,b) va_start(a)
void rleaf_log_with_context( VALUE context, const char *level, const char *fmt, va_dcl );
void rleaf_log( const char *level, const char *fmt, va_dcl );
#endif


/* --------------------------------------------------------------
 * Initializers
 * -------------------------------------------------------------- */

void Init_redleaf_ext( void );

void rleaf_init_redleaf_store( void );
void rleaf_init_redleaf_graph( void );
void rleaf_init_redleaf_parser( void );
void rleaf_init_redleaf_statement( void );

#endif

