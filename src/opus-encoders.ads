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

package Opus.Encoders is
   pragma Preelaborate;

   type Encoder_Data is private;

   type Percentage is new Interfaces.C.int range 0 .. 100;

   type Signal_Depth is new Interfaces.C.int range 8 .. 24;
   --  Depth of signal in bits. Helps the encoder to identify silence and
   --  near-silence.

   type Frame_Duration is
     (Argument,
      Frame_2_5_ms,
      Frame_5_ms,
      Frame_10_ms,
      Frame_20_ms,
      Frame_40_ms,
      Frame_60_ms)
--      Variable)
   with
      Convention => C;

   type Complexity is new Interfaces.C.int range 1 .. 10;
   --  1 is the lowest complexity and 10 the highest

   type Signal is (Auto, Voice, Music)
      with Convention => C;

   Minimum_Bitrate        : constant :=     500;
   Maximum_Stereo_Bitrate : constant := 600_000;
   Maximum_Mono_Bitrate   : constant := 300_000;

   type Bitrate is range Minimum_Bitrate .. Maximum_Stereo_Bitrate;
   --  Bitrate in bits per second

   type Bitrate_Type is (Auto, Maximum)
      with Convention => C;

   type Force_Channels is (Auto, Mono, Stereo)
      with Convention => C;

   subtype Bandpass is Bandwidth range Narrow_Band .. Full_Band;

   function Create
     (Frequency   : in Sampling_Rate;
      Channels    : in Channel_Type;
      Application : in Application_Type) return Encoder_Data;
   --  Create and return an Opus encoder.
   --
   --  Regardless of the sampling rate and number channels selected, the
   --  Opus encoder can switch to a lower audio bandwidth or number of
   --  channels if the bitrate selected is too low. This also means that
   --  it is safe to always use 48 kHz stereo input and let the encoder
   --  optimize the encoding.

   procedure Destroy (Encoder : in Encoder_Data);

   function Encode
     (Encoder        : in Encoder_Data;
      Audio_Frame    : in PCM_Buffer;
      Max_Data_Bytes : in Positive) return Byte_Array;
   --  Encode exactly one frame (2.5, 5, 10, 20, 40, or 60 ms) of audio data.
   --  Returns the length of the encoded packet (in bytes) on success.
   --
   --  Frame size is the duration of the frame in samples (per channel)
   --
   --  Max_Data_Bytes is the maximum number of bytes that can be written in
   --  the packet (4000 bytes is recommended). Do not use it to control
   --  VBR target bitrate, instead use Set_Bitrate.

   procedure Reset_State (Encoder : in Encoder_Data);
   --  Resets the codec state to be equivalent to a freshly initialized
   --  state. This should be called when switching streams in order to
   --  prevent the back to back decoding from giving different results
   --  from one at a time decoding.

   procedure Set_Application
     (Encoder     : in Encoder_Data;
      Application : in Application_Type);
   --  Set the encoder's intended application. The initial value
   --  is a mandatory argument to the Create function.
   --
   --  VoIP:
   --     Process signal for improved speech intelligibility. Best for most
   --     VoIP/videoconference applications where listening quality and
   --     intelligibility matter most.
   --  Audio:
   --     Favor faithfulness to the original input. Best for
   --     broadcast/high-fidelity application where the decoded audio should
   --     be as close as possible to the input.
   --  Low_Delay:
   --     Configure the minimum possible coding delay by disabling
   --     voice-optimized mode of operation. To be used when
   --     lowest-achievable latency is what matters most.

   function Get_Application (Encoder : in Encoder_Data) return Application_Type;
   --  Return the encoder's configured application

   procedure Set_Bitrate
     (Encoder : in Encoder_Data;
      Rate    : in Bitrate)
   with
      Pre => (if Get_Channels (Encoder) = Mono then
                 Rate <= Maximum_Mono_Bitrate);
   --  Set bitrate in bits per second (b/s)

   function Get_Bitrate (Encoder : in Encoder_Data) return Bitrate;
   --  Return the encoder's bitrate in bits per second (b/s). If the
   --  result is invalid, the bitrate has been set to Maximum.
   --
   --  The default is determined based on the number of channels and the
   --  input sampling rate.

   procedure Set_Bitrate
     (Encoder : in Encoder_Data;
      Rate    : in Bitrate_Type);
   --  Set bitrate to automatic or the maximum bitrate

   procedure Set_Bandwidth
     (Encoder : in Encoder_Data;
      Width   : in Bandwidth);
   --  Set the encoder's bandpass to a specific value or configure the
   --  encoder to automatically (default) select the bandpass based on
   --  the available bitrate.
   --
   --  This prevents the encoder from automatically selecting the bandpass
   --  based on the available bitrate. If an application knows the bandpass
   --  of the input audio it is providing, it should normally use
   --  Set_Max_Bandwidth instead, which still gives the encoder the freedom
   --  to reduce the bandpass when the bitrate becomes too low, for better
   --  overall quality.

   function Get_Bandwidth (Encoder : in Encoder_Data) return Bandwidth;
   --  Return the encoder's configured bandpass

   procedure Set_Max_Bandwidth
     (Encoder : in Encoder_Data;
      Width   : in Bandpass);
   --  Set the maximum bandpass that the encoder will select automatically.
   --  The default is Full_Band.
   --
   --  Applications should normally use this instead of Set_Bandwidth
   --  (leaving that set to the default, Auto). This allows the
   --  application to set an upper bound based on the type of input it is
   --  providing, but still gives the encoder the freedom to reduce the bandpass
   --  when the bitrate becomes too low, for better overall quality.

   function Get_Max_Bandwidth (Encoder : in Encoder_Data) return Bandpass;
   --  Return the encoder's configured maximum allowed bandpass

   function Get_Channels (Encoder : in Encoder_Data) return Channel_Type;
   --  Return the number of channels that the encoder uses. The returned
   --  value is a mandatory argument to the Create function.

   procedure Set_Complexity
     (Encoder : in Encoder_Data;
      Scale   : in Complexity);
   --  Set the encoder's computational complexity

   function Get_Complexity (Encoder : in Encoder_Data) return Complexity;
   --  Return the encoder's complexity

   procedure Set_DTX
     (Encoder : in Encoder_Data;
      Enable  : in Boolean);
   --  Enable or disable (default) the encoder's use of discontinuous
   --  transmission (DTX).
   --  Note: This is only applicable to the LPC layer.

   function Get_DTX (Encoder : in Encoder_Data) return Boolean;
   --  Return the encoder's configured use of discontinuous transmission

   procedure Set_Force_Channels
     (Encoder  : in Encoder_Data;
      Channels : in Force_Channels);
   --  Force mono or stereo in the encoder.
   --
   --  This can force the encoder to produce packets encoded as either
   --  mono or stereo, regardless of the format of the input audio. This
   --  is useful when the caller knows that the input signal is currently
   --  a mono source embedded in a stereo stream.

   function Get_Force_Channels (Encoder : in Encoder_Data) return Force_Channels;
   --  Return the encoder's forced channel configuration

   procedure Set_Inband_FEC
     (Encoder : in Encoder_Data;
      Enable  : in Boolean);
   --  Enable or disable (default) the encoder's use of inband forward
   --  error correction (FEC).
   --  Note: This is only applicable to the LPC layer.

   function Get_Inband_FEC (Encoder : in Encoder_Data) return Boolean;
   --  Return encoder's configured use of inband forward error correction

   procedure Set_LSB_Depth
     (Encoder : in Encoder_Data;
      Depth   : in Signal_Depth);
   --  Set the depth (default is 24 bits) of signal being encoded. This
   --  is a hint which helps the encoder identify silence and near-silence.

   function Get_LSB_Depth (Encoder : in Encoder_Data) return Signal_Depth;
   --  Return the encoder's configured signal depth

   procedure Set_Packet_Loss
     (Encoder       : in Encoder_Data;
      Expected_Loss : in Percentage);
   --  Set the encoder's expected packet loss percentage. Higher values
   --  will trigger progressively more loss resistant behavior in the
   --  encoder at the expense of quality at a given bitrate in the
   --  lossless case, but greater quality under loss.

   function Get_Packet_Loss (Encoder : in Encoder_Data) return Percentage;
   --  Return the encoder's configured packet loss percentage

   procedure Set_Prediction_Disabled
     (Encoder : in Encoder_Data;
      Disable : in Boolean);
   --  Disable or enable (default) almost all use of prediction, making
   --  frames almost completely independent. This reduces quality.

   function Get_Prediction_Disabled (Encoder : in Encoder_Data) return Boolean;
   --  Return the encoder's configured prediction status

   procedure Set_Signal
     (Encoder : in Encoder_Data;
      Hint    : in Signal);
   --  Set the type of signal being encoded. This is a hint which
   --  helps the encoder's mode selection.
   --
   --  Voice:
   --     Bias thresholds towards choosing LPC or Hybrid modes.
   --  Music:
   --     Bias thresholds towards choosing MDCT modes.

   function Get_Signal (Encoder : in Encoder_Data) return Signal;
   --  Return the encoder's configured signal type

   procedure Set_VBR
     (Encoder : in Encoder_Data;
      Enable  : in Boolean);
   --  Enable or disable variable bitrate (VBR) in the encoder.
   --
   --  If enabled then VBR (default) is used. The exact type of VBR is
   --  controlled by Set_VBR_Constraint.
   --
   --  If disabled then hard CBR is used. For LPC/hybrid modes at very low
   --  bit-rate, this can cause noticeable quality degradation.
   --  Warning: Only the MDCT mode of Opus can provide hard CBR behavior.

   function Get_VBR (Encoder : in Encoder_Data) return Boolean;
   --  Return whether variable bitrate (VBR) is enabled in the encoder

   procedure Set_VBR_Constraint
     (Encoder   : in Encoder_Data;
      Constrain : in Boolean);
   --  Enable or disable constrained VBR in the encoder. This setting is
   --  ignored when the encoder is in CBR mode.
   --
   --  Warning: Only the MDCT mode of Opus currently heeds the constraint.
   --  Speech mode ignores it completely, hybrid mode may fail to obey it
   --  if the LPC layer uses more bitrate than the constraint would have
   --  permitted.
   --
   --  If constrained (default) then this creates a maximum of one frame
   --  of buffering delay assuming a transport with a serialization speed
   --  of the nominal bitrate.

   function Get_VBR_Constraint (Encoder : in Encoder_Data) return Boolean;
   --  Determine if constrained VBR is enabled in the encoder

   procedure Set_Expert_Frame_Duration
     (Encoder  : in Encoder_Data;
      Duration : in Frame_Duration);
   --  Set the encoder's use of variable duration frames.
   --
   --  When variable duration is enabled, the encoder is free to use a
   --  shorter frame size than the one requested in the Encode call.
   --  It is then the user's responsibility to verify how much audio was
   --  encoded by checking the ToC byte of the encoded packet. The part
   --  of the audio that was not encoded needs to be resent to the
   --  encoder for the next call. Do not use this option unless you *really*
   --  know what you are doing.
   --
   --  Argument:
   --     Select frame size from the argument (default).
   --  Variable:
   --     Optimize the frame size dynamically.
   --  <duration in ms>:
   --     Use <duration in ms> frames.

   function Get_Expert_Frame_Duration (Encoder : in Encoder_Data) return Frame_Duration;
   --  Return the encoder's configured use of variable duration frames

   function Get_Final_Range (Encoder : in Encoder_Data) return Integer;
   --  Return the final state of the codec's entropy coder.
   --
   --  This is used for testing purposesr. The encoder and decoder state
   --  should be identical after coding a payload (assuming no data
   --  corruption or software bugs)

   function Get_Lookahead (Encoder : in Encoder_Data) return Positive;
   --  Return the total samples of delay added by the entire codec.
   --
   --  This can be queried by the encoder and then the provided number
   --  of samples can be skipped on from the start of the decoder's output
   --  to provide time aligned input and output. From the perspective of
   --  a decoding application the real data begins this many samples late.
   --
   --  The decoder contribution to this delay is identical for all decoders,
   --  but the encoder portion of the delay may vary from implementation
   --  to implementation, version to version, or even depend on the encoder's
   --  initial configuration. Applications needing delay compensation should
   --  call this rather than hard-coding a value.

   function Get_Sample_Rate (Encoder : in Encoder_Data) return Sampling_Rate;
   --  Return the sampling rate the encoder was initialized with

private

   type Opus_Encoder is access System.Address
     with Storage_Size => 0;

   type Encoder_Data is record
      Encoder  : Opus_Encoder;
      Channels : Channel_Type;
   end record;

   for Signal use
     (Auto  => -1000,
      Voice => 3001,
      Music => 3002);

   for Bitrate_Type use
     (Auto    => -1000,
      Maximum => -1);

   for Force_Channels use
     (Auto   => -1000,
      Mono   => 1,
      Stereo => 2);

   for Frame_Duration use
     (Argument     => 5000,
      Frame_2_5_ms => 5001,
      Frame_5_ms   => 5002,
      Frame_10_ms  => 5003,
      Frame_20_ms  => 5004,
      Frame_40_ms  => 5005,
      Frame_60_ms  => 5006);
--      Variable     => 5010);  --  OPUS_FRAMESIZE_VARIABLE is undefined in opus_defines.h

end Opus.Encoders;
