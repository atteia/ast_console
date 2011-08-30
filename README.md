Asterisk voicemail and call history extension for Chrome
========================================================

This project contains a Chrome extension and associated runtime to display 
Asterisk voicemail notifications and access the call history.

Requirements
------------

- [Asterisk](http://www.asterisk.org), with a manager interface (AMI) account.
- [Erlang](http://www.erlang.org) R14B or higher.
- [rebar](http://github.com/basho/rebar) for compiling.
- [couchdb](http://couchdb.apache.org) with a `calls` database already created.

Installing
----------

To compile the runtime system, execute the following commands at the
shell prompt:

    % rebar get-deps
    % rebar compile generate

Before starting the runtime system, edit the configuration file in
`rel/ast_console/etc/app.config`. Then start the system by executing
the following command:

    % rel/ast_console/bin/ast_console start


In Google Chrome, install the extension from the `extension`
directory, then right-click on the extension's icon and select
"Options". Complete the information on the configuration page and
click "Save".

Author
------

Dominique Boucher, Nu Echo Inc. 