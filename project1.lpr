program project1;

uses avro, classes, sysutils;

const sPERSON_SCHEMA =
  '{"type":"record",'+
  '"name":"Person",'+
  '"fields":['+
     '{"name": "ID", "type": "long"},'+
     '{"name": "First", "type": "string"},'+
     '{"name": "Last", "type": "string"},'+
     '{"name": "Phone", "type": "string"},'+
     '{"name": "Age", "type": "int"}]}';

var person_schema: pavro_schema;
    rval: int;
    db: pavro_file_writer;
    dbreader: pavro_file_reader;
    wr: pavro_writer;
    id: int64_t;
    i: integer;
    projection_schema, first_name_schema, phone_schema: pavro_schema;
    FS: TFileStream;
    h: THandle;
    cl: pavro_value_iface;

procedure init_schema();
var
  i: int;
begin
  i := avro_schema_from_json_literal(PAnsiChar(sPERSON_SCHEMA), person_schema);
  if i > 0 then
   begin
     writeln('Unable to parse person schema');
     halt(1);
   end;
end;

procedure add_person(db: pavro_file_writer; first, last, phone: String; age: int32_t);
var person, id_datum, first_datum, last_datum, age_datum, phone_datum: pavro_datum;
begin
  id := id + 1;
  person := avro_record_f(person_schema);
  id_datum := avro_int64_f(id);
  first_datum := avro_string_f(PAnsiChar(first));
  last_datum := avro_string_f(PAnsiChar(last));
  age_datum := avro_int32_f(age);
  phone_datum := avro_string_f(PAnsiChar(phone));
  if (avro_record_set(person, 'ID', id_datum) > 0)
    or (avro_record_set(person, 'First', first_datum) > 0)
    or (avro_record_set(person, 'Last', last_datum) > 0)
    or (avro_record_set(person, 'Age', age_datum) > 0)
    or (avro_record_set(person, 'Phone', phone_datum) > 0) then
    begin
      writeln('Unable to create Person datum structure');
      Halt(1);
    end;
  if (avro_file_writer_append(db, person) > 0) then
    begin
      writeln('Unable to write Person datum to memory buffer');
      halt(1);
    end;
  avro_datum_decref(id_datum);
  avro_datum_decref(first_datum);
  avro_datum_decref(last_datum);
  avro_datum_decref(age_datum);
  avro_datum_decref(phone_datum);
  avro_datum_decref(person);
end;


function print_person(db: pavro_file_reader; reader_schema: pavro_schema): int;
var
  rval: int;
  person: pavro_datum;
  i64: int64_t;
  i32: int32_t;
  p, d: PAnsiChar;
  id_datum, first_datum, last_datum, phone_datum, age_datum: pavro_datum;
begin
	rval := avro_file_reader_read(db, reader_schema, person);
	if (rval = 0) then
          begin
		if (avro_record_get(person, 'ID', id_datum) = 0) then
                begin
			avro_int64_get(id_datum, i64);
			Write(i64,'|');
                end;
		if (avro_record_get(person, 'First', &first_datum) = 0) then
                begin
			avro_string_get(first_datum, p);
			write(p,'|');
                end;
		if (avro_record_get(person, 'Last', last_datum) = 0)  then
                begin
			avro_string_get(last_datum, &p);
			write(p,'|');
                end;
		if (avro_record_get(person, 'Phone', phone_datum) = 0) then
                begin
			avro_string_get(phone_datum, &p);
			write(p,'|');
                end;
		if (avro_record_get(person, 'Age', age_datum) = 0) then
                begin
			avro_int32_get(age_datum, i32);
			write(i32,'|');
                end;
		writeln;
		avro_datum_decref(person);
          end;
	Result := rval;
end;

begin
  init_schema();
  db := nil;
  id := 0;
  rval := avro_file_writer_create_with_codec('quickstop.db', person_schema, db, 'lzma', 0);
  for i := 0 to 1000 do
  begin
   add_person(db, 'Dante', 'Hicks', '(555) 123-5678', 32);
   add_person(db, 'Randal', 'Graves', '(555) 123-5678', 30);
   add_person(db, 'Veronica', 'Loughran', '(555) 123-0987', 28);
   add_person(db, 'Caitlin', 'Bree', '(555) 123-2323', 27);
   add_person(db, 'Bob', 'Silent', '(555) 123-6422', 29);
   add_person(db, 'Jay', '???', '(555) 11-22233', 26);
  end;
  avro_file_writer_flush(db);
  add_person(db, 'Super', 'Man', '123456', 31);
  avro_file_writer_close(db);

  i := avro_file_reader('quickstop.db', dbreader);
  if (i > 0) then
   begin
         writeln('Error opening file');
         halt(1);
   end;
  for i := 0 to id - 1 do
   if (print_person(dbreader, nil) > 0) then
     begin
           writeln('Error printing person');
           halt(1);
     end;
  avro_file_reader_close(dbreader);
  projection_schema := avro_schema_record('Person', nil);
  first_name_schema := avro_schema_string();
  phone_schema :=  avro_schema_string();
  avro_schema_record_field_append(projection_schema, 'First', first_name_schema);
  avro_schema_record_field_append(projection_schema, 'Phone', phone_schema);

  i := avro_file_reader('quickstop.db', dbreader);
  if (i > 0) then
   begin
         writeln('Error opening file');
         halt(1);
   end;
  for i := 0 to id - 1 do
   if (print_person(dbreader, projection_schema) > 0) then
     begin
           writeln('Error printing person');
           halt(1);
     end;
  avro_file_reader_close(dbreader);

  avro_schema_decref(first_name_schema);
  avro_schema_decref(phone_schema);
  avro_schema_decref(projection_schema);
  avro_schema_decref(person_schema);


end.

