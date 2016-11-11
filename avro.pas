unit avro;

interface

const
{$IfDef UNIX}
  AvroLibraryName = 'avro.so';
{$Else}
    AvroLibraryName = 'libavro.dll';
{$EndIf}

type
 size_t = LongWord;
 int32_t = Integer;
 uint32_t = UInt32;
 int64_t = Int64;
 int = Integer;
 int8_t = ShortInt;
 float = single;
avro_type_t = (
	AVRO_STRING,
	AVRO_BYTES,
	AVRO_INT32,
	AVRO_INT64,
	AVRO_FLOAT,
	AVRO_DOUBLE,
	AVRO_BOOLEAN,
	AVRO_NULL,
	AVRO_RECORD,
	AVRO_ENUM,
	AVRO_FIXED,
	AVRO_MAP,
	AVRO_ARRAY,
	AVRO_UNION,
	AVRO_LINK
);


  avro_class_t = (AVRO_SCHEMA, AVRO_DATUM);

 avro_obj_t  = record
	&type: avro_type_t;
	class_type: avro_class_t;
	refcount: Integer;
 end;

 pavro_datum = ^avro_obj_t;
 pavro_schema = ^avro_obj_t;
 avro_schema_error_t_ = record

 end;
 pavro_schema_error = ^avro_schema_error_t_;

 avro_reader_t_ = record

 end;
 pavro_reader = ^avro_reader_t_;

 avro_writer_t_  = record

 end;
 pavro_writer = ^avro_writer_t_;

 avro_file_reader_t_ = record

 end;
 avro_file_reader_t = avro_file_reader_t_;
 pavro_file_reader = ^avro_file_reader_t;

 avro_file_writer_t_  = record

 end;
 avro_file_writer_t = avro_file_writer_t_;
 pavro_file_writer = ^avro_file_writer_t;

 pavro_wrapped_buffer = ^avro_wrapped_buffer;

 avro_wrapped_buffer = record
   buf: Pointer;
   size: size_t;
   user_data: Pointer;
   free: procedure(self: pavro_wrapped_buffer); cdecl;
   copy: function(dest: pavro_wrapped_buffer; const src: pavro_wrapped_buffer; offset: size_t; length: size_t): int; cdecl;
   slice: function(self: pavro_wrapped_buffer; offset: size_t; length: size_t): int; cdecl;
 end;


 pavro_value_iface = ^avro_value_iface_t;

 avro_value = record
	iface: pavro_value_iface;
	self: pointer;
 end;
 avro_value_t = avro_value;
 pavro_value = ^avro_value_t;

 avro_value_iface_t = record
   incref_iface: function(iface: pavro_value_iface): pavro_value_iface; cdecl;
   decref_iface: procedure(iface: pavro_value_iface); cdecl;
   incref: procedure(value: pavro_value); cdecl;
   decref: procedure(value: pavro_value); cdecl;
   reset: function(iface: pavro_value_iface; self: Pointer): int; cdecl;
   get_type: function(iface: pavro_value_iface; const self: Pointer): avro_type_t; cdecl;
   get_schema: function(iface: pavro_value_iface; const self: Pointer): pavro_schema; cdecl;
   get_boolean: function(const iface: pavro_value_iface; const self: Pointer; var &out: int): int; cdecl;
   get_bytes: function(const iface: pavro_value_iface; const self: Pointer; var buf: PAnsiChar; var size: size_t): int; cdecl;
   grab_bytes: function(const iface: pavro_value_iface; const self: Pointer; dest: pavro_wrapped_buffer): int; cdecl;
   get_double:function(const iface: pavro_value_iface; const self: Pointer; var &out: double): int; cdecl;
   get_float: function(const iface: pavro_value_iface; const self: Pointer; var &out: float): int; cdecl;
   get_int: function(const iface: pavro_value_iface; const self: Pointer; var &out:int32_t): int; cdecl;
   get_long: function(const iface: pavro_value_iface; const self: Pointer; var &out: int64_t): int; cdecl;
   get_null: function(const iface: pavro_value_iface; const self: Pointer): int; cdecl;

   set_boolean: function(const iface: pavro_value_iface; const self: Pointer; val: int): int; cdecl;
   set_bytes: function(const iface: pavro_value_iface; const self: Pointer; buf: PAnsiChar; size: size_t): int; cdecl;
   give_bytes: function(const iface: pavro_value_iface; const self: Pointer; buf: pavro_wrapped_buffer): int; cdecl;
   set_double: function(const iface: pavro_value_iface; const self: Pointer; val: double): int; cdecl;
   set_float: function(const iface: pavro_value_iface; const self: Pointer; val: float): int; cdecl;
   set_int: function(const iface: pavro_value_iface; const self: Pointer; val: int32_t): int; cdecl;
   set_long: function(const iface: pavro_value_iface; const self: Pointer; val: int64_t): int; cdecl;
   set_null: function(const iface: pavro_value_iface; const self: Pointer): int; cdecl;

   set_string: function(const iface: pavro_value_iface; const self: Pointer; const str: PAnsiChar): int; cdecl;
   set_string_len: function(const iface: pavro_value_iface; const self: Pointer; const str: PAnsiChar; size: size_t): int; cdecl;
   give_string_len: function(const iface: pavro_value_iface; const self: Pointer; buf: pavro_wrapped_buffer): int; cdecl;

   set_enum: function(const iface: pavro_value_iface; const self: Pointer; val: int): int; cdecl;
   set_fixed: function(const iface: pavro_value_iface; const self: Pointer; buf: Pointer; size: size_t): int; cdecl;
   give_fixed: function(const iface: pavro_value_iface; const self: Pointer; buf: pavro_wrapped_buffer): int; cdecl;

   get_size: function(const iface: pavro_value_iface; const self: Pointer; var size: size_t): int; cdecl;

   {
    * For arrays and maps, returns the element with the given
    * index.  (For maps, the "index" is based on the order that the
    * keys were added to the map.)  For records, returns the field
    * with that index in the schema.
    *
    * For maps and records, the name parameter (if given) will be
    * filled in with the key or field name of the returned value.
    * For arrays, the name parameter will always be ignored.
    }
   get_by_index: function(const iface: pavro_value_iface; const self: Pointer; index: size_t; child: pavro_value; var name: PAnsiChar): int; cdecl;

   {
    * For maps, returns the element with the given key.  For
    * records, returns the element with the given field name.  If
    * index is given, it will be filled in with the numeric index
    * of the returned value.
    }
   get_by_name: function(const iface: pavro_value_iface; const self: Pointer; const name: PAnsiChar; child: pavro_value; var index: size_t): int; cdecl;

   { Discriminant of current union value }
   get_discriminant: function(const iface: pavro_value_iface; const self: Pointer; var &out: int): int; cdecl;
   { Current union value }
   get_current_branch: function(const iface: pavro_value_iface; const self: Pointer; branch: pavro_value): int; cdecl;

   {-------------------------------------------------------------
    * Compound value setters
    }

   {
    * For all of these, the value class should know which class to
    * use for its children.
    }

   { Creates a new array element. }
   append: function(const iface: pavro_value_iface; const self: Pointer; child_out: pavro_value; var new_index: size_t): int; cdecl;

   { Creates a new map element, or returns an existing one. }
   add: function(const iface: pavro_value_iface; const self: Pointer; const key: PAnsiChar; child: pavro_value; var index: size_t; var is_new: int): int; cdecl;

   { Select a union branch. }
   set_branch: function(const iface: pavro_value_iface; const self: Pointer; discriminant: int; branch: pavro_value): int; cdecl;

 end;

 pavro_consumer_t = ^avro_consumer_t;
 avro_consumer_t = record
	{**
	 * The schema of the data that this consumer expects to process.
	 *}
	schema: pavro_schema;
	{**
	 * Called when this consumer is freed.  This function should
	 * free any additional resources acquired by a consumer
	 * subclass.
	 *}
	free: procedure(consumer: pavro_consumer_t); cdecl;
	{ PRIMITIVE VALUES }

	{*
	 * Called when a boolean value is encountered.
	 }

  boolean_value: function(consumer: pavro_consumer_t; value: int; user_data: pointer): int; cdecl;

	{*
	 * Called when a bytes value is encountered. The @ref value
	 * pointer is only guaranteed to be valid for the duration of
	 * the callback function.  If you need to save the data for
	 * processing later, you must copy it into another buffer.
	 }
  bytes_value: function(consumer: pavro_consumer_t; const value: pointer; value_len: size_t; user_data: pointer): int; cdecl;

	{*
	 * Called when a double value is encountered.
	 }
  double_value: function(consumer: pavro_consumer_t; value: double; user_data: pointer): int; cdecl;

	{*
	 * Called when a float value is encountered.
	 }
  float_value: function(consumer: pavro_consumer_t; value: single; user_data: pointer): int; cdecl;

	{*
	 * Called when an int value is encountered.
	 }
  int_value: function(consumer: pavro_consumer_t; value: int32_t; user_data: pointer): int; cdecl;
	{*
	 * Called when a long value is encountered.
	 }
  long_value: function(consumer: pavro_consumer_t; value: int64_t; user_data: pointer): int; cdecl;

	{*
	 * Called when a null value is encountered.
	 }
  null_value: function(consumer: pavro_consumer_t; user_data: pointer): int; cdecl;

	{*
	 * Called when a string value is encountered.  The @ref value
	 * pointer will point at UTF-8 encoded data.  (If the data
	 * you're representing isn't a UTF-8 Unicode string, you
	 * should use the bytes type.)	The @ref value_len parameter
	 * gives the length of the data in bytes, not in Unicode
	 * characters.	The @ref value pointer is only guaranteed to
	 * be valid for the duration of the callback function.	If you
	 * need to save the data for processing later, you must copy
	 * it into another buffer.
	 }
  string_value: function(consumer: pavro_consumer_t; value: pointer; value_len: size_t; user_data: pointer): int; cdecl;
	{ COMPOUND VALUES }

	{*
	 * Called when the beginning of an array block is encountered.
	 * The @ref block_count parameter will contain the number of
	 * elements in this block.
	 }

  array_start_block: function(consumer: pavro_consumer_t; is_first_block: int; block_count: UInt32; user_data: pointer): int; cdecl;

	{*
	 * Called before each individual element of an array is
	 * processed.  The index of the current element is passed into
	 * the callback.  The callback should fill in @ref
	 * element_consumer and @ref element_user_data with the consumer
	 * and <code>user_data</code> pointer to use to process the
	 * element.
	 }
  array_element: function(consumer: pavro_consumer_t; index: UInt32; var element_consumer: pavro_consumer_t; var element_user_data: pointer; user_data: pointer): int; cdecl;

	{*
	 * Called when an enum value is encountered.
	 }
  enum_value: function(consumer: pavro_consumer_t; value: int; user_data: pointer): int; cdecl;

	{*
	 * Called when a fixed value is encountered.  The @ref value
	 * pointer is only guaranteed to be valid for the duration of
	 * the callback function.  If you need to save the data for
	 * processing later, you must copy it into another buffer.
	 }
  fixed_value: function(consumer: pavro_consumer_t; value: pointer; value_len: size_t; user_data: pointer): int; cdecl;

	{*
	 * Called when the beginning of a map block is encountered.
	 * The @ref block_count parameter will contain the number of
	 * elements in this block.
	 }
  map_start_block: function(consumer: pavro_consumer_t; is_first_block: int; block_count: UInt32; user_data: pointer): int; cdecl;

	{*
	 * Called before each individual element of a map is
	 * processed.  The index and key of the current element is
	 * passed into the callback.  The key is only guaranteed to be
	 * valid for the duration of the map_element_start callback,
	 * and the map's subschema callback.  If you need to save it for
	 * later use, you must copy the key into another memory
	 * location.  The callback should fill in @ref value_consumer
	 * and @ref value_user_data with the consumer and
	 * <code>user_data</code> pointer to use to process the value.
	 }
  map_element: function(consumer: pavro_consumer_t; index: uint32; key: PAnsiChar; var value_consumer: pavro_consumer_t;
    var value_user_data: pointer; user_data: pointer): int; cdecl;

	{*
	 * Called when the beginning of a record is encountered.
	 }
  record_start: function(consumer: pavro_consumer_t; user_data: pointer): int; cdecl;

	{*
	 * Called before each individual field of a record is
	 * processed.  The index and name of the current field is
	 * passed into the callback.  The name is only guaranteed to
	 * be valid for the duration of the record_field_start
	 * callback, and the field's subschema callback.  If you need to
	 * save it for later use, you must copy the key into another
	 * memory location.  The callback should fill in @ref
	 * field_consumer and @ref field_user_data with the consumer
	 * <code>user_data</code> pointer to use to process the field.
	 }
  record_field: function(consumer: pavro_consumer_t; index: uint32; var field_consumer: pavro_consumer_t; var field_user_data: pointer; user_data: pointer): int; cdecl;

	{*
	 * Called when a union value is encountered.  The callback
	 * should fill in @ref branch_consumer and @ref branch_user_data
	 * with the consumer <code>user_data</code> pointer to use to
	 * process the branch.
	 }
  union_branch: function(consumer: pavro_consumer_t; discriminant: uint32; var branch_consumer: pavro_consumer_t; var branch_user_data: pointer; user_data: pointer): int; cdecl;
 end;


