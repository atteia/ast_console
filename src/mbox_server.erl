%%% File    : mbox_server.erl
%%% Author  : Dominique Boucher <>
%%% Description : 
%%% Created : 28 Aug 2011 by Dominique Boucher <>

-module(mbox_server).

-include("ast_mgr.hrl").

-export([start_link/0, start_link/2]).
-export([handle_req/1]).


start_link() ->
    {ok, {Host, Port}} = application:get_env(ast_console, http_listen),
    start_link(Host, Port).

start_link(Host, Port) ->
    mochiweb_http:start([{loop, {?MODULE, handle_req}}, {ip, Host}, {port, Port}]).

handle_req(Req) ->
    handle_req(Req, Req:get(method), Req:get(path)).

handle_req(Req, 'GET', "/mbox") ->
    case lists:keyfind("mbox", 1, Req:parse_qs()) of 
        {_, MboxName} ->
	    {ok, #mbox_count{new_messages = NewMessages}} = ast_manager:mailbox_count(MboxName),
            Req:ok({"application/json", [], mochijson2:encode({struct, [{<<"count">>, NewMessages}]})});
        _ ->
            Req:not_found()            
    end;
handle_req(Req, _, _) ->
    Req:not_found().

        
     
