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

with Ahven; use Ahven;

with Opus;

use Opus;

package body Test_Opus is

   Unexpected_Version_Message : constant String := "Unexpected version";

   overriding
   procedure Initialize (T : in out Test) is
   begin
      T.Set_Name ("Opus");

      T.Add_Test_Routine (Test_Version'Access,  "Test version");
   end Initialize;

   procedure Test_Version is
      Version : constant String := Get_Version;
   begin
      Assert (Version'Length > 7 and then Version (1 .. 7) = "libopus", Unexpected_Version_Message);
   end Test_Version;

end Test_Opus;