{basics.h}
function avro_schema_string: pavro_schema; cdecl; external AvroLibraryName name 'avro_schema_string';
function avro_schema_bytes: pavro_schema; cdecl; external AvroLibraryName name 'avro_schema_bytes';
function avro_schema_int: pavro_schema; cdecl; external AvroLibraryName name 'avro_schema_int';
function avro_schema_long: pavro_schema; cdecl; external AvroLibraryName name 'avro_schema_long';
function avro_schema_float: pavro_schema; cdecl; external AvroLibraryName name 'avro_schema_float';
function avro_schema_double: pavro_schema; cdecl; external AvroLibraryName name 'avro_schema_double';
function avro_schema_boolean: pavro_schema; cdecl; external AvroLibraryName name 'avro_schema_boolean';
function avro_schema_null: pavro_schema; cdecl; external AvroLibraryName name 'avro_schema_null';
function avro_schema_record (const name: PAnsiChar; const space: PAnsiChar): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_record_field_get(const &record: pavro_schema; const field_name: PAnsiChar): pavro_schema; cdecl; external AvroLibraryName;

{schema.h}
function avro_schema_record_field_name (const schema: pavro_schema; index: Integer): PAnsiChar; cdecl;  external AvroLibraryName;
function avro_schema_record_field_get_index(const schema: pavro_schema; const field_name: PAnsiChar): Integer; cdecl; external AvroLibraryName;
function avro_schema_record_field_get_by_index(const &record: pavro_schema; index: integer): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_record_field_append(const &record: pavro_schema; const field_name: PAnsiChar; const &type: pavro_schema ): Integer; cdecl; external AvroLibraryName;
function avro_schema_record_size(const &record: pavro_schema ): size_t; cdecl; external AvroLibraryName;
function avro_schema_enum(const name: PAnsiChar): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_enum_ns(const name: PAnsiChar; const space: AnsiString): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_enum_get(const enump: pavro_schema; index: integer): PAnsiChar; cdecl; external AvroLibraryName;
function avro_schema_enum_get_by_name(const enump: pavro_schema; const symbol_name: PAnsiChar): Integer; cdecl; external AvroLibraryName;
function avro_schema_enum_symbol_append(const enump: pavro_schema; const symbol: PAnsiChar): Integer; cdecl; external AvroLibraryName;
function avro_schema_fixed(const name: PAnsiChar; const len: Int64): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_fixed_ns(const name: PAnsiChar; const space: PAnsiChar; const len: Int64): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_fixed_size(const fixed: pavro_schema): Int64; cdecl; external AvroLibraryName;
function avro_schema_map(const values: pavro_schema): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_map_values(map: pavro_schema): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_array(const items: pavro_schema ): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_array_items(&array: pavro_schema): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_union: pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_union_size(const union_schema: pavro_schema): size_t; cdecl; external AvroLibraryName;
function avro_schema_union_append(const union_schema: pavro_schema; const schema: pavro_schema): integer; cdecl; external AvroLibraryName;
function avro_schema_union_branch(union_schema: pavro_schema; branch_index: Integer): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_union_branch_by_name(union_schema: pavro_schema; var branch_index: Integer; const name: PAnsiChar): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_link(schema: pavro_schema): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_link_target(schema: pavro_schema): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_from_json(const jsontext: PAnsiChar; unused1: int32_t; schema: pavro_schema; var unused2: pavro_schema_error): integer; cdecl; external AvroLibraryName;
{ jsontext does not need to be NUL terminated.  length must *NOT*
 * include the NUL terminator, if one is present. }
