-include_lib("erlastic_search/include/erlastic_search.hrl").

-define(SPAWN_INTERVAL, 10). % in ms
-define(SPAWN_COUNTER, 10). % N of spawns at every SPAWN_INTERVAL
-define(COLLECT_INTERVAL, 1000). % 1 sec
-define(CHILD(Name, Module, Type, Args),
    {Name, {Module, start_link, Args}, permanent, 5000, Type, [Module]}).

-define(INDEX, <<"refresh-test">>).
-define(TYPE,  <<"messages">>).

-define(CONNECTION, #erls_params{host = <<"188.166.26.174">>}).


%% UUID
%% Variant, corresponds to variant 1 0 of RFC 4122.
-define(VARIANT10, 2#10).
%% Version
-define(UUIDv4, 4).
