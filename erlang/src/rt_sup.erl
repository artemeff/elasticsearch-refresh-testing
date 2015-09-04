-module(rt_sup).
-behaviour(supervisor).
-include("rt.hrl").
-export([ start_link/0
        , init/1
        ]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Worker = ?CHILD(rt_spawner, rt_spawner, worker, []),
    {ok, {{one_for_all, 0, 1}, [Worker]}}.
