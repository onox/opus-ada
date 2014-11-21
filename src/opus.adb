--  Copyright (c) 2014 onox <denkpadje@gmail.com>
--
--  Permission to use, copy, modify, and/or distribute this software for any
--  purpose with or without fee is hereby granted, provided that the above
--  copyright notice and this permission notice appear in all copies.
--
--  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
--  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
--  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
--  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
--  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
--  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
--  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

with Interfaces.C.Strings;

package body Opus is

   function Get_Version return String is
      function Opus_Get_Version_String return Interfaces.C.Strings.chars_ptr
         with Import, Convention => C, External_Name => "opus_get_version_string";
   begin
      return Interfaces.C.Strings.Value (Opus_Get_Version_String);
   end Get_Version;

   procedure Check_Error (Error : in Interfaces.C.int) is
   begin
      case Error is
         when -1 => raise Bad_Argument;
         when -2 => raise Buffer_Too_Small;
         when -3 => raise Internal_Error;
         when -4 => raise Invalid_Packet;
         when -5 => raise Unimplemented;
         when -6 => raise Invalid_State;
         when -7 => raise Allocation_Fail;
         when others => null;
      end case;
   end Check_Error;

end Opus;
