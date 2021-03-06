%%%-------------------------------------------------------------------
%%% @copyright (C) 2013-2014, 2600Hz
%%% @doc
%%%
%%% @end
%%% @contributors
%%%-------------------------------------------------------------------
-module(teletype_sup).

-behaviour(supervisor).

-export([start_link/0
         ,render_farm_name/0
        ]).
-export([init/1]).

-include("teletype.hrl").

-define(POOL_NAME, 'teletype_render_farm').
-define(POOL_SIZE, whapps_config:get_integer(?APP_NAME, <<"render_farm_workers">>, 20)).
-define(POOL_OVERFLOW, 0).

-define(POOL_ARGS, [[{'worker_module', 'teletype_renderer'}
                     ,{'name', {'local', ?POOL_NAME}}
                     ,{'size', ?POOL_SIZE}
                     ,{'max_overflow', ?POOL_OVERFLOW}
                    ]]).

%% Helper macro for declaring children of supervisor
-define(CHILDREN, [?CACHE('teletype_cache')
                   ,?WORKER_NAME_ARGS('poolboy', ?POOL_NAME, ?POOL_ARGS)
                   ,?WORKER('teletype_listener')
                   ,?WORKER('teletype_shared_listener')
                  ]).

%% ===================================================================
%% API functions
%% ===================================================================

%%--------------------------------------------------------------------
%% @public
%% @doc
%% Starts the supervisor
%% @end
%%--------------------------------------------------------------------
-spec start_link() -> startlink_ret().
start_link() ->
    supervisor:start_link({'local', ?MODULE}, ?MODULE, []).

-spec render_farm_name() -> ?POOL_NAME.
render_farm_name() ->
    ?POOL_NAME.

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

%%--------------------------------------------------------------------
%% @public
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%% @end
%%--------------------------------------------------------------------
-spec init([]) -> sup_init_ret().
init([]) ->
    RestartStrategy = 'one_for_one',
    MaxRestarts = 5,
    MaxSecondsBetweenRestarts = 10,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    {'ok', {SupFlags, ?CHILDREN}}.
