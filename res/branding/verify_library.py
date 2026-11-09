#!/usr/bin/env python3
"""Read only the public synchronous getters from the actual packaged FRB 1.80.1 library."""
import argparse,ctypes as c,json
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('library',type=Path);parser.add_argument('--edition',choices=['operator','customer'],default='operator');args=parser.parse_args()
class Object(c.Structure):pass
ObjectPointer=c.POINTER(Object)
class Array(c.Structure):_fields_=[('length',c.c_ssize_t),('values',c.POINTER(ObjectPointer))]
class TypedData(c.Structure):_fields_=[('kind',c.c_int32),('length',c.c_ssize_t),('values',c.POINTER(c.c_uint8))]
class Value(c.Union):
 _fields_=[('boolean',c.c_bool),('int32',c.c_int32),('int64',c.c_int64),('string',c.c_char_p),('array',Array),('typed',TypedData),('align',c.c_uint64*5)]
Object._fields_=[('kind',c.c_int32),('value',Value)]
assert c.sizeof(Object)==48
library=c.CDLL(str(args.library.resolve()))
free=library.free_WireSyncReturn;free.argtypes=[ObjectPointer];free.restype=None
def decode(pointer):
 obj=pointer.contents
 if obj.kind==0:return None
 if obj.kind==1:return bool(obj.value.boolean)
 if obj.kind==2:return int(obj.value.int32)
 if obj.kind==3:return int(obj.value.int64)
 if obj.kind==5:return obj.value.string.decode('utf-8')
 if obj.kind==6:
  array=obj.value.array;assert 0<=array.length<100
  return [decode(array.values[i]) for i in range(array.length)]
 if obj.kind==7:
  array=obj.value.typed;assert array.kind in [1,2,3] and 0<=array.length<10000
  return c.string_at(array.values,array.length).decode('utf-8')
 raise ValueError('Unexpected CObject kind: '+str(obj.kind))
def getter(name):
 function=getattr(library,'wire_'+name);function.argtypes=[];function.restype=ObjectPointer
 pointer=function()
 if not pointer:raise RuntimeError('Null result from '+name)
 try:
  result=decode(pointer)
  assert len(result)==2 and result[1] is True,(name,result)
  return result[0]
 finally:free(pointer)
internal='RustDeskCustomer' if args.edition=='customer' else 'RustDesk'
result={name:getter(name) for name in ['main_get_app_name_sync','is_disable_account','is_disable_ab']}
assert result['main_get_app_name_sync']==internal,result
for key in ['is_disable_account','is_disable_ab']:assert result[key] is True,result
result['main_get_app_display_name_sync']=getter('main_get_app_display_name_sync')
assert result['main_get_app_display_name_sync']==('远程连接（顾客版）' if args.edition=='customer' else '远程连接')
print(json.dumps({'file':str(args.library),'public_sync_getters_verified':True,**result},ensure_ascii=False))
