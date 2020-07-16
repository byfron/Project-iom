const PROTO_VERSION = 2

#
# BSD 3-Clause License
#
# Copyright (c) 2018, Oleg Malyavkin
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# DEBUG_TAB redefine this "  " if you need, example: const DEBUG_TAB = "\t"
const DEBUG_TAB = "  "

enum PB_ERR {
	NO_ERRORS = 0,
	VARINT_NOT_FOUND = -1,
	REPEATED_COUNT_NOT_FOUND = -2,
	REPEATED_COUNT_MISMATCH = -3,
	LENGTHDEL_SIZE_NOT_FOUND = -4,
	LENGTHDEL_SIZE_MISMATCH = -5,
	PACKAGE_SIZE_MISMATCH = -6,
	UNDEFINED_STATE = -7,
	PARSE_INCOMPLETE = -8,
	REQUIRED_FIELDS = -9
}

enum PB_DATA_TYPE {
	INT32 = 0,
	SINT32 = 1,
	UINT32 = 2,
	INT64 = 3,
	SINT64 = 4,
	UINT64 = 5,
	BOOL = 6,
	ENUM = 7,
	FIXED32 = 8,
	SFIXED32 = 9,
	FLOAT = 10,
	FIXED64 = 11,
	SFIXED64 = 12,
	DOUBLE = 13,
	STRING = 14,
	BYTES = 15,
	MESSAGE = 16,
	MAP = 17
}

const DEFAULT_VALUES_2 = {
	PB_DATA_TYPE.INT32: null,
	PB_DATA_TYPE.SINT32: null,
	PB_DATA_TYPE.UINT32: null,
	PB_DATA_TYPE.INT64: null,
	PB_DATA_TYPE.SINT64: null,
	PB_DATA_TYPE.UINT64: null,
	PB_DATA_TYPE.BOOL: null,
	PB_DATA_TYPE.ENUM: null,
	PB_DATA_TYPE.FIXED32: null,
	PB_DATA_TYPE.SFIXED32: null,
	PB_DATA_TYPE.FLOAT: null,
	PB_DATA_TYPE.FIXED64: null,
	PB_DATA_TYPE.SFIXED64: null,
	PB_DATA_TYPE.DOUBLE: null,
	PB_DATA_TYPE.STRING: null,
	PB_DATA_TYPE.BYTES: null,
	PB_DATA_TYPE.MESSAGE: null,
	PB_DATA_TYPE.MAP: null
}

const DEFAULT_VALUES_3 = {
	PB_DATA_TYPE.INT32: 0,
	PB_DATA_TYPE.SINT32: 0,
	PB_DATA_TYPE.UINT32: 0,
	PB_DATA_TYPE.INT64: 0,
	PB_DATA_TYPE.SINT64: 0,
	PB_DATA_TYPE.UINT64: 0,
	PB_DATA_TYPE.BOOL: false,
	PB_DATA_TYPE.ENUM: 0,
	PB_DATA_TYPE.FIXED32: 0,
	PB_DATA_TYPE.SFIXED32: 0,
	PB_DATA_TYPE.FLOAT: 0.0,
	PB_DATA_TYPE.FIXED64: 0,
	PB_DATA_TYPE.SFIXED64: 0,
	PB_DATA_TYPE.DOUBLE: 0.0,
	PB_DATA_TYPE.STRING: "",
	PB_DATA_TYPE.BYTES: [],
	PB_DATA_TYPE.MESSAGE: null,
	PB_DATA_TYPE.MAP: []
}

enum PB_TYPE {
	VARINT = 0,
	FIX64 = 1,
	LENGTHDEL = 2,
	STARTGROUP = 3,
	ENDGROUP = 4,
	FIX32 = 5,
	UNDEFINED = 8
}

enum PB_RULE {
	OPTIONAL = 0,
	REQUIRED = 1,
	REPEATED = 2,
	RESERVED = 3
}

enum PB_SERVICE_STATE {
	FILLED = 0,
	UNFILLED = 1
}

class PBField:
	func _init(a_name, a_type, a_rule, a_tag, packed, a_value = null):
		name = a_name
		type = a_type
		rule = a_rule
		tag = a_tag
		option_packed = packed
		value = a_value
	var name
	var type
	var rule
	var tag
	var option_packed
	var value
	var option_default = false

class PBLengthDelimitedField:
	var type = null
	var tag = null
	var begin = null
	var size = null

class PBUnpackedField:
	var offset
	var field

class PBTypeTag:
	var type = null
	var tag = null
	var offset = null

class PBServiceField:
	var field
	var func_ref = null
	var state = PB_SERVICE_STATE.UNFILLED