function avro_schema_from_json_length(const jsontext: PAnsiChar; length: size_t; var schema: pavro_schema): int; cdecl; external AvroLibraryName;
{* A helper macro for loading a schema from a string literal.  The
 * literal must be declared as a char[], not a char *, since we use the
 * sizeof operator to determine its length. *}
function avro_schema_from_json_literal(json: PAnsiChar; var schema: pavro_schema): int; inline;
function avro_schemao_specific(schema: pavro_schema; const prefix: PAnsiChar): int; cdecl; external AvroLibraryName;
function avro_schema_get_subschema(const schema: pavro_schema;  const name: PAnsiChar): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_name(const schema: pavro_schema): PAnsiChar; cdecl; external AvroLibraryName;
function avro_schema_namespace(const schema: pavro_schema): PAnsiChar; cdecl; external AvroLibraryName;
function avro_schemaype_name(const schema: pavro_schema): PAnsiChar; cdecl; external AvroLibraryName;
function avro_schema_copy(schema: pavro_schema): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_equal(a, b: pavro_schema): int ; cdecl; external AvroLibraryName;
function avro_schema_incref(schema: pavro_schema): pavro_schema; cdecl; external AvroLibraryName;
function avro_schema_decref(schema: pavro_schema): int; cdecl; external AvroLibraryName;
function avro_schema_match(schema: pavro_schema;  readers_schema: pavro_schema): int; cdecl; external AvroLibraryName;


