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

with Opus.API;

package body Opus is

   function Get_Version return String is
   begin
      return Interfaces.C.Strings.Value (Opus.API.Get_Version_String);
   end Get_Version;

   procedure Check_Error (Error : Interfaces.C.int) is
   begin
      case Error is
         when  0 => null;
         when -1 => raise Bad_Argument;
         when -2 => raise Buffer_Too_Small;
         when -3 => raise Internal_Error;
         when -4 => raise Invalid_Packet;
         when -5 => raise Unimplemented;
         when -6 => raise Invalid_State;
         when -7 => raise Allocation_Fail;
         when others => raise Program_Error;
      end case;
   end Check_Error;

end Opus;
