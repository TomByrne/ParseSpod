# ParseSpod

ParseSpod is an Haxe library for generating client-side API code for Parse Servers.

This is done in two steps:

- Download Application schema from Parse Server
- Combine Application schema and a set of templates to generate API code

Both of these steps are run from the command line using the `haxelib run` command (which allows commands from an installed library to be run).

Note that, while this library is Haxe focused, as you can specify your own templates, you can generate Parse API code for any language.

For deeper information, check out the [wiki](https://github.com/TomByrne/ParseSpod/wiki).

## Download Application schema from Parse Server

ParseSpod downloads your Parse Application's schema using the `load-parse` command.

```
haxelib run ParseSpod load-parse host=https://myserver.com/ restKey=XXXX masterKey=XXXX name=AppName
```

Running this command from the root directory of your project should result in a file called `EscapeRoom.schema.json` in your project root (you can change where it is saved using the `dest` argument).

**Note:** The `name` argument is not currently used for any server interactions, just for information in template generation. That said, it's recommended to keep it matching your actual AppName in case the 'multi-app' functionality gets reinstated in Parse Server (see bottom).

## Generate API code

ParseSpod generates your Client API code using the [standard Haxe templating system](https://haxe.org/manual/std-template.html).

To generate the default Client API from your schema, run the `make` command in your project root (where you downloaded your schema):

```
haxelib run ParseSpod make package=my.package.parseApi dest=src
```

In this command `package` is the package that the generated files should be in, and `dest` is the class path where that package should be updated/created.

There are two template sets included with ParseSpod:

- **standard** is the default set of templates embedded in the ParseSpod tool, which you can [see here](https://github.com/TomByrne/ParseSpod/tree/master/templates/standard). These templates are the default and will be used if no template directory is specified.
- **abstract** is a set of templates embedded in the ParseSpod tool, which you can [see here](https://github.com/TomByrne/ParseSpod/tree/master/templates/abstract). These templates use Haxe abstracts heavily, the goal of which is to consume minimal memory and allocate few objects, even when working with large data sets. The downside of this is that reflection will not work as expected on these objects.

Both of these templates use the same underlying functionality for loading/saving. Their signatures are intentionally the same for easy swapping.

To use your own folder of templates, use the `templates` argument, like this:

```
haxelib run ParseSpod make package=imagsyd.reception.model.parseApi dest=src templates=assets/templates
```

You can also run `make` in verbose mode, which will give information on files being generated, like this:

```
haxelib run ParseSpod make package=imagsyd.reception.model.parseApi dest=src verbose=true
```

By default, `make` will process all files in the current working directory ending with `.schema.json`.

If you want to specify a different folder to search, use this argument `dir=assets/parseSchemas`.

If you want to specify specific schema files to process, use this argument `files=assets/App1.schema.json,App2.schema.json`.

### Parse Server Legacy

The old closed-source Parse Server had a meta-level which allowed you to have multiple Applications on one server. This made it easier for tools like ParseSpod to get information about your Parse Apps (REST keys, etc). Since this level is removed in the open-source version of the Parse Server, ParseSpod requires a little more info from the user to do it's work. If the meta-level gets reinstated at some point it should be fairly easy to revert to the old method.