procedure avro_consumer_free(consumer: pavro_consumer_t); cdecl; external AvroLibraryName;
function avro_resolver_new(writer_schema: pavro_schema;reader_schema: pavro_schema): pavro_consumer_t; cdecl; external AvroLibraryName;
function avro_consume_binary(reader: pavro_reader; consumer: pavro_consumer_t; ud: pointer): int; cdecl; external AvroLibraryName;

{io.h}
function avro_reader_file(var fp: Pointer): pavro_reader; cdecl; external AvroLibraryName;
function avro_reader_file_fp(var fp: Pointer; should_close: int): pavro_reader; cdecl; external AvroLibraryName;
function avro_writer_file(var fp: Pointer): pavro_writer; cdecl; external AvroLibraryName;
function avro_writer_file_fp(var fp: Pointer; should_close: int): pavro_writer; cdecl; external AvroLibraryName;
function avro_reader_memory(const buf: PAnsiChar; len: int64_t): pavro_reader cdecl; external AvroLibraryName;
function avro_writer_memory(const buf: PAnsiChar; len: int64_t): pavro_writer; cdecl; external AvroLibraryName;
procedure avro_reader_memory_set_source(reader: pavro_reader; const buf: PAnsiChar; len: int64_t); cdecl; external AvroLibraryName;
procedure avro_writer_memory_set_dest(writer: pavro_writer; const buf: PAnsiChar; len: int64_t); cdecl; external AvroLibraryName;

function avro_read(reader: pavro_reader; buf: pointer; len: int64_t): int; cdecl; external AvroLibraryName;
function avro_skip(reader: pavro_reader; len: int64_t): int; cdecl; external AvroLibraryName;
function avro_write(writer: pavro_writer; buf: pointer; len :int64_t): int; cdecl; external AvroLibraryName;

procedure avro_reader_reset(reader: pavro_reader); cdecl; external AvroLibraryName;
procedure avro_writer_reset(writer: pavro_writer); cdecl; external AvroLibraryName;

function avro_writer_tell(writer: pavro_writer): int64_t; cdecl; external AvroLibraryName;
procedure avro_writer_flush(writer: pavro_writer); cdecl; external AvroLibraryName;

procedure avro_writer_dump(writer: pavro_writer; var fp: Pointer); cdecl; external AvroLibraryName;
procedure avro_reader_dump(reader: pavro_reader; var fp: Pointer); cdecl; external AvroLibraryName;

function avro_reader_is_eof(reader: pavro_reader): int;  cdecl; external AvroLibraryName;

procedure avro_reader_free(reader: pavro_reader); cdecl; external AvroLibraryName;
procedure avro_writer_free(writer: pavro_writer); cdecl; external AvroLibraryName;

function avro_schema_to_json(const schema: pavro_schema; &out: pavro_writer): int; cdecl; external AvroLibraryName;

{*
 * Reads a binary-encoded Avro value from the given reader object,
 * storing the result into dest.
 *}

function avro_value_read(reader: pavro_reader; dest: pavro_value): int; cdecl; external AvroLibraryName;

{
 * Writes a binary-encoded Avro value to the given writer object.
 }

function avro_value_write(writer: pavro_writer; src: pavro_value): int; cdecl; external AvroLibraryName;

{
 * Returns the size of the binary encoding of the given Avro value.
 }

function avro_value_sizeof(src: pavro_value; var size: size_t): int; cdecl; external AvroLibraryName;
function avro_file_writer_create(const path: PAnsiChar; schema: pavro_schema; writer: pavro_file_writer): int; cdecl; external AvroLibraryName;
function avro_file_writer_create_fp(var fp: Pointer; const path: PAnsiChar; should_close: int; schema: pavro_schema; var writer: pavro_file_writer): int; cdecl; external AvroLibraryName;
function avro_file_writer_create_with_codec(const path: PAnsiChar; schema: pavro_schema;
  var writer: pavro_file_writer; const codec: PAnsiChar; block_size: size_t): int; cdecl; external AvroLibraryName;
function avro_file_writer_create_with_codec_fp(var fp: Pointer; const path: AnsiChar; should_close: int;
				schema: pavro_schema; var writer: pavro_file_writer;
                                const codec: PAnsiChar; block_size: size_t): int; cdecl; external AvroLibraryName;
