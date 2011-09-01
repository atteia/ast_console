%%% File    : channel_events.erl
%%% Author  : Dominique Boucher <>
%%% Description : Channel event handlers
%%% Created : 22 Aug 2010 by Dominique Boucher <>

-module(asterisk_events).

-export([start_link/0]).
-export([init/1, terminate/2, handle_event/2]).

-include("ast_mgr.hrl").

-record(conf, {couchdb, ignore_list}).


start_link() ->
    {ok, {Host, Port}} = application:get_env(ast_console, ami_host),
    {ok, {Username, Password}} = application:get_env(ast_console, ami_credentials),
    {ok, {CouchHost, CouchPort}} = application:get_env(ast_console, couchdb_host),
    {ok, IgnoreList} = application:get_env(ast_console, ignore_list),
    Args = [#conf{couchdb = {CouchHost, CouchPort}, ignore_list = IgnoreList}],
    Result = ast_manager:start_link(?MODULE, Host, Port, Args),
    ast_manager:login(Username, Password),
    Result.


init([Conf = #conf{}]) ->
    error_logger:info_msg("Starting channel_events~n", []),
    {ok, Conf}.

terminate(_Reason, _Conf) ->
    error_logger:info_msg("Terminating channel_events~n", []),
    ok.

handle_event({'Newstate', #ast_state{caller_id = CallerId, 
                                     state_desc = 'Up',
                                     caller_id_name = CallerName,
                                     unique_id = Id}}, 
	     Conf) ->
    save_call(Conf,
              info(Id),
	      info(CallerId),
	      info(CallerName),
	      tuple_to_list(date()) ++ tuple_to_list(time())),
    {ok, Conf};

handle_event(_Event,Conf) ->
    {ok,Conf}.


save_call(#conf{couchdb = {CouchHost, CouchPort}, ignore_list = IgnoreList}, 
          Id, CallerId, CallerName, TimeStamp) ->
    case lists:member(CallerId, IgnoreList) of
	false ->
            Doc = {[{<<"_id">>, Id},
                    {<<"callerid">>, CallerId},
                    {<<"callernum">>, CallerName},
                    {<<"timestamp">>, TimeStamp}]},
	    Conn = couchbeam:server_connection(CouchHost, CouchPort),
	    {ok, Db} = couchbeam:open_db(Conn, "calls"),
	    {ok, _NewDoc} = couchbeam:save_doc(Db, Doc);
	_ ->
	    ok
    end.
    
info(undefined) ->
    <<"">>;
info(L)
  when is_list(L) ->
    list_to_binary(L).