class PBPacker:
	static func convert_signed(n):
		if n < -2147483648:
			return (n << 1) ^ (n >> 63)
		else:
			return (n << 1) ^ (n >> 31)

	static func deconvert_signed(n):
		if n & 0x01:
			return ~(n >> 1)
		else:
			return (n >> 1)

	static func pack_varint(value):
		var varint = PoolByteArray()
		if typeof(value) == TYPE_BOOL:
			if value:
				value = 1
			else:
				value = 0
		for i in range(9):
			var b = value & 0x7F
			value >>= 7
			if value:
				varint.append(b | 0x80)
			else:
				varint.append(b)
				break
		if varint.size() == 9 && varint[8] == 0xFF:
			varint.append(0x01)
		return varint

	static func pack_bytes(value, count, data_type):
		var bytes = PoolByteArray()
		if data_type == PB_DATA_TYPE.FLOAT:
			var spb = StreamPeerBuffer.new()
			spb.put_float(value)
			bytes = spb.get_data_array()
		elif data_type == PB_DATA_TYPE.DOUBLE:
			var spb = StreamPeerBuffer.new()
			spb.put_double(value)
			bytes = spb.get_data_array()
		else:
			for i in range(count):
				bytes.append(value & 0xFF)
				value >>= 8
		return bytes

	static func unpack_bytes(bytes, index, count, data_type):
		var value = 0
		if data_type == PB_DATA_TYPE.FLOAT:
			var spb = StreamPeerBuffer.new()
			for i in range(index, count + index):
				spb.put_u8(bytes[i])
			spb.seek(0)
			value = spb.get_float()
		elif data_type == PB_DATA_TYPE.DOUBLE:
			var spb = StreamPeerBuffer.new()
			for i in range(index, count + index):
				spb.put_u8(bytes[i])
			spb.seek(0)
			value = spb.get_double()
		else:
			for i in range(index + count - 1, index - 1, -1):
				value |= (bytes[i] & 0xFF)
				if i != index:
					value <<= 8
		return value

	static func unpack_varint(varint_bytes):
		var value = 0
		for i in range(varint_bytes.size() - 1, -1, -1):
			value |= varint_bytes[i] & 0x7F
			if i != 0:
				value <<= 7
		return value

	static func pack_type_tag(type, tag):
		return pack_varint((tag << 3) | type)

	static func isolate_varint(bytes, index):
		var result = PoolByteArray()
		for i in range(index, bytes.size()):
			result.append(bytes[i])
			if !(bytes[i] & 0x80):
				break
		return result

	static func unpack_type_tag(bytes, index):
		var varint_bytes = isolate_varint(bytes, index)
		var result = PBTypeTag.new()
		if varint_bytes.size() != 0:
			result.offset = varint_bytes.size()
			var unpacked = unpack_varint(varint_bytes)
			result.type = unpacked & 0x07
			result.tag = unpacked >> 3
		return result

	static func pack_length_delimeted(type, tag, bytes):
		var result = pack_type_tag(type, tag)
		result.append_array(pack_varint(bytes.size()))
		result.append_array(bytes)
		return result

	static func unpack_length_delimiter(bytes, index):
		var result = PBLengthDelimitedField.new()
		var type_tag = unpack_type_tag(bytes, index)
		var offset = type_tag.offset
		if offset != null:
			result.type = type_tag.type
			result.tag = type_tag.tag
			var size = isolate_varint(bytes, offset)
			if size > 0:
				offset += size
				if bytes.size() >= size + offset:
					result.begin = offset
					result.size = size
		return result

	static func pb_type_from_data_type(data_type):
		if data_type == PB_DATA_TYPE.INT32 || data_type == PB_DATA_TYPE.SINT32 || data_type == PB_DATA_TYPE.UINT32 || data_type == PB_DATA_TYPE.INT64 || data_type == PB_DATA_TYPE.SINT64 || data_type == PB_DATA_TYPE.UINT64 || data_type == PB_DATA_TYPE.BOOL || data_type == PB_DATA_TYPE.ENUM:
			return PB_TYPE.VARINT
		elif data_type == PB_DATA_TYPE.FIXED32 || data_type == PB_DATA_TYPE.SFIXED32 || data_type == PB_DATA_TYPE.FLOAT:
			return PB_TYPE.FIX32
		elif data_type == PB_DATA_TYPE.FIXED64 || data_type == PB_DATA_TYPE.SFIXED64 || data_type == PB_DATA_TYPE.DOUBLE:
			return PB_TYPE.FIX64
		elif data_type == PB_DATA_TYPE.STRING || data_type == PB_DATA_TYPE.BYTES || data_type == PB_DATA_TYPE.MESSAGE || data_type == PB_DATA_TYPE.MAP:
			return PB_TYPE.LENGTHDEL
		else:
			return PB_TYPE.UNDEFINED

	static func pack_field(field):
		var type = pb_type_from_data_type(field.type)
		var type_copy = type
		if field.rule == PB_RULE.REPEATED && field.option_packed:
			type = PB_TYPE.LENGTHDEL
		var head = pack_type_tag(type, field.tag)
		var data = PoolByteArray()
		if type == PB_TYPE.VARINT:
			var value
			if field.rule == PB_RULE.REPEATED:
				for v in field.value:
					data.append_array(head)
					if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
						value = convert_signed(v)
					else:
						value = v
					data.append_array(pack_varint(value))
				return data
			else:
				if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
					value = convert_signed(field.value)
				else:
					value = field.value
				data = pack_varint(value)
		elif type == PB_TYPE.FIX32:
			if field.rule == PB_RULE.REPEATED:
				for v in field.value:
					data.append_array(head)
					data.append_array(pack_bytes(v, 4, field.type))
				return data
			else:
				data.append_array(pack_bytes(field.value, 4, field.type))
		elif type == PB_TYPE.FIX64:
			if field.rule == PB_RULE.REPEATED:
				for v in field.value:
					data.append_array(head)
					data.append_array(pack_bytes(v, 8, field.type))
				return data
			else:
				data.append_array(pack_bytes(field.value, 8, field.type))
		elif type == PB_TYPE.LENGTHDEL:
			if field.rule == PB_RULE.REPEATED:
				if type_copy == PB_TYPE.VARINT:
					if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
						var signed_value
						for v in field.value:
							signed_value = convert_signed(v)
							data.append_array(pack_varint(signed_value))
					else:
						for v in field.value:
							data.append_array(pack_varint(v))
					return pack_length_delimeted(type, field.tag, data)
				elif type_copy == PB_TYPE.FIX32:
					for v in field.value:
						data.append_array(pack_bytes(v, 4, field.type))
					return pack_length_delimeted(type, field.tag, data)
				elif type_copy == PB_TYPE.FIX64:
					for v in field.value:
						data.append_array(pack_bytes(v, 8, field.type))
					return pack_length_delimeted(type, field.tag, data)
				elif field.type == PB_DATA_TYPE.STRING:
					for v in field.value:
						var obj = v.to_utf8()
						data.append_array(pack_length_delimeted(type, field.tag, obj))
					return data
				elif field.type == PB_DATA_TYPE.BYTES:
					for v in field.value:
						data.append_array(pack_length_delimeted(type, field.tag, v))
					return data
				elif typeof(field.value[0]) == TYPE_OBJECT:
					for v in field.value:
						var obj = v.to_bytes()
						#if obj != null && obj.size() > 0:
						#	data.append_array(pack_length_delimeted(type, field.tag, obj))
						#else:
						#	data = PoolByteArray()
						#	return data
						if obj != null:#
							data.append_array(pack_length_delimeted(type, field.tag, obj))#
						else:#
							data = PoolByteArray()#
							return data#
					return data
			else:
				if field.type == PB_DATA_TYPE.STRING:
					var str_bytes = field.value.to_utf8()
					if PROTO_VERSION == 2 || (PROTO_VERSION == 3 && str_bytes.size() > 0):
						data.append_array(str_bytes)
						return pack_length_delimeted(type, field.tag, data)
				if field.type == PB_DATA_TYPE.BYTES:
					if PROTO_VERSION == 2 || (PROTO_VERSION == 3 && field.value.size() > 0):
						data.append_array(field.value)
						return pack_length_delimeted(type, field.tag, data)
				elif typeof(field.value) == TYPE_OBJECT:
					var obj = field.value.to_bytes()
					#if obj != null && obj.size() > 0:
					#	data.append_array(obj)
					#	return pack_length_delimeted(type, field.tag, data)
					if obj != null:#
						if obj.size() > 0:#
							data.append_array(obj)#
						return pack_length_delimeted(type, field.tag, data)#
				else:
					pass
		if data.size() > 0:
			head.append_array(data)
			return head
		else:
			return data

	static func unpack_field(bytes, offset, field, type, message_func_ref):
		if field.rule == PB_RULE.REPEATED && type != PB_TYPE.LENGTHDEL && field.option_packed:
			var count = isolate_varint(bytes, offset)
			if count.size() > 0:
				offset += count.size()
				count = unpack_varint(count)
				if type == PB_TYPE.VARINT:
					var val
					var counter = offset + count
					while offset < counter:
						val = isolate_varint(bytes, offset)
						if val.size() > 0:
							offset += val.size()
							val = unpack_varint(val)
							if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
								val = deconvert_signed(val)
							elif field.type == PB_DATA_TYPE.BOOL:
								if val:
									val = true
								else:
									val = false
							field.value.append(val)
						else:
							return PB_ERR.REPEATED_COUNT_MISMATCH
					return offset
				elif type == PB_TYPE.FIX32 || type == PB_TYPE.FIX64:
					var type_size
					if type == PB_TYPE.FIX32:
						type_size = 4
					else:
						type_size = 8
					var val
					var counter = offset + count
					while offset < counter:
						if (offset + type_size) > bytes.size():
							return PB_ERR.REPEATED_COUNT_MISMATCH
						val = unpack_bytes(bytes, offset, type_size, field.type)
						offset += type_size
						field.value.append(val)
					return offset
			else:
				return PB_ERR.REPEATED_COUNT_NOT_FOUND
		else:
			if type == PB_TYPE.VARINT:
				var val = isolate_varint(bytes, offset)
				if val.size() > 0:
					offset += val.size()
					val = unpack_varint(val)
					if field.type == PB_DATA_TYPE.SINT32 || field.type == PB_DATA_TYPE.SINT64:
						val = deconvert_signed(val)
					elif field.type == PB_DATA_TYPE.BOOL:
						if val:
							val = true
						else:
							val = false
					if field.rule == PB_RULE.REPEATED:
						field.value.append(val)
					else:
						field.value = val
				else:
					return PB_ERR.VARINT_NOT_FOUND
				return offset
			elif type == PB_TYPE.FIX32 || type == PB_TYPE.FIX64:
				var type_size
				if type == PB_TYPE.FIX32:
					type_size = 4
				else:
					type_size = 8
				var val
				if (offset + type_size) > bytes.size():
					return PB_ERR.REPEATED_COUNT_MISMATCH
				val = unpack_bytes(bytes, offset, type_size, field.type)
				offset += type_size
				if field.rule == PB_RULE.REPEATED:
					field.value.append(val)
				else:
					field.value = val
				return offset
			elif type == PB_TYPE.LENGTHDEL:
				var inner_size = isolate_varint(bytes, offset)
				if inner_size.size() > 0:
					offset += inner_size.size()
					inner_size = unpack_varint(inner_size)
					if inner_size >= 0:
						if inner_size + offset > bytes.size():
							return PB_ERR.LENGTHDEL_SIZE_MISMATCH
						if message_func_ref != null:
							var message = message_func_ref.call_func()
							if inner_size > 0:
								var sub_offset = message.from_bytes(bytes, offset, inner_size + offset)
								if sub_offset > 0:
									if sub_offset - offset >= inner_size:
										offset = sub_offset
										return offset
									else:
										return PB_ERR.LENGTHDEL_SIZE_MISMATCH
								return sub_offset
							else:
								return offset
						elif field.type == PB_DATA_TYPE.STRING:
							var str_bytes = PoolByteArray()
							for i in range(offset, inner_size + offset):
								str_bytes.append(bytes[i])
							if field.rule == PB_RULE.REPEATED:
								field.value.append(str_bytes.get_string_from_utf8())
							else:
								field.value = str_bytes.get_string_from_utf8()
							return offset + inner_size
						elif field.type == PB_DATA_TYPE.BYTES:
							var val_bytes = PoolByteArray()
							for i in range(offset, inner_size + offset):
								val_bytes.append(bytes[i])
							if field.rule == PB_RULE.REPEATED:
								field.value.append(val_bytes)
							else:
								field.value = val_bytes
							return offset + inner_size
					else:
						return PB_ERR.LENGTHDEL_SIZE_NOT_FOUND
				else:
					return PB_ERR.LENGTHDEL_SIZE_NOT_FOUND
		return PB_ERR.UNDEFINED_STATE

	static func unpack_message(data, bytes, offset, limit):
		while true:
			var tt = unpack_type_tag(bytes, offset)
			if tt.offset != null:
				offset += tt.offset
				if data.has(tt.tag):
					var service = data[tt.tag]
					var type = pb_type_from_data_type(service.field.type)
					if type == tt.type || (tt.type == PB_TYPE.LENGTHDEL && service.field.rule == PB_RULE.REPEATED && service.field.option_packed):
						var res = unpack_field(bytes, offset, service.field, type, service.func_ref)
						if res > 0:
							service.state = PB_SERVICE_STATE.FILLED
							offset = res
							if offset == limit:
								return offset
							elif offset > limit:
								return PB_ERR.PACKAGE_SIZE_MISMATCH
						elif res < 0:
							return res
						else:
							break
			else:
				return offset
		return PB_ERR.UNDEFINED_STATE

	static func pack_message(data):
		var DEFAULT_VALUES
		if PROTO_VERSION == 2:
			DEFAULT_VALUES = DEFAULT_VALUES_2
		elif PROTO_VERSION == 3:
			DEFAULT_VALUES = DEFAULT_VALUES_3
		var result = PoolByteArray()
		var keys = data.keys()
		keys.sort()
		for i in keys:
			if data[i].field.value != null:
				if typeof(data[i].field.value) == typeof(DEFAULT_VALUES[data[i].field.type]) && data[i].field.value == DEFAULT_VALUES[data[i].field.type]:
					continue
				elif data[i].field.rule == PB_RULE.REPEATED && data[i].field.value.size() == 0:
					continue
				result.append_array(pack_field(data[i].field))
			elif data[i].field.rule == PB_RULE.REQUIRED:
				print("Error: required field is not filled: Tag:", data[i].field.tag)
				return null
		return result

	static func check_required(data):
		var keys = data.keys()
		for i in keys:
			if data[i].field.rule == PB_RULE.REQUIRED && data[i].state == PB_SERVICE_STATE.UNFILLED:
				return false
		return true

	static func construct_map(key_values):
		var result = {}
		for kv in key_values:
			result[kv.get_key()] = kv.get_value()
		return result
	
	static func tabulate(text, nesting):
		var tab = ""
		for i in range(nesting):
			tab += DEBUG_TAB
		return tab + text
	
	static func value_to_string(value, field, nesting):
		var result = ""
		var text
		if field.type == PB_DATA_TYPE.MESSAGE:
			result += "{"
			nesting += 1
			text = message_to_string(value.data, nesting)
			if text != "":
				result += "\n" + text
				nesting -= 1
				result += tabulate("}", nesting)
			else:
				nesting -= 1
				result += "}"
		elif field.type == PB_DATA_TYPE.BYTES:
			result += "<"
			for i in range(value.size()):
				result += String(value[i])
				if i != (value.size() - 1):
					result += ", "
			result += ">"
		elif field.type == PB_DATA_TYPE.STRING:
			result += "\"" + value + "\""
		elif field.type == PB_DATA_TYPE.ENUM:
			result += "ENUM::" + String(value)
		else:
			result += String(value)
		return result
	
	static func field_to_string(field, nesting):
		var result = tabulate(field.name + ": ", nesting)
		if field.type == PB_DATA_TYPE.MAP:
			if field.value.size() > 0:
				result += "(\n"
				nesting += 1
				for i in range(field.value.size()):
					var local_key_value = field.value[i].data[1].field
					result += tabulate(value_to_string(local_key_value.value, local_key_value, nesting), nesting) + ": "
					local_key_value = field.value[i].data[2].field
					result += value_to_string(local_key_value.value, local_key_value, nesting)
					if i != (field.value.size() - 1):
						result += ","
					result += "\n"
				nesting -= 1
				result += tabulate(")", nesting)
			else:
				result += "()"
		elif field.rule == PB_RULE.REPEATED:
			if field.value.size() > 0:
				result += "[\n"
				nesting += 1
				for i in range(field.value.size()):
					result += tabulate(String(i) + ": ", nesting)
					result += value_to_string(field.value[i], field, nesting)
					if i != (field.value.size() - 1):
						result += ","
					result += "\n"
				nesting -= 1
				result += tabulate("]", nesting)
			else:
				result += "[]"
		else:
			result += value_to_string(field.value, field, nesting)
		result += ";\n"
		return result
		
	static func message_to_string(data, nesting = 0):
		var DEFAULT_VALUES
		if PROTO_VERSION == 2:
			DEFAULT_VALUES = DEFAULT_VALUES_2
		elif PROTO_VERSION == 3:
			DEFAULT_VALUES = DEFAULT_VALUES_3
		var result = ""
		var keys = data.keys()
		keys.sort()
		for i in keys:
			if data[i].field.value != null:
				if typeof(data[i].field.value) == typeof(DEFAULT_VALUES[data[i].field.type]) && data[i].field.value == DEFAULT_VALUES[data[i].field.type]:
					continue
				elif data[i].field.rule == PB_RULE.REPEATED && data[i].field.value.size() == 0:
					continue
				result += field_to_string(data[i].field, nesting)
			elif data[i].field.rule == PB_RULE.REQUIRED:
				result += data[i].field.name + ": " + "error"
		return result