function avro_file_writer_open(const path: PAnsiChar; var writer: pavro_file_writer): int; cdecl; external AvroLibraryName;
function avro_file_writer_open_bs(const path: PAnsiChar; var writer: pavro_file_writer; block_size: size_t): int; cdecl; external AvroLibraryName;
function avro_file_reader(const path: PAnsiChar; var reader: pavro_file_reader): int; cdecl; external AvroLibraryName;
function avro_file_reader_fp(var fp: Pointer; const path: PAnsiChar; should_close: int; var reader: pavro_file_reader): int; cdecl; external AvroLibraryName;
function avro_file_reader_get_writer_schema(reader: pavro_file_reader): pavro_schema; cdecl; external AvroLibraryName;
function avro_file_writer_sync(writer: pavro_file_writer): int; cdecl; external AvroLibraryName;
function avro_file_writer_flush(writer: pavro_file_writer): int; cdecl; external AvroLibraryName;
function avro_file_writer_close(writer: pavro_file_writer): int; cdecl; external AvroLibraryName;
function avro_file_reader_close(reader: pavro_file_reader): int; cdecl; external AvroLibraryName;
function avro_file_reader_read_value(reader: pavro_file_reader; var dest: pavro_value): int; cdecl; external AvroLibraryName;
function avro_file_writer_append_value(writer: pavro_file_writer; src: pavro_value): int; cdecl; external AvroLibraryName;
function avro_file_writer_append_encoded(writer: pavro_file_writer; const buf: Pointer; len: int64_t): int; cdecl; external AvroLibraryName;

{
 * Legacy avro_datum_t API
 }

function avro_read_data(reader: pavro_reader; writer_schema: pavro_schema; reader_schema: pavro_schema;
   var datum: pavro_datum): int; cdecl; external AvroLibraryName;
function avro_skip_data(reader: pavro_reader; writer_schema: pavro_schema): int; cdecl; external AvroLibraryName;
function avro_write_data(writer: pavro_writer;  writer_schema: pavro_schema; datum: pavro_datum): int; cdecl; external AvroLibraryName;
function avro_size_data(writer: pavro_writer; writer_schema: pavro_schema ; datum: pavro_datum): int64_t; cdecl; external AvroLibraryName;
function avro_file_writer_append(writer: pavro_file_writer; datum: pavro_datum): int; cdecl; external AvroLibraryName;
function avro_file_reader_read(reader: pavro_file_reader; readers_schema: pavro_schema;
   var datum: pavro_datum): int; cdecl; external AvroLibraryName;

type
  avro_free_func_t = procedure(ptr: Pointer; sz: size_t); cdecl;

procedure avro_alloc_free_func(ptr: pointer; sz: size_t); cdecl; external AvroLibraryName;

function avro_string_f(const str: PAnsiChar): pavro_datum; cdecl; external AvroLibraryName name 'avro_string';

function avro_givestring(const str:PAnsiChar; free: avro_free_func_t): pavro_datum; external AvroLibraryName name 'avro_givestring';
function avro_bytes_f(const buf: PAnsiChar; len: int64_t): pavro_datum; cdecl; external AvroLibraryName name 'avro_bytes';
function avro_givebytes(const buf: PAnsiChar; len: int64_t; free: avro_free_func_t): pavro_datum;  cdecl; external AvroLibraryName name 'avro_givebytes';
function avro_int32_f(i: int32_t): pavro_datum;  cdecl; external AvroLibraryName name 'avro_int32';
function avro_int64_f(l: int64_t): pavro_datum;  cdecl; external AvroLibraryName name 'avro_int64';
function avro_float_f(f: float): pavro_datum;  cdecl; external AvroLibraryName name 'avro_float';
function avro_double_f(d: double): pavro_datum;  cdecl; external AvroLibraryName name 'avro_double';
function avro_boolean_f(i: int8_t): pavro_datum; cdecl; external AvroLibraryName name 'avro_boolean';
function avro_null_f(): pavro_datum; cdecl; external AvroLibraryName name 'avro_null';
function avro_record_f(schema: pavro_schema): pavro_datum; cdecl; external AvroLibraryName name 'avro_record';
function avro_enum_f(schema: pavro_schema; i: int): pavro_datum; cdecl; external AvroLibraryName name 'avro_enum';
function avro_fixed_f(schema: pavro_schema; const bytes: PAnsiChar; const size: int64_t): pavro_datum; cdecl; external AvroLibraryName name 'avro_fixed';
function avro_givefixed(schema: pavro_schema; const bytes: PAnsiChar; const size: int64_t; free: avro_free_func_t): pavro_datum; cdecl; external AvroLibraryName name 'avro_givefixed';
function avro_map_f(schema: pavro_schema): pavro_datum; cdecl; external AvroLibraryName name 'avro_map';
function avro_array_f(schema: pavro_schema): pavro_datum; cdecl; external AvroLibraryName name 'avro_array';
function avro_union_f(schema: pavro_schema; discriminant: int64_t; const datum: pavro_datum): pavro_datum; cdecl; external AvroLibraryName name 'avro_union';
{*
 * Returns the schema that the datum is an instance of.
 }

function avro_datum_get_schema(const datum: pavro_datum): pavro_schema; cdecl; external AvroLibraryName;

{
 * Constructs a new avro_datum_t instance that's appropriate for holding
 * values of the given schema.
 }

function avro_datum_from_schema(const schema: pavro_schema): pavro_datum; cdecl; external AvroLibraryName;

{ getters }
function avro_string_get(datum: pavro_datum; var p: PAnsiChar): int; cdecl; external AvroLibraryName;
function avro_bytes_get(datum: pavro_datum; var bytes: PAnsiChar; var size: int64_t): int; cdecl; external AvroLibraryName;
function avro_int32_get(datum: pavro_datum; var i: int32_t): int; cdecl; external AvroLibraryName;
function avro_int64_get(datum: pavro_datum; var l: int64_t): int; cdecl; external AvroLibraryName;
function avro_float_get(datum: pavro_datum; var f: float): int; cdecl; external AvroLibraryName;
function avro_double_get(datum: pavro_datum; var d: Double): int; cdecl; external AvroLibraryName;
function avro_boolean_get(datum: pavro_datum; var i: int8_t): int; cdecl; external AvroLibraryName;

