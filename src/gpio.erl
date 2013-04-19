%%%---- BEGIN COPYRIGHT -------------------------------------------------------
%%%
%%% Copyright (C) 2013 Feuerlabs, Inc. All rights reserved.
%%%
%%% This Source Code Form is subject to the terms of the Mozilla Public
%%% License, v. 2.0. If a copy of the MPL was not distributed with this
%%% file, You can obtain one at http://mozilla.org/MPL/2.0/.
%%%
%%%---- END COPYRIGHT ---------------------------------------------------------
%%% @author Magnus Feuer <magnus@feuerlabs.com>
%%% @author Tony Rogvall <tony@rogvall.se>
%%% @author Malotte W L�nne <malotte@malotte.net>
%%% @copyright (C) 2013, Feuerlabs, Inc.
%%% @doc
%%%  GPIO interface
%%%
%%% Created: 2012 by Magnus Feuer 
%%% @end

-module(gpio).
-include("gpio.hrl").

%% Basic api
-export([init/1,
	 release/1,
	 set/1, 
	 clr/1, 
	 get/1,
	 input/1,
	 output/1,
	 set_direction/2,
	 get_direction/1]).

%% Extended api
%%-export([set_pin/2]).
-export([set_mask/1,
	 clr_mask/1,
	 set_mask/2,
	 clr_mask/2]).

%% Port commands
%% MUST BE EQUAL TO DEFINES IN gpio_drv.c !!!!
-define (CMD_INIT,1).
-define (CMD_SET, 2).
-define (CMD_CLR, 3).
-define (CMD_GET, 4).
-define (CMD_SET_DIRECTION, 5).
-define (CMD_GET_DIRECTION, 6).
-define (CMD_SET_MASK, 7).
-define (CMD_CLR_MASK, 8).
-define (CMD_RELEASE, 9).

-define(DIR_IN, 1).
-define(DIR_OUT, 2).
-define(DIR_LOW, 3).
-define(DIR_HIGH, 4).

%%====================================================================
%% API
%%====================================================================

%%--------------------------------------------------------------------
%% @doc
%% Inits pin in pin register 0, i.e. prepares it for use.
%% @end
%%--------------------------------------------------------------------
-spec gpio:init(Pin::unsigned()) -> ok | {error,Reason::posix()}.
init(Pin) 
  when is_integer(Pin), Pin >= 0 ->
    call(?GPIO_PORT, ?CMD_INIT, <<0:8, Pin:8>>).


%%--------------------------------------------------------------------
%% @doc
%% Releases pin in pin register 0.
%% @end
%%--------------------------------------------------------------------
-spec gpio:release(Pin::unsigned()) -> ok | {error,Reason::posix()}.
release(Pin) 
  when is_integer(Pin), Pin >= 0 ->
    call(?GPIO_PORT, ?CMD_RELEASE, <<0:8, Pin:8>>).


%%--------------------------------------------------------------------
%% @doc
%% Sets pin in pin register 0, i.e. sets it to 1.
%% @end
%%--------------------------------------------------------------------
-spec gpio:set(Pin::unsigned())  -> ok | {error,Reason::posix()}.
set(Pin) 
  when is_integer(Pin), Pin >= 0 ->
    call(?GPIO_PORT, ?CMD_SET, <<0:8, Pin:8>>).

%%--------------------------------------------------------------------
%% @doc
%% Clears pinin pin register 0, i.e. sets it to 0.
%% @end
%%--------------------------------------------------------------------
-spec gpio:clr(Pin::unsigned())  -> ok | {error,Reason::posix()}.
clr(Pin) 
  when is_integer(Pin), Pin >= 0 ->
    call(?GPIO_PORT, ?CMD_CLR, <<0:8, Pin:8>>).

%%--------------------------------------------------------------------
%% @doc
%% Gets value for pin in pin register 0.
%% @end
%%--------------------------------------------------------------------
-spec gpio:get(Pin::unsigned()) -> boolean().
get(Pin) 
  when is_integer(Pin), Pin >= 0 ->
    call(?GPIO_PORT, ?CMD_GET, <<0:8, Pin:8>>).

