--  SPDX-License-Identifier: Apache-2.0 AND BSD-2-Clause
--
--  Copyright (c) 2010-2011 Xiph.Org Foundation, Skype Limited
--
--  Most of the documentation has been copied from opus.h and opus_defines.h
--  and is licensed under the license of those files; the Simplified BSD License.
--
--  Copyright (c) 2014 - 2022 onox <denkpadje@gmail.com>
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.

private with System;

package Opus.Decoders is
   pragma Preelaborate;

   type Decoder_Data is private;
   --  A single codec state may only be accessed from a single thread at
   --  a time and any required locking must be performed by the caller.
   --  Separate streams must be decoded with separate decoder states and
   --  can be decoded in parallel unless the Opus library was compiled
   --  with NONTHREADSAFE_PSEUDOSTACK defined.

   type Q8_dB is new Interfaces.C.int range -32768 .. 32767;

   function Create
     (Frequency : in Sampling_Rate;
      Channels  : in Channel_Type) return Decoder_Data;
   --  Create and return an Opus decoder

   procedure Destroy (Decoder : in Decoder_Data);

   function Decode
     (Decoder    : in Decoder_Data;
      Data       : in Byte_Array;
      Max_Samples_Per_Channel : in Positive;
      Decode_FEC : in Boolean) return PCM_Buffer;
   --  If Data = null or Decode_FEC is true then Frame_Size must be a
   --  multiple of 2.5 ms.

   procedure Reset_State (Decoder : in Decoder_Data);
   --  Resets the codec state to be equivalent to a freshly initialized
   --  state. This should be called when switching streams in order to
   --  prevent the back to back decoding from giving different results
   --  from one at a time decoding.

   function Get_Bandwidth (Decoder : in Decoder_Data) return Bandwidth;
   --  Gets the decoder's last bandpass.
   --
   --  Raises No_Packets_Decoded if no packets have been decoded yet.

   function Get_Channels (Decoder : in Decoder_Data) return Channel_Type;
   --  Return the number of channels that the decoder expects. The returned
   --  value is a mandatory argument to the Create function.

   procedure Set_Gain
     (Decoder : in Decoder_Data;
      Factor  : in Q8_dB);
   --  Set decoder gain adjustment, which is the amount to scale the PCM
   --  signal by in Q8 dB units.
   --
   --  Scales the decoded output by a factor specified in Q8 dB units.
   --  The default is zero indicating no adjustment. This setting survives
   --  decoder reset.
   --
   --  gain = pow(10, factor / (20.0 * 256))

   function Get_Gain (Decoder : in Decoder_Data) return Q8_dB;
   --  Gets the decoder's configured gain adjustment, which is the amount
   --  to scale the PCM signal by in Q8 dB units.

   function Get_Pitch (Decoder : in Decoder_Data) return Integer;
   --  Gets the pitch period at 48 kHz of the last decoded frame, or
   --  0 if not available.
   --
   --  This can be used for any post-processing algorithm requiring the
   --  use of pitch, e.g. time stretching/shortening. If the last frame
   --  was not voiced, or if the pitch was not coded in the frame, then
   --  zero is returned.

   function Get_Final_Range (Decoder : in Decoder_Data) return Integer;
   --  Gets the final state of the codec's entropy coder.
   --
   --  This is used for testing purposesr. The encoder and decoder state
   --  should be identical after coding a payload (assuming no data
   --  corruption or software bugs)

   function Get_Sample_Rate (Decoder : in Decoder_Data) return Sampling_Rate;
   --  Return the sampling rate the decoder was initialized with

   function Get_Last_Packet_Duration (Decoder : in Decoder_Data) return Natural;
   --  Return the duration (number of samples at current sampling rate)
   --  of the last packet successfully decoded or concealed.

   No_Packets_Decoded : exception;

private

   type Opus_Decoder is access System.Address
     with Storage_Size => 0;

   type Decoder_Data is record
      Decoder  : Opus_Decoder;
      Channels : Channel_Type;
   end record;

end Opus.Decoders;