function avro_enum_get(const datum: pavro_datum): int; cdecl; external AvroLibraryName;
function avro_enum_get_name(const datum: pavro_datum): PAnsiChar; cdecl; external AvroLibraryName;
function avro_fixed_get(datum: pavro_datum; var bytes: PAnsiChar; var size: int64_t): int; cdecl; external AvroLibraryName;
function avro_record_get(const &record: pavro_datum; const field_name: PAnsiChar;  var value: pavro_datum): int; cdecl; external AvroLibraryName;


function avro_map_get(const datum: pavro_datum; const key: PAnsiChar; var value: pavro_datum): int; cdecl; external AvroLibraryName;
{
 * For maps, the "index" for each entry is based on the order that they
 * were added to the map.
 }
function avro_map_get_key(const datum: pavro_datum; index: int; var key: PAnsiChar): int; cdecl; external AvroLibraryName;
function avro_map_get_index(const datum: pavro_datum; const key: PAnsiChar; var index: int): int; cdecl; external AvroLibraryName;
function avro_map_size(const datum: pavro_datum): size_t; cdecl; external AvroLibraryName;
function avro_array_get(const datum: pavro_datum; index: int64_t; var value: pavro_datum): int; cdecl; external AvroLibraryName;
function avro_array_size(const datum: pavro_datum): size_t; cdecl; external AvroLibraryName;

{
 * These accessors allow you to query the current branch of a union
 * value, returning either the branch's discriminant value or the
 * avro_datum_t of the branch.  A union value can be uninitialized, in
 * which case the discriminant will be -1 and the datum NULL.
 }

function avro_union_discriminant(const datum: pavro_datum): int64_t; cdecl; external AvroLibraryName;
function avro_union_current_branch(datum: pavro_datum): pavro_datum; cdecl; external AvroLibraryName;

{ setters }
function avro_string_set(datum: pavro_datum; const p: PAnsiChar): int; cdecl; external AvroLibraryName;
function avro_givestring_set(datum: pavro_datum; const p: PAnsiChar; free: avro_free_func_t): int; cdecl; external AvroLibraryName;

function avro_bytes_set(datum: pavro_datum; const bytes: PAnsiChar; const size: int64_t): int; cdecl; external AvroLibraryName;
function avro_givebytes_set(datum: pavro_datum; const bytes: PAnsiChar;  const size: int64_t; free:	avro_free_func_t): int; cdecl; external AvroLibraryName;

function avro_int32_set(datum: pavro_datum; const i: int32_t): int; cdecl; external AvroLibraryName;
function avro_int64_set(datum: pavro_datum; const l: int64_t): int; cdecl; external AvroLibraryName;
function avro_float_set(datum: pavro_datum; const f: float): int; cdecl; external AvroLibraryName;
function avro_double_set(datum: pavro_datum; const d: double): int; cdecl; external AvroLibraryName;
function avro_boolean_set(datum: pavro_datum; const i: int8_t): int; cdecl; external AvroLibraryName;

function avro_enum_set(datum: pavro_datum; const symbol_value: int): int; cdecl; external AvroLibraryName;
function avro_enum_set_name(datum: pavro_datum; const symbol_name: PAnsiChar): int; cdecl; external AvroLibraryName;
function avro_fixed_set(datum: pavro_datum; const bytes: PAnsiChar; const size: int64_t): int; cdecl; external AvroLibraryName;
function avro_givefixed_set(datum: pavro_datum; const bytes: PAnsiChar; const size: int64_t; free: avro_free_func_t): int; cdecl; external AvroLibraryName;
function avro_record_set(&record: pavro_datum; const field_name: PAnsiChar; value: pavro_datum): int; cdecl; external AvroLibraryName;

function avro_map_set(map : pavro_datum; const key: PAnsiChar; value: pavro_datum): int; cdecl; external AvroLibraryName;
function avro_array_append_datum(array_datum: pavro_datum; datum: pavro_datum): int; cdecl; external AvroLibraryName;

{
 * This function selects the active branch of a union value, and can be
 * safely called on an existing union to change the current branch.  If
 * the branch changes, we'll automatically construct a new avro_datum_t
 * for the new branch's schema type.  If the desired branch is already
 * the active branch of the union, we'll leave the existing datum
 * instance as-is.  The branch datum will be placed into the "branch"
 * parameter, regardless of whether we have to create a new datum
 * instance or not.
 }

function avro_union_set_discriminant(unionp: pavro_datum; discriminant: int; var branch: pavro_datum): int; cdecl; external AvroLibraryName;

{*
 * Resets a datum instance.  For arrays and maps, this frees all
 * elements and clears the container.  For records and unions, this
 * recursively resets any child datum instances.
 }


function avro_datum_reset(value: pavro_datum): int; cdecl; external AvroLibraryName;

{ reference counting }
function avro_datum_incref(value: pavro_datum): pavro_datum; cdecl; external AvroLibraryName;
procedure avro_datum_decref(value: pavro_datum); cdecl; external AvroLibraryName;

procedure avro_datum_print(value: pavro_datum; var fp: Pointer); cdecl; external AvroLibraryName;

function avro_datum_equal(a: pavro_datum; b: pavro_datum): int; cdecl; external AvroLibraryName;

{
 * Returns a string containing the JSON encoding of an Avro value.  You
 * must free this string when you're done with it, using the standard
 * free() function.  (*Not* using the custom Avro allocator.)
 }

function avro_datum_to_json(const datum: pavro_datum; one_line: int; var json_str: PAnsiChar): int; cdecl; external AvroLibraryName;

function avro_schema_datum_validate(expected_schema: pavro_schema; datume: pavro_datum): int; cdecl; external AvroLibraryName;