%%--------------------------------------------------------------------
%% @doc
%% Sets direction in for pin in pin register 0.
%% @end
%%--------------------------------------------------------------------
-spec gpio:input(Pin::unsigned()) -> ok | {error,Reason::posix()}.

input(Pin) ->
    set_direction(Pin,in).

%%--------------------------------------------------------------------
%% @doc
%% Sets direction out for pin in pin register 0.
%% @end
%%--------------------------------------------------------------------
-spec gpio:output(Pin::unsigned()) -> ok | {error,Reason::posix()}.

output(Pin) ->
    set_direction(Pin,out).

%%--------------------------------------------------------------------
%% @doc
%% Sets direction for pin in pin register 0.
%% @end
%%--------------------------------------------------------------------
-spec gpio:set_direction(Pin::unsigned(),
			 Dir::in | out | high | low) ->
				ok | {error,Reason::posix()}.

set_direction(Pin,in) when is_integer(Pin), Pin >= 0 ->
    call(?GPIO_PORT, ?CMD_SET_DIRECTION, <<0:8,Pin:8,?DIR_IN>>);
set_direction(Pin,out) when is_integer(Pin), Pin >= 0 ->
    call(?GPIO_PORT, ?CMD_SET_DIRECTION, <<0:8,Pin:8,?DIR_OUT>>);
set_direction(Pin,high) when is_integer(Pin), Pin >= 0 ->
    call(?GPIO_PORT, ?CMD_SET_DIRECTION, <<0:8,Pin:8,?DIR_HIGH>>);
set_direction(Pin,low) when is_integer(Pin), Pin >= 0 ->
    call(?GPIO_PORT, ?CMD_SET_DIRECTION, <<0:8,Pin:8,?DIR_LOW>>).

%%--------------------------------------------------------------------
%% @doc
%% Gets direction for pin in pin register 0.
%% @end
%%--------------------------------------------------------------------
-spec gpio:get_direction(Pin::unsigned()) -> ok | {error,Reason::posix()}.

get_direction(Pin) 
  when is_integer(Pin), Pin >= 0 ->
    call(?GPIO_PORT, ?CMD_GET_DIRECTION, <<0:8, Pin:8>>).

%% extended api

%%--------------------------------------------------------------------
-spec gpio:set_mask(Mask::unsigned()) -> ok | {error,Reason::posix()}.
set_mask(Mask) 
  when is_integer(Mask), Mask >= 0 ->
    call(?GPIO_PORT, ?CMD_SET_MASK, <<0:8, Mask:8>>).

%%--------------------------------------------------------------------
-spec gpio:clr_mask(Mask::unsigned()) -> ok | {error,Reason::posix()}.
clr_mask(Mask) 
  when is_integer(Mask), Mask >= 0 ->
    call(?GPIO_PORT, ?CMD_CLR_MASK, <<0:8, Mask:8>>).

%%--------------------------------------------------------------------
-spec gpio:set_mask(PinReg::unsigned(), Mask::unsigned()) ->
			        ok | {error,Reason::posix()}.
set_mask(PinReg, Mask) 
  when is_integer(PinReg), PinReg >= 0, is_integer(Mask), Mask >= 0 ->
    call(?GPIO_PORT, ?CMD_SET_MASK, <<PinReg:8, Mask:8>>).

%%--------------------------------------------------------------------
-spec gpio:clr_mask(PinReg::unsigned(), Mask::unsigned()) ->
			       ok | {error,Reason::posix()}.
clr_mask(PinReg, Mask) 
  when is_integer(PinReg), PinReg >= 0, is_integer(Mask), Mask >= 0 ->
    call(?GPIO_PORT, ?CMD_CLR_MASK, <<PinReg:8, Mask:8>>).

%%--------------------------------------------------------------------
%% Internal functions
%%--------------------------------------------------------------------
call(Port, Cmd, Data) ->
    case erlang:port_control(Port, Cmd, Data) of
	<<0>> ->
	    ok;
	<<255,E/binary>> -> 
	    {error, erlang:binary_to_atom(E, latin1)};
	<<1,Y>> -> {ok,Y};
	<<2,Y:16/native-unsigned>> -> {ok, Y};
	<<4,Y:32/native-unsigned>> -> {ok, Y};
	<<3,Return/binary>> -> {ok,Return}
    end.