############### USER DATA BEGIN ################


class LocationComponent:
	func _init():
		var service
		
		_coord = PBField.new("coord", PB_DATA_TYPE.MESSAGE, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _coord
		service.func_ref = funcref(self, "new_coord")
		data[_coord.tag] = service
		
	var data = {}
	
	var _coord
	func get_coord():
		return _coord.value
	func clear_coord():
		_coord.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func new_coord():
		_coord.value = PBMapCoordinate.new()
		return _coord.value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class MovementComponent:
	func _init():
		var service
		
		_speed = PBField.new("speed", PB_DATA_TYPE.FLOAT, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.FLOAT])
		service = PBServiceField.new()
		service.field = _speed
		data[_speed.tag] = service
		
	var data = {}
	
	var _speed
	func get_speed():
		return _speed.value
	func clear_speed():
		_speed.value = DEFAULT_VALUES_2[PB_DATA_TYPE.FLOAT]
	func set_speed(value):
		_speed.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class GraphicsComponent:
	func _init():
		var service
		
		_size_x = PBField.new("size_x", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _size_x
		data[_size_x.tag] = service
		
		_size_y = PBField.new("size_y", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _size_y
		data[_size_y.tag] = service
		
		_graphics_id = PBField.new("graphics_id", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _graphics_id
		data[_graphics_id.tag] = service
		
		_gtype = PBField.new("gtype", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _gtype
		data[_gtype.tag] = service
		
		_cast_shadows = PBField.new("cast_shadows", PB_DATA_TYPE.BOOL, PB_RULE.REQUIRED, 5, false, DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL])
		service = PBServiceField.new()
		service.field = _cast_shadows
		data[_cast_shadows.tag] = service
		
	var data = {}
	
	var _size_x
	func get_size_x():
		return _size_x.value
	func clear_size_x():
		_size_x.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_size_x(value):
		_size_x.value = value
	
	var _size_y
	func get_size_y():
		return _size_y.value
	func clear_size_y():
		_size_y.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_size_y(value):
		_size_y.value = value
	
	var _graphics_id
	func get_graphics_id():
		return _graphics_id.value
	func clear_graphics_id():
		_graphics_id.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_graphics_id(value):
		_graphics_id.value = value
	
	var _gtype
	func get_gtype():
		return _gtype.value
	func clear_gtype():
		_gtype.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_gtype(value):
		_gtype.value = value
	
	var _cast_shadows
	func get_cast_shadows():
		return _cast_shadows.value
	func clear_cast_shadows():
		_cast_shadows.value = DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL]
	func set_cast_shadows(value):
		_cast_shadows.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class BehaviorComponent:
	func _init():
		var service
		
		_script = PBField.new("script", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _script
		data[_script.tag] = service
		
	var data = {}
	
	var _script
	func get_script():
		return _script.value
	func clear_script():
		_script.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_script(value):
		_script.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class DialogState:
	func _init():
		var service
		
		_id = PBField.new("id", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _id
		data[_id.tag] = service
		
		_script = PBField.new("script", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _script
		data[_script.tag] = service
		
	var data = {}
	
	var _id
	func get_id():
		return _id.value
	func clear_id():
		_id.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_id(value):
		_id.value = value
	
	var _script
	func get_script():
		return _script.value
	func clear_script():
		_script.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_script(value):
		_script.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class DialogComponent:
	func _init():
		var service
		
		_dialog_states = PBField.new("dialog_states", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 1, false, [])
		service = PBServiceField.new()
		service.field = _dialog_states
		service.func_ref = funcref(self, "add_dialog_states")
		data[_dialog_states.tag] = service
		
	var data = {}
	
	var _dialog_states
	func get_dialog_states():
		return _dialog_states.value
	func clear_dialog_states():
		_dialog_states.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func add_dialog_states():
		var element = DialogState.new()
		_dialog_states.value.append(element)
		return element
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class CharacterComponent:
	func _init():
		var service
		
		_name = PBField.new("name", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _name
		data[_name.tag] = service
		
		_gender = PBField.new("gender", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _gender
		data[_gender.tag] = service
		
		_level = PBField.new("level", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _level
		data[_level.tag] = service
		
		_experience = PBField.new("experience", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _experience
		data[_experience.tag] = service
		
	var data = {}
	
	var _name
	func get_name():
		return _name.value
	func clear_name():
		_name.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_name(value):
		_name.value = value
	
	var _gender
	func get_gender():
		return _gender.value
	func clear_gender():
		_gender.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_gender(value):
		_gender.value = value
	
	var _level
	func get_level():
		return _level.value
	func clear_level():
		_level.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_level(value):
		_level.value = value
	
	var _experience
	func get_experience():
		return _experience.value
	func clear_experience():
		_experience.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_experience(value):
		_experience.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class SoundComponent:
	func _init():
		var service
		
		_sound_map = PBField.new("sound_map", PB_DATA_TYPE.MAP, PB_RULE.REPEATED, 1, false, [])
		service = PBServiceField.new()
		service.field = _sound_map
		service.func_ref = funcref(self, "add_empty_sound_map")
		data[_sound_map.tag] = service
		
	var data = {}
	
	var _sound_map
	func get_raw_sound_map():
		return _sound_map.value
	func get_sound_map():
		return PBPacker.construct_map(_sound_map.value)
	func clear_sound_map():
		_sound_map.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MAP]
	func add_empty_sound_map():
		var element = SoundComponent.map_type_sound_map.new()
		_sound_map.value.append(element)
		return element
	func add_sound_map(a_key, a_value):
		var idx = -1
		for i in range(_sound_map.value.size()):
			if _sound_map.value[i].get_key() == a_key:
				idx = i
				break
		var element = SoundComponent.map_type_sound_map.new()
		element.set_key(a_key)
		element.set_value(a_value)
		if idx != -1:
			_sound_map.value[idx] = element
		else:
			_sound_map.value.append(element)
	
	class map_type_sound_map:
		func _init():
			var service
			
			_key = PBField.new("key", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
			service = PBServiceField.new()
			service.field = _key
			data[_key.tag] = service
			
			_value = PBField.new("value", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
			service = PBServiceField.new()
			service.field = _value
			data[_value.tag] = service
			
		var data = {}
		
		var _key
		func get_key():
			return _key.value
		func clear_key():
			_key.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
		func set_key(value):
			_key.value = value
		
		var _value
		func get_value():
			return _value.value
		func clear_value():
			_value.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
		func set_value(value):
			_value.value = value
		
		func to_string():
			return PBPacker.message_to_string(data)
			
		func to_bytes():
			return PBPacker.pack_message(data)
			
		func from_bytes(bytes, offset = 0, limit = -1):
			var cur_limit = bytes.size()
			if limit != -1:
				cur_limit = limit
			var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
			if result == cur_limit:
				if PBPacker.check_required(data):
					if limit == -1:
						return PB_ERR.NO_ERRORS
				else:
					return PB_ERR.REQUIRED_FIELDS
			elif limit == -1 && result > 0:
				return PB_ERR.PARSE_INCOMPLETE
			return result
		
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class MainCharacterComponent:
	func _init():
		var service
		
		_name = PBField.new("name", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _name
		data[_name.tag] = service
		
		_gender = PBField.new("gender", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _gender
		data[_gender.tag] = service
		
		_level = PBField.new("level", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _level
		data[_level.tag] = service
		
		_experience = PBField.new("experience", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _experience
		data[_experience.tag] = service
		
	var data = {}
	
	var _name
	func get_name():
		return _name.value
	func clear_name():
		_name.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_name(value):
		_name.value = value
	
	var _gender
	func get_gender():
		return _gender.value
	func clear_gender():
		_gender.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_gender(value):
		_gender.value = value
	
	var _level
	func get_level():
		return _level.value
	func clear_level():
		_level.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_level(value):
		_level.value = value
	
	var _experience
	func get_experience():
		return _experience.value
	func clear_experience():
		_experience.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_experience(value):
		_experience.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class CharStatusComponent:
	func _init():
		var service
		
		_crouching = PBField.new("crouching", PB_DATA_TYPE.BOOL, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL])
		service = PBServiceField.new()
		service.field = _crouching
		data[_crouching.tag] = service
		
		_running = PBField.new("running", PB_DATA_TYPE.BOOL, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL])
		service = PBServiceField.new()
		service.field = _running
		data[_running.tag] = service
		
		_bleeding = PBField.new("bleeding", PB_DATA_TYPE.BOOL, PB_RULE.REQUIRED, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL])
		service = PBServiceField.new()
		service.field = _bleeding
		data[_bleeding.tag] = service
		
		_poisoned = PBField.new("poisoned", PB_DATA_TYPE.BOOL, PB_RULE.REQUIRED, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL])
		service = PBServiceField.new()
		service.field = _poisoned
		data[_poisoned.tag] = service
		
	var data = {}
	
	var _crouching
	func get_crouching():
		return _crouching.value
	func clear_crouching():
		_crouching.value = DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL]
	func set_crouching(value):
		_crouching.value = value
	
	var _running
	func get_running():
		return _running.value
	func clear_running():
		_running.value = DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL]
	func set_running(value):
		_running.value = value
	
	var _bleeding
	func get_bleeding():
		return _bleeding.value
	func clear_bleeding():
		_bleeding.value = DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL]
	func set_bleeding(value):
		_bleeding.value = value
	
	var _poisoned
	func get_poisoned():
		return _poisoned.value
	func clear_poisoned():
		_poisoned.value = DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL]
	func set_poisoned(value):
		_poisoned.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class CharStatsComponent:
	func _init():
		var service
		
		_health = PBField.new("health", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _health
		data[_health.tag] = service
		
		_stamina = PBField.new("stamina", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _stamina
		data[_stamina.tag] = service
		
		_mana = PBField.new("mana", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _mana
		data[_mana.tag] = service
		
		_sanity = PBField.new("sanity", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _sanity
		data[_sanity.tag] = service
		
	var data = {}
	
	var _health
	func get_health():
		return _health.value
	func clear_health():
		_health.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_health(value):
		_health.value = value
	
	var _stamina
	func get_stamina():
		return _stamina.value
	func clear_stamina():
		_stamina.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_stamina(value):
		_stamina.value = value
	
	var _mana
	func get_mana():
		return _mana.value
	func clear_mana():
		_mana.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_mana(value):
		_mana.value = value
	
	var _sanity
	func get_sanity():
		return _sanity.value
	func clear_sanity():
		_sanity.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_sanity(value):
		_sanity.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class VolumeComponent:
	func _init():
		var service
		
		_height = PBField.new("height", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _height
		data[_height.tag] = service
		
	var data = {}
	
	var _height
	func get_height():
		return _height.value
	func clear_height():
		_height.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_height(value):
		_height.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class AttributesComponent:
	func _init():
		var service
		
		_str = PBField.new("str", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _str
		data[_str.tag] = service
		
		_dex = PBField.new("dex", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _dex
		data[_dex.tag] = service
		
		_con = PBField.new("con", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _con
		data[_con.tag] = service
		
		_int = PBField.new("int", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _int
		data[_int.tag] = service
		
		_edu = PBField.new("edu", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 5, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _edu
		data[_edu.tag] = service
		
		_cha = PBField.new("cha", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 6, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _cha
		data[_cha.tag] = service
		
	var data = {}
	
	var _str
	func get_str():
		return _str.value
	func clear_str():
		_str.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_str(value):
		_str.value = value
	
	var _dex
	func get_dex():
		return _dex.value
	func clear_dex():
		_dex.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_dex(value):
		_dex.value = value
	
	var _con
	func get_con():
		return _con.value
	func clear_con():
		_con.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_con(value):
		_con.value = value
	
	var _int
	func get_int():
		return _int.value
	func clear_int():
		_int.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_int(value):
		_int.value = value
	
	var _edu
	func get_edu():
		return _edu.value
	func clear_edu():
		_edu.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_edu(value):
		_edu.value = value
	
	var _cha
	func get_cha():
		return _cha.value
	func clear_cha():
		_cha.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_cha(value):
		_cha.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class ThrowableComponent:
	func _init():
		var service
		
		_weight_factor = PBField.new("weight_factor", PB_DATA_TYPE.FLOAT, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.FLOAT])
		service = PBServiceField.new()
		service.field = _weight_factor
		data[_weight_factor.tag] = service
		
	var data = {}
	
	var _weight_factor
	func get_weight_factor():
		return _weight_factor.value
	func clear_weight_factor():
		_weight_factor.value = DEFAULT_VALUES_2[PB_DATA_TYPE.FLOAT]
	func set_weight_factor(value):
		_weight_factor.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class SkillsComponent:
	func _init():
		var service
		
		_skill_map = PBField.new("skill_map", PB_DATA_TYPE.MAP, PB_RULE.REPEATED, 1, false, [])
		service = PBServiceField.new()
		service.field = _skill_map
		service.func_ref = funcref(self, "add_empty_skill_map")
		data[_skill_map.tag] = service
		
	var data = {}
	
	var _skill_map
	func get_raw_skill_map():
		return _skill_map.value
	func get_skill_map():
		return PBPacker.construct_map(_skill_map.value)
	func clear_skill_map():
		_skill_map.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MAP]
	func add_empty_skill_map():
		var element = SkillsComponent.map_type_skill_map.new()
		_skill_map.value.append(element)
		return element
	func add_skill_map(a_key, a_value):
		var idx = -1
		for i in range(_skill_map.value.size()):
			if _skill_map.value[i].get_key() == a_key:
				idx = i
				break
		var element = SkillsComponent.map_type_skill_map.new()
		element.set_key(a_key)
		element.set_value(a_value)
		if idx != -1:
			_skill_map.value[idx] = element
		else:
			_skill_map.value.append(element)
	
	class map_type_skill_map:
		func _init():
			var service
			
			_key = PBField.new("key", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
			service = PBServiceField.new()
			service.field = _key
			data[_key.tag] = service
			
			_value = PBField.new("value", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
			service = PBServiceField.new()
			service.field = _value
			data[_value.tag] = service
			
		var data = {}
		
		var _key
		func get_key():
			return _key.value
		func clear_key():
			_key.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
		func set_key(value):
			_key.value = value
		
		var _value
		func get_value():
			return _value.value
		func clear_value():
			_value.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
		func set_value(value):
			_value.value = value
		
		func to_string():
			return PBPacker.message_to_string(data)
			
		func to_bytes():
			return PBPacker.pack_message(data)
			
		func from_bytes(bytes, offset = 0, limit = -1):
			var cur_limit = bytes.size()
			if limit != -1:
				cur_limit = limit
			var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
			if result == cur_limit:
				if PBPacker.check_required(data):
					if limit == -1:
						return PB_ERR.NO_ERRORS
				else:
					return PB_ERR.REQUIRED_FIELDS
			elif limit == -1 && result > 0:
				return PB_ERR.PARSE_INCOMPLETE
			return result
		
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class BodyPartsComponent:
	func _init():
		var service
		
		_head = PBField.new("head", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _head
		data[_head.tag] = service
		
		_chest = PBField.new("chest", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _chest
		data[_chest.tag] = service
		
		_left_arm = PBField.new("left_arm", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _left_arm
		data[_left_arm.tag] = service
		
		_right_arm = PBField.new("right_arm", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _right_arm
		data[_right_arm.tag] = service
		
		_left_leg = PBField.new("left_leg", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 5, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _left_leg
		data[_left_leg.tag] = service
		
		_right_leg = PBField.new("right_leg", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 6, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _right_leg
		data[_right_leg.tag] = service
		
	var data = {}
	
	var _head
	func get_head():
		return _head.value
	func clear_head():
		_head.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_head(value):
		_head.value = value
	
	var _chest
	func get_chest():
		return _chest.value
	func clear_chest():
		_chest.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_chest(value):
		_chest.value = value
	
	var _left_arm
	func get_left_arm():
		return _left_arm.value
	func clear_left_arm():
		_left_arm.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_left_arm(value):
		_left_arm.value = value
	
	var _right_arm
	func get_right_arm():
		return _right_arm.value
	func clear_right_arm():
		_right_arm.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_right_arm(value):
		_right_arm.value = value
	
	var _left_leg
	func get_left_leg():
		return _left_leg.value
	func clear_left_leg():
		_left_leg.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_left_leg(value):
		_left_leg.value = value
	
	var _right_leg
	func get_right_leg():
		return _right_leg.value
	func clear_right_leg():
		_right_leg.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_right_leg(value):
		_right_leg.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class InitiativeComponent:
	func _init():
		var service
		
		_initiative = PBField.new("initiative", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _initiative
		data[_initiative.tag] = service
		
	var data = {}
	
	var _initiative
	func get_initiative():
		return _initiative.value
	func clear_initiative():
		_initiative.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_initiative(value):
		_initiative.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class DoorComponent:
	func _init():
		var service
		
		_locked = PBField.new("locked", PB_DATA_TYPE.BOOL, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL])
		service = PBServiceField.new()
		service.field = _locked
		data[_locked.tag] = service
		
		_open_closed = PBField.new("open_closed", PB_DATA_TYPE.BOOL, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL])
		service = PBServiceField.new()
		service.field = _open_closed
		data[_open_closed.tag] = service
		
	var data = {}
	
	var _locked
	func get_locked():
		return _locked.value
	func clear_locked():
		_locked.value = DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL]
	func set_locked(value):
		_locked.value = value
	
	var _open_closed
	func get_open_closed():
		return _open_closed.value
	func clear_open_closed():
		_open_closed.value = DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL]
	func set_open_closed(value):
		_open_closed.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class ItemComponent:
	func _init():
		var service
		
		_weight = PBField.new("weight", PB_DATA_TYPE.FLOAT, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.FLOAT])
		service = PBServiceField.new()
		service.field = _weight
		data[_weight.tag] = service
		
		_itype = PBField.new("itype", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _itype
		data[_itype.tag] = service
		
	var data = {}
	
	var _weight
	func get_weight():
		return _weight.value
	func clear_weight():
		_weight.value = DEFAULT_VALUES_2[PB_DATA_TYPE.FLOAT]
	func set_weight(value):
		_weight.value = value
	
	var _itype
	func get_itype():
		return _itype.value
	func clear_itype():
		_itype.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_itype(value):
		_itype.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class LightComponent:
	func _init():
		var service
		
		_intensity = PBField.new("intensity", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _intensity
		data[_intensity.tag] = service
		
		_size = PBField.new("size", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _size
		data[_size.tag] = service
		
		_color = PBField.new("color", PB_DATA_TYPE.UINT32, PB_RULE.REPEATED, 3, false, [])
		service = PBServiceField.new()
		service.field = _color
		data[_color.tag] = service
		
	var data = {}
	
	var _intensity
	func get_intensity():
		return _intensity.value
	func clear_intensity():
		_intensity.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_intensity(value):
		_intensity.value = value
	
	var _size
	func get_size():
		return _size.value
	func clear_size():
		_size.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_size(value):
		_size.value = value
	
	var _color
	func get_color():
		return _color.value
	func clear_color():
		_color.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func add_color(value):
		_color.value.append(value)
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class DescriptionComponent:
	func _init():
		var service
		
		_description = PBField.new("description", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _description
		data[_description.tag] = service
		
	var data = {}
	
	var _description
	func get_description():
		return _description.value
	func clear_description():
		_description.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_description(value):
		_description.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class InventoryComponent:
	func _init():
		var service
		
		_capacity = PBField.new("capacity", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _capacity
		data[_capacity.tag] = service
		
		_stored_entities = PBField.new("stored_entities", PB_DATA_TYPE.STRING, PB_RULE.REPEATED, 2, false, [])
		service = PBServiceField.new()
		service.field = _stored_entities
		data[_stored_entities.tag] = service
		
		_weilded_in_main_hand = PBField.new("weilded_in_main_hand", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _weilded_in_main_hand
		data[_weilded_in_main_hand.tag] = service
		
		_weilded_in_secondary_hand = PBField.new("weilded_in_secondary_hand", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _weilded_in_secondary_hand
		data[_weilded_in_secondary_hand.tag] = service
		
		_equiped_in_head = PBField.new("equiped_in_head", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 5, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _equiped_in_head
		data[_equiped_in_head.tag] = service
		
		_equiped_in_chest = PBField.new("equiped_in_chest", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 6, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _equiped_in_chest
		data[_equiped_in_chest.tag] = service
		
		_equiped_in_hands = PBField.new("equiped_in_hands", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 7, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _equiped_in_hands
		data[_equiped_in_hands.tag] = service
		
		_equiped_in_legs = PBField.new("equiped_in_legs", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 8, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _equiped_in_legs
		data[_equiped_in_legs.tag] = service
		
		_equiped_misc = PBField.new("equiped_misc", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 9, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _equiped_misc
		data[_equiped_misc.tag] = service
		
	var data = {}
	
	var _capacity
	func get_capacity():
		return _capacity.value
	func clear_capacity():
		_capacity.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_capacity(value):
		_capacity.value = value
	
	var _stored_entities
	func get_stored_entities():
		return _stored_entities.value
	func clear_stored_entities():
		_stored_entities.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func add_stored_entities(value):
		_stored_entities.value.append(value)
	
	var _weilded_in_main_hand
	func get_weilded_in_main_hand():
		return _weilded_in_main_hand.value
	func clear_weilded_in_main_hand():
		_weilded_in_main_hand.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_weilded_in_main_hand(value):
		_weilded_in_main_hand.value = value
	
	var _weilded_in_secondary_hand
	func get_weilded_in_secondary_hand():
		return _weilded_in_secondary_hand.value
	func clear_weilded_in_secondary_hand():
		_weilded_in_secondary_hand.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_weilded_in_secondary_hand(value):
		_weilded_in_secondary_hand.value = value
	
	var _equiped_in_head
	func get_equiped_in_head():
		return _equiped_in_head.value
	func clear_equiped_in_head():
		_equiped_in_head.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_equiped_in_head(value):
		_equiped_in_head.value = value
	
	var _equiped_in_chest
	func get_equiped_in_chest():
		return _equiped_in_chest.value
	func clear_equiped_in_chest():
		_equiped_in_chest.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_equiped_in_chest(value):
		_equiped_in_chest.value = value
	
	var _equiped_in_hands
	func get_equiped_in_hands():
		return _equiped_in_hands.value
	func clear_equiped_in_hands():
		_equiped_in_hands.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_equiped_in_hands(value):
		_equiped_in_hands.value = value
	
	var _equiped_in_legs
	func get_equiped_in_legs():
		return _equiped_in_legs.value
	func clear_equiped_in_legs():
		_equiped_in_legs.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_equiped_in_legs(value):
		_equiped_in_legs.value = value
	
	var _equiped_misc
	func get_equiped_misc():
		return _equiped_misc.value
	func clear_equiped_misc():
		_equiped_misc.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_equiped_misc(value):
		_equiped_misc.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class ContainerComponent:
	func _init():
		var service
		
		_capacity = PBField.new("capacity", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _capacity
		data[_capacity.tag] = service
		
		_type = PBField.new("type", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _type
		data[_type.tag] = service
		
		_entities = PBField.new("entities", PB_DATA_TYPE.STRING, PB_RULE.REPEATED, 3, false, [])
		service = PBServiceField.new()
		service.field = _entities
		data[_entities.tag] = service
		
	var data = {}
	
	var _capacity
	func get_capacity():
		return _capacity.value
	func clear_capacity():
		_capacity.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_capacity(value):
		_capacity.value = value
	
	var _type
	func get_type():
		return _type.value
	func clear_type():
		_type.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_type(value):
		_type.value = value
	
	var _entities
	func get_entities():
		return _entities.value
	func clear_entities():
		_entities.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func add_entities(value):
		_entities.value.append(value)
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class StairsComponent:
	func _init():
		var service
		
		_to_level = PBField.new("to_level", PB_DATA_TYPE.INT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.INT32])
		service = PBServiceField.new()
		service.field = _to_level
		data[_to_level.tag] = service
		
	var data = {}
	
	var _to_level
	func get_to_level():
		return _to_level.value
	func clear_to_level():
		_to_level.value = DEFAULT_VALUES_2[PB_DATA_TYPE.INT32]
	func set_to_level(value):
		_to_level.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class FoodComponent:
	func _init():
		var service
		
		_nutrition = PBField.new("nutrition", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _nutrition
		data[_nutrition.tag] = service
		
	var data = {}
	
	var _nutrition
	func get_nutrition():
		return _nutrition.value
	func clear_nutrition():
		_nutrition.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_nutrition(value):
		_nutrition.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class FireComponent:
	func _init():
		var service
		
		_fire_power = PBField.new("fire_power", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _fire_power
		data[_fire_power.tag] = service
		
		_fire_duration = PBField.new("fire_duration", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _fire_duration
		data[_fire_duration.tag] = service
		
	var data = {}
	
	var _fire_power
	func get_fire_power():
		return _fire_power.value
	func clear_fire_power():
		_fire_power.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_fire_power(value):
		_fire_power.value = value
	
	var _fire_duration
	func get_fire_duration():
		return _fire_duration.value
	func clear_fire_duration():
		_fire_duration.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_fire_duration(value):
		_fire_duration.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class WeaponComponent:
	func _init():
		var service
		
		_weapon_type = PBField.new("weapon_type", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _weapon_type
		data[_weapon_type.tag] = service
		
		_damage_roll = PBField.new("damage_roll", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _damage_roll
		data[_damage_roll.tag] = service
		
		_range = PBField.new("range", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _range
		data[_range.tag] = service
		
		_use_cost = PBField.new("use_cost", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _use_cost
		data[_use_cost.tag] = service
		
		_attacks_per_round = PBField.new("attacks_per_round", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 5, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _attacks_per_round
		data[_attacks_per_round.tag] = service
		
		_reload_cost = PBField.new("reload_cost", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 6, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _reload_cost
		data[_reload_cost.tag] = service
		
	var data = {}
	
	var _weapon_type
	func get_weapon_type():
		return _weapon_type.value
	func clear_weapon_type():
		_weapon_type.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_weapon_type(value):
		_weapon_type.value = value
	
	var _damage_roll
	func get_damage_roll():
		return _damage_roll.value
	func clear_damage_roll():
		_damage_roll.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_damage_roll(value):
		_damage_roll.value = value
	
	var _range
	func get_range():
		return _range.value
	func clear_range():
		_range.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_range(value):
		_range.value = value
	
	var _use_cost
	func get_use_cost():
		return _use_cost.value
	func clear_use_cost():
		_use_cost.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_use_cost(value):
		_use_cost.value = value
	
	var _attacks_per_round
	func get_attacks_per_round():
		return _attacks_per_round.value
	func clear_attacks_per_round():
		_attacks_per_round.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_attacks_per_round(value):
		_attacks_per_round.value = value
	
	var _reload_cost
	func get_reload_cost():
		return _reload_cost.value
	func clear_reload_cost():
		_reload_cost.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_reload_cost(value):
		_reload_cost.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class ChunkComponent:
	func _init():
		var service
		
		_chunk = PBField.new("chunk", PB_DATA_TYPE.MESSAGE, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _chunk
		service.func_ref = funcref(self, "new_chunk")
		data[_chunk.tag] = service
		
	var data = {}
	
	var _chunk
	func get_chunk():
		return _chunk.value
	func clear_chunk():
		_chunk.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func new_chunk():
		_chunk.value = PBWorldChunk.new()
		return _chunk.value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class PBEntityPool:
	func _init():
		var service
		
		_entities = PBField.new("entities", PB_DATA_TYPE.MAP, PB_RULE.REPEATED, 1, false, [])
		service = PBServiceField.new()
		service.field = _entities
		service.func_ref = funcref(self, "add_empty_entities")
		data[_entities.tag] = service
		
		_actions = PBField.new("actions", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 2, false, [])
		service = PBServiceField.new()
		service.field = _actions
		service.func_ref = funcref(self, "add_actions")
		data[_actions.tag] = service
		
	var data = {}
	
	var _entities
	func get_raw_entities():
		return _entities.value
	func get_entities():
		return PBPacker.construct_map(_entities.value)
	func clear_entities():
		_entities.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MAP]
	func add_empty_entities():
		var element = PBEntityPool.map_type_entities.new()
		_entities.value.append(element)
		return element
	func add_entities(a_key):
		var idx = -1
		for i in range(_entities.value.size()):
			if _entities.value[i].get_key() == a_key:
				idx = i
				break
		var element = PBEntityPool.map_type_entities.new()
		element.set_key(a_key)
		if idx != -1:
			_entities.value[idx] = element
		else:
			_entities.value.append(element)
		return element.new_value()
	
	var _actions
	func get_actions():
		return _actions.value
	func clear_actions():
		_actions.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func add_actions():
		var element = PBAction.new()
		_actions.value.append(element)
		return element
	
	class map_type_entities:
		func _init():
			var service
			
			_key = PBField.new("key", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
			service = PBServiceField.new()
			service.field = _key
			data[_key.tag] = service
			
			_value = PBField.new("value", PB_DATA_TYPE.MESSAGE, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE])
			service = PBServiceField.new()
			service.field = _value
			service.func_ref = funcref(self, "new_value")
			data[_value.tag] = service
			
		var data = {}
		
		var _key
		func get_key():
			return _key.value
		func clear_key():
			_key.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
		func set_key(value):
			_key.value = value
		
		var _value
		func get_value():
			return _value.value
		func clear_value():
			_value.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
		func new_value():
			_value.value = PBEntity.new()
			return _value.value
		
		func to_string():
			return PBPacker.message_to_string(data)
			
		func to_bytes():
			return PBPacker.pack_message(data)
			
		func from_bytes(bytes, offset = 0, limit = -1):
			var cur_limit = bytes.size()
			if limit != -1:
				cur_limit = limit
			var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
			if result == cur_limit:
				if PBPacker.check_required(data):
					if limit == -1:
						return PB_ERR.NO_ERRORS
				else:
					return PB_ERR.REQUIRED_FIELDS
			elif limit == -1 && result > 0:
				return PB_ERR.PARSE_INCOMPLETE
			return result
		
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class PBComponent:
	func _init():
		var service
		
		_type = PBField.new("type", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _type
		data[_type.tag] = service
		
		_data = PBField.new("data", PB_DATA_TYPE.BYTES, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.BYTES])
		service = PBServiceField.new()
		service.field = _data
		data[_data.tag] = service
		
	var data = {}
	
	var _type
	func get_type():
		return _type.value
	func clear_type():
		_type.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_type(value):
		_type.value = value
	
	var _data
	func get_data():
		return _data.value
	func clear_data():
		_data.value = DEFAULT_VALUES_2[PB_DATA_TYPE.BYTES]
	func set_data(value):
		_data.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class PBAction:
	func _init():
		var service
		
		_action_id = PBField.new("action_id", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _action_id
		data[_action_id.tag] = service
		
		_name = PBField.new("name", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _name
		data[_name.tag] = service
		
		_component_type = PBField.new("component_type", PB_DATA_TYPE.STRING, PB_RULE.REPEATED, 3, false, [])
		service = PBServiceField.new()
		service.field = _component_type
		data[_component_type.tag] = service
		
		_description = PBField.new("description", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _description
		data[_description.tag] = service
		
		_type = PBField.new("type", PB_DATA_TYPE.STRING, PB_RULE.REPEATED, 5, false, [])
		service = PBServiceField.new()
		service.field = _type
		data[_type.tag] = service
		
		_range = PBField.new("range", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 6, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _range
		data[_range.tag] = service
		
		_states = PBField.new("states", PB_DATA_TYPE.UINT32, PB_RULE.REPEATED, 7, false, [])
		service = PBServiceField.new()
		service.field = _states
		data[_states.tag] = service
		
		_execute = PBField.new("execute", PB_DATA_TYPE.UINT32, PB_RULE.OPTIONAL, 8, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _execute
		data[_execute.tag] = service
		
		_animation = PBField.new("animation", PB_DATA_TYPE.STRING, PB_RULE.OPTIONAL, 9, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _animation
		data[_animation.tag] = service
		
		_priority = PBField.new("priority", PB_DATA_TYPE.UINT32, PB_RULE.REQUIRED, 10, false, DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32])
		service = PBServiceField.new()
		service.field = _priority
		data[_priority.tag] = service
		
		_auto = PBField.new("auto", PB_DATA_TYPE.BOOL, PB_RULE.REQUIRED, 11, false, DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL])
		service = PBServiceField.new()
		service.field = _auto
		data[_auto.tag] = service
		
		_turn_time = PBField.new("turn_time", PB_DATA_TYPE.FLOAT, PB_RULE.REQUIRED, 12, false, DEFAULT_VALUES_2[PB_DATA_TYPE.FLOAT])
		service = PBServiceField.new()
		service.field = _turn_time
		data[_turn_time.tag] = service
		
	var data = {}
	
	var _action_id
	func get_action_id():
		return _action_id.value
	func clear_action_id():
		_action_id.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_action_id(value):
		_action_id.value = value
	
	var _name
	func get_name():
		return _name.value
	func clear_name():
		_name.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_name(value):
		_name.value = value
	
	var _component_type
	func get_component_type():
		return _component_type.value
	func clear_component_type():
		_component_type.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func add_component_type(value):
		_component_type.value.append(value)
	
	var _description
	func get_description():
		return _description.value
	func clear_description():
		_description.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_description(value):
		_description.value = value
	
	var _type
	func get_type():
		return _type.value
	func clear_type():
		_type.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func add_type(value):
		_type.value.append(value)
	
	var _range
	func get_range():
		return _range.value
	func clear_range():
		_range.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_range(value):
		_range.value = value
	
	var _states
	func get_states():
		return _states.value
	func clear_states():
		_states.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func add_states(value):
		_states.value.append(value)
	
	var _execute
	func get_execute():
		return _execute.value
	func clear_execute():
		_execute.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_execute(value):
		_execute.value = value
	
	var _animation
	func get_animation():
		return _animation.value
	func clear_animation():
		_animation.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_animation(value):
		_animation.value = value
	
	var _priority
	func get_priority():
		return _priority.value
	func clear_priority():
		_priority.value = DEFAULT_VALUES_2[PB_DATA_TYPE.UINT32]
	func set_priority(value):
		_priority.value = value
	
	var _auto
	func get_auto():
		return _auto.value
	func clear_auto():
		_auto.value = DEFAULT_VALUES_2[PB_DATA_TYPE.BOOL]
	func set_auto(value):
		_auto.value = value
	
	var _turn_time
	func get_turn_time():
		return _turn_time.value
	func clear_turn_time():
		_turn_time.value = DEFAULT_VALUES_2[PB_DATA_TYPE.FLOAT]
	func set_turn_time(value):
		_turn_time.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class PBEntity:
	func _init():
		var service
		
		_entity_id = PBField.new("entity_id", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _entity_id
		data[_entity_id.tag] = service
		
		_name = PBField.new("name", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _name
		data[_name.tag] = service
		
		_components = PBField.new("components", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 3, false, [])
		service = PBServiceField.new()
		service.field = _components
		service.func_ref = funcref(self, "add_components")
		data[_components.tag] = service
		
	var data = {}
	
	var _entity_id
	func get_entity_id():
		return _entity_id.value
	func clear_entity_id():
		_entity_id.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_entity_id(value):
		_entity_id.value = value
	
	var _name
	func get_name():
		return _name.value
	func clear_name():
		_name.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_name(value):
		_name.value = value
	
	var _components
	func get_components():
		return _components.value
	func clear_components():
		_components.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func add_components():
		var element = PBComponent.new()
		_components.value.append(element)
		return element
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class PBMapCoordinate:
	func _init():
		var service
		
		_x = PBField.new("x", PB_DATA_TYPE.INT32, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.INT32])
		service = PBServiceField.new()
		service.field = _x
		data[_x.tag] = service
		
		_y = PBField.new("y", PB_DATA_TYPE.INT32, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.INT32])
		service = PBServiceField.new()
		service.field = _y
		data[_y.tag] = service
		
		_z = PBField.new("z", PB_DATA_TYPE.INT32, PB_RULE.REQUIRED, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.INT32])
		service = PBServiceField.new()
		service.field = _z
		data[_z.tag] = service
		
	var data = {}
	
	var _x
	func get_x():
		return _x.value
	func clear_x():
		_x.value = DEFAULT_VALUES_2[PB_DATA_TYPE.INT32]
	func set_x(value):
		_x.value = value
	
	var _y
	func get_y():
		return _y.value
	func clear_y():
		_y.value = DEFAULT_VALUES_2[PB_DATA_TYPE.INT32]
	func set_y(value):
		_y.value = value
	
	var _z
	func get_z():
		return _z.value
	func clear_z():
		_z.value = DEFAULT_VALUES_2[PB_DATA_TYPE.INT32]
	func set_z(value):
		_z.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class PBRect:
	func _init():
		var service
		
		_top_left = PBField.new("top_left", PB_DATA_TYPE.MESSAGE, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _top_left
		service.func_ref = funcref(self, "new_top_left")
		data[_top_left.tag] = service
		
		_bottom_right = PBField.new("bottom_right", PB_DATA_TYPE.MESSAGE, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _bottom_right
		service.func_ref = funcref(self, "new_bottom_right")
		data[_bottom_right.tag] = service
		
	var data = {}
	
	var _top_left
	func get_top_left():
		return _top_left.value
	func clear_top_left():
		_top_left.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func new_top_left():
		_top_left.value = PBMapCoordinate.new()
		return _top_left.value
	
	var _bottom_right
	func get_bottom_right():
		return _bottom_right.value
	func clear_bottom_right():
		_bottom_right.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func new_bottom_right():
		_bottom_right.value = PBMapCoordinate.new()
		return _bottom_right.value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class PBTilemap:
	func _init():
		var service
		
		_name = PBField.new("name", PB_DATA_TYPE.STRING, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.STRING])
		service = PBServiceField.new()
		service.field = _name
		data[_name.tag] = service
		
		_rect = PBField.new("rect", PB_DATA_TYPE.MESSAGE, PB_RULE.REQUIRED, 2, false, DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _rect
		service.func_ref = funcref(self, "new_rect")
		data[_rect.tag] = service
		
		_level = PBField.new("level", PB_DATA_TYPE.INT32, PB_RULE.REQUIRED, 3, false, DEFAULT_VALUES_2[PB_DATA_TYPE.INT32])
		service = PBServiceField.new()
		service.field = _level
		data[_level.tag] = service
		
		_data = PBField.new("data", PB_DATA_TYPE.BYTES, PB_RULE.REQUIRED, 4, false, DEFAULT_VALUES_2[PB_DATA_TYPE.BYTES])
		service = PBServiceField.new()
		service.field = _data
		data[_data.tag] = service
		
		_type = PBField.new("type", PB_DATA_TYPE.INT32, PB_RULE.REQUIRED, 5, false, DEFAULT_VALUES_2[PB_DATA_TYPE.INT32])
		service = PBServiceField.new()
		service.field = _type
		data[_type.tag] = service
		
	var data = {}
	
	var _name
	func get_name():
		return _name.value
	func clear_name():
		_name.value = DEFAULT_VALUES_2[PB_DATA_TYPE.STRING]
	func set_name(value):
		_name.value = value
	
	var _rect
	func get_rect():
		return _rect.value
	func clear_rect():
		_rect.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func new_rect():
		_rect.value = PBRect.new()
		return _rect.value
	
	var _level
	func get_level():
		return _level.value
	func clear_level():
		_level.value = DEFAULT_VALUES_2[PB_DATA_TYPE.INT32]
	func set_level(value):
		_level.value = value
	
	var _data
	func get_data():
		return _data.value
	func clear_data():
		_data.value = DEFAULT_VALUES_2[PB_DATA_TYPE.BYTES]
	func set_data(value):
		_data.value = value
	
	var _type
	func get_type():
		return _type.value
	func clear_type():
		_type.value = DEFAULT_VALUES_2[PB_DATA_TYPE.INT32]
	func set_type(value):
		_type.value = value
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class PBWorldChunk:
	func _init():
		var service
		
		_coord = PBField.new("coord", PB_DATA_TYPE.MESSAGE, PB_RULE.REQUIRED, 1, false, DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE])
		service = PBServiceField.new()
		service.field = _coord
		service.func_ref = funcref(self, "new_coord")
		data[_coord.tag] = service
		
		_tilemap = PBField.new("tilemap", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 2, false, [])
		service = PBServiceField.new()
		service.field = _tilemap
		service.func_ref = funcref(self, "add_tilemap")
		data[_tilemap.tag] = service
		
	var data = {}
	
	var _coord
	func get_coord():
		return _coord.value
	func clear_coord():
		_coord.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func new_coord():
		_coord.value = PBMapCoordinate.new()
		return _coord.value
	
	var _tilemap
	func get_tilemap():
		return _tilemap.value
	func clear_tilemap():
		_tilemap.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func add_tilemap():
		var element = PBTilemap.new()
		_tilemap.value.append(element)
		return element
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
class PBWorld:
	func _init():
		var service
		
		_chunks = PBField.new("chunks", PB_DATA_TYPE.MESSAGE, PB_RULE.REPEATED, 1, false, [])
		service = PBServiceField.new()
		service.field = _chunks
		service.func_ref = funcref(self, "add_chunks")
		data[_chunks.tag] = service
		
	var data = {}
	
	var _chunks
	func get_chunks():
		return _chunks.value
	func clear_chunks():
		_chunks.value = DEFAULT_VALUES_2[PB_DATA_TYPE.MESSAGE]
	func add_chunks():
		var element = PBWorldChunk.new()
		_chunks.value.append(element)
		return element
	
	func to_string():
		return PBPacker.message_to_string(data)
		
	func to_bytes():
		return PBPacker.pack_message(data)
		
	func from_bytes(bytes, offset = 0, limit = -1):
		var cur_limit = bytes.size()
		if limit != -1:
			cur_limit = limit
		var result = PBPacker.unpack_message(data, bytes, offset, cur_limit)
		if result == cur_limit:
			if PBPacker.check_required(data):
				if limit == -1:
					return PB_ERR.NO_ERRORS
			else:
				return PB_ERR.REQUIRED_FIELDS
		elif limit == -1 && result > 0:
			return PB_ERR.PARSE_INCOMPLETE
		return result
	
################ USER DATA END #################
