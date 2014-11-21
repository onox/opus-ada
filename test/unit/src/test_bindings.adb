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

with Ahven.Framework; use Ahven.Framework;
with Ahven.Text_Runner;

with Test_Encoders;
with Test_Decoders;
with Test_Opus;

procedure Test_Bindings is
   Suite : Test_Suite := Create_Suite ("all");
begin
   Suite.Add_Test (new Test_Encoders.Test);
   Suite.Add_Test (new Test_Decoders.Test);
   Suite.Add_Test (new Test_Opus.Test);

   Ahven.Text_Runner.Run (Suite);
end Test_Bindings;