{
 * An avro_value_t implementation for avro_datum_t objects.
 }
function avro_datum_class: pavro_value_iface; cdecl; external AvroLibraryName;

{
 * Creates a new avro_value_t instance for the given datum.
 }
function avro_datum_as_value(value: pavro_value; src: pavro_datum): int; cdecl; external AvroLibraryName;

function avro_strerror(): PAnsiChar; cdecl; external AvroLibraryName;


{value.h}
{*
 * Increments the reference count of a value instance.  Normally you
 * don't need to call this directly; you'll have a reference whenever
 * you create the value, and @ref avro_value_copy and @ref
 * avro_value_move update the reference counts correctly for you.
 }


procedure avro_value_incref(value: pavro_value); cdecl; external AvroLibraryName;

{*
 * Decremenets the reference count of a value instance, freeing it if
 * its reference count drops to 0.
 }

procedure avro_value_decref(value: pavro_value); cdecl; external AvroLibraryName;

{*
 * Copies a reference to a value.  This does not copy any of the data
 * in the value; you get two avro_value_t references that point at the
 * same underlying value instance.
 }

procedure avro_value_copy_ref(dest: pavro_value; const src: pavro_value); cdecl; external AvroLibraryName;

{*
 * Moves a reference to a value.  This does not copy any of the data in
 * the value.  The @ref src value is invalidated by this function; its
 * equivalent to the following:
 *
 * <code>
 * avro_value_copy_ref(dest, src);
 * avro_value_decref(src);
 * </code>
 }


procedure avro_value_move_ref(dest: pavro_value; src: pavro_value); cdecl; external AvroLibraryName;

{*
 * Compares two values for equality.  The two values don't need to have
 * the same implementation of the value interface, but they do need to
 * represent Avro values of the same schema.  This function ensures that
 * the schemas match; if you want to skip this check, use
 * avro_value_equal_fast.
 }

function avro_value_equal(val1: pavro_value; val2: pavro_value): int; cdecl; external AvroLibraryName;

{*
 * Compares two values for equality.  The two values don't need to have
 * the same implementation of the value interface, but they do need to
 * represent Avro values of the same schema.  This function assumes that
 * the schemas match; if you can't guarantee this, you should use
 * avro_value_equal, which compares the schemas before comparing the
 * values.
 }

function avro_value_equal_fast(val1: pavro_value; val2: pavro_value): int; cdecl; external AvroLibraryName;

{*
 * Compares two values using the sort order defined in the Avro
 * specification.  The two values don't need to have the same
 * implementation of the value interface, but they do need to represent
 * Avro values of the same schema.  This function ensures that the
 * schemas match; if you want to skip this check, use
 * avro_value_cmp_fast.
 }

function avro_value_cmp(val1: pavro_value; val2: pavro_value): int; cdecl; external AvroLibraryName;

{*
 * Compares two values using the sort order defined in the Avro
 * specification.  The two values don't need to have the same
 * implementation of the value interface, but they do need to represent
 * Avro values of the same schema.  This function assumes that the
 * schemas match; if you can't guarantee this, you should use
 * avro_value_cmp, which compares the schemas before comparing the
 * values.
 }

function avro_value_cmp_fast(val1: pavro_value; val2: pavro_value): int; cdecl; external AvroLibraryName;

{*
 * Copies the contents of src into dest.  The two values don't need to
 * have the same implementation of the value interface, but they do need
 * to represent Avro values of the same schema.  This function ensures
 * that the schemas match; if you want to skip this check, use
 * avro_value_copy_fast.
 }

function avro_value_copy(dest: pavro_value; const src: pavro_value): int; cdecl; external AvroLibraryName;

{*
 * Copies the contents of src into dest.  The two values don't need to
 * have the same implementation of the value interface, but they do need
 * to represent Avro values of the same schema.  This function assumes
 * that the schemas match; if you can't guarantee this, you should use
 * avro_value_copy, which compares the schemas before comparing the
 * values.
 }

function avro_value_copy_fast(dest: pavro_value; const src: pavro_value): int; cdecl; external AvroLibraryName;

{*
 * Returns a hash value for a given Avro value.
 }


function avro_value_hash(value: pavro_value): uint32_t; cdecl; external AvroLibraryName;

{
 * Returns a string containing the JSON encoding of an Avro value.  You
 * must free this string when you're done with it, using the standard
 * free() function.  (*Not* using the custom Avro allocator.)
 }

function avro_value_to_json(const value: pavro_value; one_line: int; var json_str: PAnsiChar): int; cdecl; external AvroLibraryName;


{generic.h}
{*
 * Return a generic avro_value_iface_t implementation for the given
 * schema, regardless of what type it is.
 }

function avro_generic_class_from_schema(schema: pavro_schema): pavro_value_iface; cdecl; external AvroLibraryName;

{*
 * Allocate a new instance of the given generic value class.  @a iface
 * must have been created by @ref avro_generic_class_from_schema.
 }

function avro_generic_value_new(iface: pavro_value_iface; dest: pavro_value): int; cdecl; external AvroLibraryName;


{
 * These functions return an avro_value_iface_t implementation for each
 * primitive schema type.  (For enum, fixed, and the compound types, you
 * must use the @ref avro_generic_class_from_schema function.)
 }

function avro_generic_boolean_class(): pavro_value_iface; cdecl; external AvroLibraryName;
function avro_generic_bytes_class(): pavro_value_iface; cdecl; external AvroLibraryName;
function avro_generic_double_class(): pavro_value_iface; cdecl; external AvroLibraryName;
function avro_generic_float_class(): pavro_value_iface; cdecl; external AvroLibraryName;
function avro_generic_int_class(): pavro_value_iface; cdecl; external AvroLibraryName;
function avro_generic_long_class(): pavro_value_iface; cdecl; external AvroLibraryName;
function avro_generic_null_class(): pavro_value_iface; cdecl; external AvroLibraryName;
function avro_generic_string_class(): pavro_value_iface; cdecl; external AvroLibraryName;


