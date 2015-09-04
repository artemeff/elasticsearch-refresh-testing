-module(rt_spawner).
-include("rt.hrl").
-export([ start_link/0
        , init/1
        , handle_call/3
        , handle_cast/2
        , handle_info/2
        , terminate/2
        , code_change/3
        ]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    init_timer(),
    {ok, []}.

handle_call(_Req, _From, State) ->
    {noreply, State}.

handle_cast(_Req, State) ->
    {noreply, State}.

handle_info(init, State) ->
    lists:foreach(fun(_) ->
        spawn(fun() ->
            Msg = generate_message(),
            % UID = lists:keyfind(<<"user_id">>, 1, Msg),

            {ok, _} = insert(Msg),
            {ok, RefreshResult} = refresh(),
            % {ok, SearchResult} = search(UID),

            % {_, Shards} = lists:keyfind(<<"_shards">>, 1, RefreshResult),
            % {_, Total}  = lists:keyfind(<<"total">>, 1, Shards),
            % {_, Succs}  = lists:keyfind(<<"successful">>, 1, Shards),

            % {_, Hits1} = lists:keyfind(<<"hits">>, 1, SearchResult),
            % {_, Hits2} = lists:keyfind(<<"hits">>, 1, Hits1),

            % SearchResultCount = length(Hits2),

            % case Total =:= Succs of
            %     true ->
            %         ok;
            %     false ->
            %         io:format("ERROR shards total `~p`, successful `~p`~n", [Total, Succs])
            % end,

            % case SearchResultCount of
            %     0 ->
            %         io:format("ERROR in search~n", []);
            %     _ ->
            %         ok
            % end,

            io:format(".")
        end)
    end, lists:seq(0, ?SPAWN_COUNTER)),
    init_timer(),
    {noreply, State};
handle_info(_, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% helpers

insert(Body) ->
    erlastic_search:index_doc(?CONNECTION, ?INDEX, ?TYPE, Body).

refresh() ->
    erlastic_search:refresh_index(?CONNECTION, ?INDEX).

search(UserId) ->
    erlastic_search:search(?CONNECTION, ?INDEX, ?TYPE, search_query(UserId), []).

search_query(UserId) ->
    [{<<"query">>, [{<<"match">>, [{<<"user_id">>, UserId}]}]}].

init_timer() ->
    erlang:send_after(?SPAWN_INTERVAL, self(), init).

generate_message() ->
    [ {<<"user_id">>, uuid4()}
    , {<<"owner">>,   <<"John Doe">>}
    , {<<"text">>,    <<"test">>}
    , {<<"date">>,    iso8601:now()}
    ].

uuid4() ->
    <<U0:32, U1:16, _:4, U2:12, _:2, U3:30, U4:32>> = crypto:rand_bytes(16),
    <<U0:32, U1:16, ?UUIDv4:4, U2:12, ?VARIANT10:2, U3:30, U4:32>>.
