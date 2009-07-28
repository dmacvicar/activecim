#include "cimc/cimc.h"
//#include "cimc/cmci.h"
//#include <cimc/native.h>

#include "ruby.h"
#include "client.h"

#include <unistd.h>
#include <stdlib.h>

static VALUE cClient;	/* the client class */

/* convert char* to string VALUE */
VALUE
makestring( char *s )
{
    if (s) return rb_str_new2( s );
    return Qnil;
}

/* convert symbol or string VALUE to char* */
char *
as_string( VALUE v )
{
    char *s;
    if ( SYMBOL_P( v ) ) {
	ID id = SYM2ID( v );
	s = rb_id2name( id );
    }
    else {
	s = StringValuePtr( v );
    }
    return s;
}

typedef struct client_wrapper_struct
{
  CIMCEnv *ce;
  CIMCClient *client;
  char* scheme;
  char* cim_host;
  char* cim_host_userid;
  char* cim_host_passwd;
  char* cim_host_port;
  int rc;
  char *msg;
} client_wrapper_t;

static client_wrapper_t *
client_unwrap( VALUE self )
{
    client_wrapper_t *wrapper;
    Data_Get_Struct( self, client_wrapper_t, wrapper );

    return wrapper;
}

static void
client_mark( client_wrapper_t *r )
{
    /* see client_allocate() */
}

static void
client_free( client_wrapper_t *wrapper )
{
  if(wrapper->client) wrapper->client->ft->release(wrapper->client);
  if(wrapper->ce) wrapper->ce->ft->release(wrapper->ce);
  free( wrapper );
  printf("done enum free\n");

}

/*
 * call-seq:
 *   Client.new( scheme, host, port=8889, path="wsman", user="", password="" ) -> Client
 *   Client.new( url ) -> Client
 *
 */

static VALUE
client_initialize( int argc, VALUE *argv, VALUE self )
{
  CIMCStatus status;

  client_wrapper_t *wrapper = client_unwrap( self );
  //wrapper->ce = NewCIMCEnv("SfcbLocal",0,&(wrapper->rc),&(wrapper->msg));

  wrapper->ce = NewCIMCEnv("XML", 0, &(wrapper->rc), &(wrapper->msg));
  if ( wrapper->ce == NULL )
  {
    rb_raise(rb_eRuntimeError, "NewCIMCEnv error message = [%s] \n", wrapper->msg);
  }
  
  if (argc < 1) {
    rb_raise( rb_eArgError, "Client.new needs URI or scheme, host" );
  }
  else if (argc == 1) {   /* only uri given ? */
    rb_raise( rb_eArgError, "URI for Client.new NOT IMPLEMENTED" );
  }
  else for(;;) {
    wrapper->scheme = StringValuePtr( *argv++ );
    wrapper->cim_host = StringValuePtr( *argv++ );
    argc -= 2;
    if( argc-- == 0 ) break;
    //wrapper->cim_host_port = FIX2INT( *argv++ );
    wrapper->cim_host_port = StringValuePtr( *argv++ );
    if( argc-- == 0 ) break;
    wrapper->cim_host_userid = StringValuePtr( *argv++ );
    if( argc-- == 0 ) break;
    wrapper->cim_host_passwd = StringValuePtr( *argv++ );
    break;
  }

  wrapper->client = wrapper->ce->ft->connect(wrapper->ce, wrapper->cim_host , "http", wrapper->cim_host_port, wrapper->cim_host_userid, wrapper->cim_host_passwd , &status);

  if (!wrapper->client) {
    rb_raise( rb_eRuntimeError, "Client.new failed: %d", status.rc );
  }
  //wrapper->transport = rb_funcall( cTransport, rb_intern( "new" ), 1, self );
  return self;

  if(status.msg) CMRelease(status.msg);
}

static VALUE
client_allocate( VALUE klass )
{
    // create struct
    client_wrapper_t *wrapper = (client_wrapper_t *)calloc( 1, sizeof( client_wrapper_t ) );
    //wrapper->transport = Qnil;

    // wrap and return struct
    return Data_Wrap_Struct( klass, client_mark, client_free, wrapper );
}

static VALUE
client_each_class_name( VALUE self )
{
  CIMCObjectPath *op;
  CIMCEnumeration *enm;
  CIMCString *path;
  CIMCData data;
  CIMCStatus status;

  client_wrapper_t *wrapper = client_unwrap( self );

  op = wrapper->ce->ft->newObjectPath(wrapper->ce, "root/cimv2", NULL, &status);
  enm = wrapper->client->ft->enumClassNames(wrapper->client, op, 0, &status);

  if (!status.rc) {
    while (enm->ft->hasNext(enm, NULL)) {
        data = enm->ft->getNext(enm, NULL);
        op = data.value.ref;
        path = op->ft->toString(op, NULL);
        
        rb_yield(makestring(path->ft->getCharPtr(path, NULL)));
    }
  } else {
    printf("ERROR received from enumClassNames status.rc = %d\n",status.rc) ;
    if(wrapper->msg)
      printf("ERROR msg = %s\n", wrapper->msg) ;
  }

  printf("done enum\n");

  //if(enm) enm->ft->release(enm);
  //if(op) op->ft->release(op);

  printf("done enum release\n");

  return Qnil;
}

void Init_sfcc()
{
  VALUE mActiveCim;
  mActiveCim = rb_define_module("Sfcc");
  cClient = rb_define_class_under(mActiveCim, "Client", rb_cObject);
  rb_define_alloc_func( cClient, client_allocate ); 
  rb_define_method( cClient, "initialize", client_initialize, -1 );
  rb_define_method( cClient, "each_class_name", client_each_class_name, 0 );
}

