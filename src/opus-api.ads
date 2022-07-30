--  SPDX-License-Identifier: Apache-2.0
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

with Interfaces.C.Strings;
with System;

private package Opus.API is
   pragma Preelaborate;

   type Opus_Decoder is access System.Address
     with Storage_Size => 0;

   type Opus_Encoder is access System.Address
     with Storage_Size => 0;

   type Get_Request_Type_Decoder is
     (Get_Bandwidth_Request,
      Get_Sample_Rate_Request,
      Get_Final_Range_Request,
      Get_Pitch_Request,
      Get_Last_Packet_Duration_Request,
      Get_Gain_Request)
   with Convention => C;

   type Set_Request_Type_Decoder is
     (Set_Gain_Request)
   with Convention => C;

   type Get_Request_Type_Encoder is
     (Get_Application_Request,
      Get_Bitrate_Request,
      Get_Max_Bandwidth_Request,
      Get_VBR_Request,
      Get_Bandwidth_Request,
      Get_Complexity_Request,
      Get_Inband_FEC_Request,
      Get_Packet_Loss_Request,
      Get_DTX_Request,
      Get_VBR_Constraint_Request,
      Get_Force_Channels_Request,
      Get_Signal_Request,
      Get_Lookahead_Request,
      Get_Sample_Rate_Request,
      Get_Final_Range_Request,
      Get_LSB_Depth_Request,
      Get_Expert_Frame_Duration_Request,
      Get_Prediction_Disabled_Request)
   with Convention => C;

   type Set_Request_Type_Encoder is
     (Set_Application_Request,
      Set_Bitrate_Request,
      Set_Max_Bandwidth_Request,
      Set_VBR_Request,
      Set_Bandwidth_Request,
      Set_Complexity_Request,
      Set_Inband_FEC_Request,
      Set_Packet_Loss_Request,
      Set_DTX_Request,
      Set_VBR_Constraint_Request,
      Set_Force_Channels_Request,
      Set_Signal_Request,
      Reset_State,
      Set_LSB_Depth_Request,
      Set_Expert_Frame_Duration_Request,
      Set_Prediction_Disabled_Request)
   with Convention => C;

   function Get_Version_String return Interfaces.C.Strings.chars_ptr
      with Import, Convention => C, External_Name => "opus_get_version_string";

   function Decoder_Create
     (Frequency : Sampling_Rate;
      Channels  : Channel_Type;
      Error     : out Interfaces.C.int) return Opus_Decoder
   with Import, Convention => C, External_Name => "opus_decoder_create";

   procedure Decoder_Destroy (Decoder : Opus_Decoder)
      with Import, Convention => C, External_Name => "opus_decoder_destroy";

   function Decode
     (State     : Opus_Decoder;
      Data      : Byte_Array;
      Data_Size : Integer;
      Audio_Frame : out PCM_Buffer;
      Samples_Per_Channel : Integer;
      Decode_FEC : C_Boolean) return Interfaces.C.int
   with Import, Convention => C, External_Name => "opus_decode";

   function Encoder_Create
     (Frequency   : Sampling_Rate;
      Channels    : Channel_Type;
      Application : Application_Type;
      Error       : out Interfaces.C.int) return Opus_Encoder
   with Import, Convention => C, External_Name => "opus_encoder_create";

   procedure Encoder_Destroy (Encoder : Opus_Encoder)
     with Import, Convention => C, External_Name => "opus_encoder_destroy";

   function Encode
     (State      : Opus_Encoder;
      Frame      : PCM_Buffer;
      Frame_Size : Interfaces.C.int;
      Data       : out Byte_Array;
      Data_Size  : Integer) return Interfaces.C.int
   with Import, Convention => C, External_Name => "opus_encode";

private

   for Get_Request_Type_Decoder use
     (Get_Bandwidth_Request            => 4009,
      Get_Sample_Rate_Request          => 4029,
      Get_Final_Range_Request          => 4031,
      Get_Pitch_Request                => 4033,
      Get_Last_Packet_Duration_Request => 4039,
      Get_Gain_Request                 => 4045);
   for Get_Request_Type_Decoder'Size use Interfaces.C.int'Size;

   for Set_Request_Type_Decoder use
     (Set_Gain_Request => 4034);
   for Set_Request_Type_Decoder'Size use Interfaces.C.int'Size;

   for Get_Request_Type_Encoder use
     (Get_Application_Request           => 4001,
      Get_Bitrate_Request               => 4003,
      Get_Max_Bandwidth_Request         => 4005,
      Get_VBR_Request                   => 4007,
      Get_Bandwidth_Request             => 4009,
      Get_Complexity_Request            => 4011,
      Get_Inband_FEC_Request            => 4013,
      Get_Packet_Loss_Request           => 4015,
      Get_DTX_Request                   => 4017,
      Get_VBR_Constraint_Request        => 4021,
      Get_Force_Channels_Request        => 4023,
      Get_Signal_Request                => 4025,
      Get_Lookahead_Request             => 4027,
      Get_Sample_Rate_Request           => 4029,
      Get_Final_Range_Request           => 4031,
      Get_LSB_Depth_Request             => 4037,
      Get_Expert_Frame_Duration_Request => 4041,
      Get_Prediction_Disabled_Request   => 4043);
   for Get_Request_Type_Encoder'Size use Interfaces.C.int'Size;

   for Set_Request_Type_Encoder use
     (Set_Application_Request           => 4000,
      Set_Bitrate_Request               => 4002,
      Set_Max_Bandwidth_Request         => 4004,
      Set_VBR_Request                   => 4006,
      Set_Bandwidth_Request             => 4008,
      Set_Complexity_Request            => 4010,
      Set_Inband_FEC_Request            => 4012,
      Set_Packet_Loss_Request           => 4014,
      Set_DTX_Request                   => 4016,
      Set_VBR_Constraint_Request        => 4020,
      Set_Force_Channels_Request        => 4022,
      Set_Signal_Request                => 4024,
      Reset_State                       => 4028,
      Set_LSB_Depth_Request             => 4036,
      Set_Expert_Frame_Duration_Request => 4040,
      Set_Prediction_Disabled_Request   => 4042);
   for Set_Request_Type_Encoder'Size use Interfaces.C.int'Size;

end Opus.API;
