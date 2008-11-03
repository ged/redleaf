/*
 * Demo of the doubled-quotes problem with the JSON formatter for
 * query results in Redland 1.0.8.
 * $Id$
 * 
 * Author:
 *   Michael Granger <ged@FaerieMUD.org>
 * 
 * I compile it with:
 *   gcc -ggdb -I/usr/local/include -L/usr/local/lib -lrdf \
 *       -o test json_qr.c
 */

#include <redland.h>
#include <stdio.h>

#define DC_TITLE "http://purl.org/dc/elements/1.1/title"
#define JSON_URI "http://www.w3.org/2001/sw/DataAccess/json-sparql/"

int main( void ) {
    librdf_world *world = librdf_new_world();
    librdf_storage *store = librdf_new_storage( world, "memory", NULL, "contexts='yes'" );
    librdf_model *model = librdf_new_model( world, store, NULL );
    librdf_node *subject, *predicate, *object;
    librdf_query *query;
    librdf_query_results *results;
    librdf_uri *json_uri = librdf_new_uri( world, (unsigned char *)JSON_URI );
    unsigned char *json;
    
    subject = librdf_new_node_from_uri_string( world, (unsigned char *)"urn:isbn:0156031196" );
    predicate = librdf_new_node_from_uri_string( world, (unsigned char *)DC_TITLE );
    object = librdf_new_node_from_literal( world, (unsigned char *)"Winter's Tale", NULL, 0 );
    
    librdf_model_add( model, subject, predicate, object );
    query = librdf_new_query( world, "sparql", NULL, (unsigned char *)"SELECT ?s ?p ?o WHERE { ?s ?p ?o }", NULL );
    results = librdf_model_query_execute( model, query );
    json = librdf_query_results_to_string( results, json_uri, NULL );

    fprintf( stderr, "Results:\n%s", json );

    free( json );
    librdf_free_query_results( results );
    librdf_free_query( query );
    librdf_free_node( object );
    librdf_free_node( predicate );
    librdf_free_node( subject );
	librdf_free_model( model );
    librdf_free_storage( store );
    librdf_free_world( world );
    
    return 0;
}


