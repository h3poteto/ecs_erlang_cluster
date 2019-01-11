# ECSErlangCluster

This is a command line tool to create the Erlang cluster on AWS ECS. When start a ECS task, it needs `sys.config` and own identifier and IP address for Erlang cluster. Other nodes identifier and IP address are written in `sys.config`.

ECSErlangCluster command can get own identifier and IP address, and can generate `sys.config` which has sibling nodes identifier and IP address. So you only have to launch the application by passing the result of this command.

## Installation

This is an escript command, so you can install using mix command.

```bash
$ mix escript.install github h3poteto/ecs_erlang_cluster
* Getting new package (https://github.com/h3poteto/ecs_erlang_cluster.git)
remote: Enumerating objects: 93, done.
remote: Counting objects: 100% (93/93), done.
...
```
It will be installed in `~/.mix/escripts`, so please add this path in your `$PATH`.
