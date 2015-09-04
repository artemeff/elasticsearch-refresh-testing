-module(rt).
-export([start/0, s/0]).

start() ->
    application:ensure_all_started(rt).

s() ->
    start().
