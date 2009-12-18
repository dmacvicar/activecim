
#include "sfcc.h"

VALUE mSfcc;
VALUE mSfccCmci;
VALUE mSfccCmpi;

void Init_sfcc()
{
  mSfcc= rb_define_module("Sfcc");
  mSfccCmci= rb_define_module_under("Sfcc", "Cmci");
  mSfccCmpi= rb_define_module_under("Sfcc", "Cmpi");

  init_cmci_client();
  init_cmpi_object_path();
}
