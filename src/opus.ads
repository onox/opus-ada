--  Copyright (c) 2010-2011 Xiph.Org Foundation, Skype Limited
--
--  Most of the documentation has been copied from opus.h and opus_defines.h
--  and is licensed under the license of those files; the Simplified BSD License.
--
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

with Interfaces.C;

package Opus is

   --  The Opus codec is designed for interactive speech and audio
   --  transmission over the Internet. It is designed by the IETF Codec
   --  Working Group and incorporates technology from Skype's SILK codec
   --  and Xiph.Org's CELT codec.
   --
   --  The Opus codec is designed to handle a wide range of interactive
   --  audio applications, including Voice over IP, videoconferencing,
   --  in-game chat, and even remote live music performances. It can scale
   --  from low bit-rate narrowband speech to very high quality stereo
   --  music. Its main features are:
   --
   --  * Sampling rates from 8 to 48 kHz
   --  * Bit-rates from 6 kb/s to 510 kb/s
   --  * Support for both constant bit-rate (CBR) and variable bit-rate (VBR)
   --  * Audio bandwidth from narrowband to full-band
   --  * Support for speech and music
   --  * Support for mono and stereo
   --  * Support for multichannel (up to 255 channels)
   --  * Frame sizes from 2.5 ms to 60 ms
   --  * Good loss robustness and packet loss concealment (PLC)
   --  * Floating point and fixed-point implementation

   type Channel_Type is (Mono, Stereo);

   type Application_Type is (VoIP, Audio, Restricted_Low_Delay)
      with Convention => C;
   --  1. VOIP gives best quality at a given bitrate for voice signals. It
   --  enhances the input signal by high-pass filtering and forward error
   --  correction to protect against packet loss. Use this mode for typical
   --  VoIP applications. Because of the enhancement, even at high bitrates
   --  the output may sound different from the input.
   --
   --  2. Audio gives best quality at a given bitrate for most non-voice
   --  signals like music. Use this mode for music and mixed (music/voice)
   --  content, broadcast, and applications requiring less than 15 ms of
   --  coding delay.
   --
   --  3. Restricted_Low_Delay configures low-delay mode that disables the
   --  speech-optimized mode in exchange for slightly reduced delay. This
   --  mode can only be set on an newly initialized or freshly reset encoder
   --  because it changes the codec delay. This is useful when the caller knows
   --  that the speech-optimized modes will not be needed (use with caution).

   type Sampling_Rate is (Rate_8_kHz, Rate_12_kHz, Rate_16_kHz, Rate_24_kHz, Rate_48_kHz)
      with Convention => C;

   type Bandwidth is (Auto, Narrow_Band, Medium_Band, Wide_Band, Super_Wide_Band, Full_Band)
      with Convention => C;

   type Opus_Int16 is new Interfaces.C.short;

   subtype PCM_Range is Natural range 0 .. 5760;
   --   8 kHz with 2.5 ms/frame mono   =   20 samples/frame
   --  48 kHz with  60 ms/frame stereo = 5760 samples/frame

   use type Interfaces.C.int;

   type PCM_Buffer is array (PCM_Range range <>) of Opus_Int16
      with Convention => C;

   type Byte_Array is array (Natural range <>) of Interfaces.C.unsigned_char
      with Convention => C;

   function Get_Version return String;

   Bad_Argument     : exception;
   Buffer_Too_Small : exception;
   Internal_Error   : exception;
   Invalid_Packet   : exception;
   Unimplemented    : exception;
   Invalid_State    : exception;
   Allocation_Fail  : exception;

   Invalid_Result   : exception;

private

   type C_Boolean is new Boolean
      with Convention => C;

   for Channel_Type use
     (Mono   => 1,
      Stereo => 2);

   for Application_Type use
     (VoIP                 => 2048,
      Audio                => 2049,
      Restricted_Low_Delay => 2051);

   for Sampling_Rate use
     (Rate_8_kHz  =>  8000,
      Rate_12_kHz => 12000,
      Rate_16_kHz => 16000,
      Rate_24_kHz => 24000,
      Rate_48_kHz => 48000);

   for Bandwidth use
     (Auto            => -1000,
      Narrow_Band     =>  1101,
      Medium_Band     =>  1102,
      Wide_Band       =>  1103,
      Super_Wide_Band =>  1104,
      Full_Band       =>  1105);

   procedure Check_Error (Error : in Interfaces.C.int);

end Opus;