{
 * These functions instantiate a new generic primitive value.
 }

function avro_generic_boolean_new(value: pavro_value; val: int): int; cdecl; external AvroLibraryName;
function avro_generic_bytes_new(value: pavro_value; buf: PAnsiChar; size: size_t): int; cdecl; external AvroLibraryName;
function avro_generic_double_new(value: pavro_value; val: double): int; cdecl; external AvroLibraryName;
function avro_generic_float_new(value: pavro_value; val: float): int; cdecl; external AvroLibraryName;
function avro_generic_int_new(value: pavro_value; val: int32_t): int; cdecl; external AvroLibraryName;
function avro_generic_long_new(value: pavro_value; val: int64_t): int; cdecl; external AvroLibraryName;
function avro_generic_null_new(value: pavro_value): int; cdecl; external AvroLibraryName;
function avro_generic_string_new(value: pavro_value; const val: PAnsiChar): int; cdecl; external AvroLibraryName;
function avro_generic_string_new_length(value: pavro_value; const val: PAnsiChar; size: size_t): int; cdecl; external AvroLibraryName;


function avro_classof(obj: avro_obj_t): avro_class_t; inline;
function is_avro_schema(obj: avro_obj_t): Boolean; inline;
function is_avro_datum(obj: avro_obj_t): Boolean; inline;
function avro_typeof(obj: avro_obj_t): avro_type_t; inline;
function is_avro_string(obj: avro_obj_t): Boolean; inline;
function is_avro_bytes(obj: avro_obj_t): Boolean; inline;
function is_avro_int32(obj: avro_obj_t): Boolean; inline;
function is_avro_int64(obj: avro_obj_t): Boolean; inline;
function is_avro_float(obj: avro_obj_t): Boolean; inline;
function is_avro_double(obj: avro_obj_t): Boolean; inline;
function is_avro_boolean(obj: avro_obj_t): Boolean; inline;
function is_avro_null(obj: avro_obj_t): Boolean; inline;
function is_avro_primitive(obj: avro_obj_t): Boolean; inline;
function is_avro_record(obj: avro_obj_t): Boolean; inline;
function is_avro_enum(obj: avro_obj_t): Boolean; inline;
function is_avro_fixed(obj: avro_obj_t): Boolean; inline;
function is_avro_named_type(obj: avro_obj_t): Boolean; inline;
function is_avro_map(obj: avro_obj_t): Boolean; inline;
function is_avro_array(obj: avro_obj_t): Boolean; inline;
function is_avro_union(obj: avro_obj_t): Boolean; inline;
function is_avro_complex_type(obj: avro_obj_t): Boolean; inline;
function is_avro_link(obj: avro_obj_t): Boolean; inline;


implementation

function avro_classof(obj: avro_obj_t): avro_class_t; inline;
begin
  Result := obj.class_type;
end;

function is_avro_schema(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_classof(obj) = AVRO_SCHEMA;
end;

function is_avro_datum(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_classof(obj) = AVRO_DATUM;
end;

function avro_typeof(obj: avro_obj_t): avro_type_t; inline;
begin
  Result :=obj.&type;
end;

function is_avro_string(obj: avro_obj_t): Boolean; inline;
begin
 Result := avro_typeof(obj) = AVRO_STRING;
end;

function is_avro_bytes(obj: avro_obj_t): Boolean; inline;
begin
    Result := avro_typeof(obj) = AVRO_BYTES;
end;

function is_avro_int32(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_typeof(obj) = AVRO_INT32;
end;

function is_avro_int64(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_typeof(obj) = AVRO_INT64;
end;

function is_avro_float(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_typeof(obj) = AVRO_FLOAT;
end;

function is_avro_double(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_typeof(obj) = AVRO_DOUBLE;
end;

function is_avro_boolean(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_typeof(obj) = AVRO_BOOLEAN;
end;

function is_avro_null(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_typeof(obj) = AVRO_NULL;
end;

function is_avro_primitive(obj: avro_obj_t): Boolean; inline;
begin
  Result :=  is_avro_string(obj) or is_avro_bytes(obj) or is_avro_int32(obj)
           or is_avro_int64(obj) or is_avro_float(obj) or is_avro_double(obj)
           or is_avro_boolean(obj) or is_avro_null(obj);
end;

function is_avro_record(obj: avro_obj_t): Boolean; inline;
begin
 Result := avro_typeof(obj) = AVRO_RECORD;
end;

function is_avro_enum(obj: avro_obj_t): Boolean; inline;
begin
 Result := avro_typeof(obj) = AVRO_ENUM;
end;

function is_avro_fixed(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_typeof(obj) = AVRO_FIXED;
end;

function is_avro_named_type(obj: avro_obj_t): Boolean; inline;
begin
  Result := is_avro_record(obj) or is_avro_enum(obj) or is_avro_fixed(obj);
end;

function is_avro_map(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_typeof(obj) = AVRO_MAP;
end;

function is_avro_array(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_typeof(obj) = AVRO_ARRAY;
end;

function is_avro_union(obj: avro_obj_t): Boolean; inline;
begin
 Result := avro_typeof(obj) = AVRO_UNION;
end;

function is_avro_complex_type(obj: avro_obj_t): Boolean; inline;
begin
 Result := not is_avro_primitive(obj);
end;

function is_avro_link(obj: avro_obj_t): Boolean; inline;
begin
  Result := avro_typeof(obj) = AVRO_LINK;
end;

function avro_schema_from_json_literal(json: PAnsiChar; var schema: pavro_schema): int; inline;
begin
  Result := avro_schema_from_json_length(json, Length(json), schema);
end;


end.
