/*
 * Demo of the librdf_parser_parse_string_into_model() function's return value
 * being '0' even on a parse error for most parsers.
 *
 * $Id$
 *
 * Author:
 *   Michael Granger <ged@FaerieMUD.org>
 *
 * I compile it with:
 *   gcc -ggdb -Wall \
 *     -I/usr/local/include -I/usr/local/include/raptor2 -I/usr/local/include/rasqal \
 *     -L/usr/local/lib -lrdf -o parse_error parse_error.c
 */

#include <redland.h>
#include <stdio.h>

#define CONTEXT_URI "file:///tmp/error.turtle"

const char *levelnames[] = {
	"",
	"debug",
	"info",
	"warn",
	"error",
	"fatal",
};

const char *facilities[] = {
	"",
	"Concepts",
	"Digest",
	"Files",
	"Hash",
	"Init",
	"Iterator",
	"List",
	"Model",
	"Node",
	"Parser",
	"Query",
	"Serializer",
	"Statement",
	"Storage",
	"Stream",
	"URI",
	"UTF8",
	"Memory",
	"Raptor"
};


int logit( void *user_data, librdf_log_message *message )
{
	const char *level = levelnames[ librdf_log_message_level(message) ];
	const char *facility = facilities[ librdf_log_message_facility(message) ];

 	fprintf( stderr, "[%s] {%s} %s\n", level, facility, librdf_log_message_message(message) );

	return 1;
}

int main( void )
{
    librdf_world *world = librdf_new_world();
    librdf_storage *store = librdf_new_storage( world, "memory", NULL, "contexts='yes'" );
    librdf_model *model = librdf_new_model( world, store, NULL );
    librdf_uri *ctx_uri = librdf_new_uri( world, (unsigned char *)CONTEXT_URI );
	librdf_parser *parser = librdf_new_parser( world, "turtle", NULL, NULL );
	const unsigned char *turtle = "# prefix name must end in a :\n@prefix a <#> .\n";
	int rval = 0;

	librdf_world_set_logger( world, NULL, logit );

	rval = librdf_parser_parse_string_into_model( parser, turtle, ctx_uri, model );
    fprintf( stderr, "Return value: %d\n", rval );

	librdf_free_parser( parser );
	librdf_free_uri( ctx_uri );
	librdf_free_model( model );
    librdf_free_storage( store );
    librdf_free_world( world );

    return 0;
}


