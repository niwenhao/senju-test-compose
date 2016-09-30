# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

commands:

    rails g model SenjuEnv logonUser:string hostName:string
    rails g model ShellTask command:string expected:integer
    rails g model SenjuJob name:string description:string command:string expected:integer senjuEnv:references task:references{polymorphic} preExec:references{polymorphic} postExec:references{polymorphic}
    rails g model SenjuNet name:string description:string senjuEnv:references preExec:references{polymorphic} postExec:references{polymorphic}
    rails g model SenjuTriger name:string description:string node:string path:string postExec:references{polymorphic}
    rails g model SenjuSuccession left:references right:references task:references{polymorphic}
    rails g model NetReference senjuNet:references senjuObject:references{polymorphic}
    rails g migration AddEnvToNetReference senjuEnv:references
    rails g migration AddNameToSenjuEnv name:string:index
    rails g migration AddNameIndexToSenjuJob name:index
