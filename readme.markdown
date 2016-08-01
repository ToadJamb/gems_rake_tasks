[![Build Status](https://travis-ci.org/ToadJamb/gems_rake_tasks.svg?branch=master)](https://travis-ci.org/ToadJamb/gems_rake_tasks)


Welcome to RakeTasks
====================

RakeTasks provides basic rake tasks for generating documentation,
building and installing gems, and running tests.

It will also load additional rake tasks
if they are in either `lib/tasks` or `tasks`.
That is the only thing this gem does unless
one of the included tasks is explicitly required.


Dependency Philosophy
---------------------

This gem potentially adds a number of (hopefully) useful tasks.
However, it is probably rare that a given project
will actually make use of all of them at once.
To that end, *dependencies are expected to be included by the application
that is consuming this gem*.

Per-task requirements are noted in the [Tasks][tasks] section below.


Getting Started
---------------

Install RakeTasks at the command prompt if you haven't yet:

    $ gem install rake\_tasks

Require the gem in your Gemfile:

    gem 'rake\_tasks', '~> 4.2.1'

Require the gem wherever you need to use it:
(This will load any \*.rake files in your project.)

    require 'rake\_tasks'

Require the tasks that you want to use:

    require 'rake\_tasks/tasks/spec'     # Run RSpec specs of different types
    require 'rake\_tasks/tasks/cane'     # Cane rake tasks
    require 'rake\_tasks/tasks/console'  # Load a library project in irb.
    require 'rake\_tasks/tasks/gem'      # Gem build, install, deploy, etc.
    require 'rake\_tasks/tasks/checksum' # Generate checksums for \*.gem file
    require 'rake\_tasks/tasks/doc'      # Generate readme
    require 'rake\_tasks/tasks/rdoc'     # Generate RDoc
    require 'rake\_tasks/tasks/test'     # Run TestUnit tests - may get removed
    require 'rake\_tasks/tasks/travis_ci_lint' # Lint .travis.yml
    require 'rake\_tasks/tasks/release'  # Prepare a gem (and repo) for release


Tasks
-----

Additional rake tasks will be found and loaded
if they are named \*.rake (as of 3.0.0)
and reside in either `lib/tasks` or  `tasks` (as of 4.0.0).

### Console Task

#### Requirements

This task looks for a folder under `lib` with a ruby (.rb extension) file
of the same name.


### Cane Tasks

#### Dependencies

* [Cane][cane]


### Gem Tasks

#### Dependencies

* [Gems][gems]


#### Requirements

* There is a valid .gemspec file in the root folder that is named the same
   as the root folder.


#### gem:push

`gem:push` requires that an environment variable
named `RUBYGEMS_API_KEY` is set.
This key is used to identify the author when pushing to rubygems.
After authenticating on the command line,
this value will be saved to `~/.gem/credentials`.


### Doc Tasks

#### Requirements

* There is a valid .gemspec file in the root folder that is named the same
   as the root folder.

* README generation uses the gemspec data to populate the license information.

  If readem.md does not exist, one will be created.
  If readem.md does exist, a readem\_GENERATED.md file will be created,
  so as not to overwrite a 'real' readem.md file.


### Test Tasks

* Tests reside in a folder named 'test', 'tests', or 'spec'
   and test files are named \*\_test.rb or test\_\*.rb.

   Additionally, if you have sub-folders under test(s)
   (i.e. test/unit, test/performance), they will be available
   using rake test:unit and rake test:performance.
   Sub-folders that do not contain files matching the test file name patterns
   will not be included in this set.

   You may run a single test from any test file by using the following:

    rake test:test\_file[test\_method]

   test\_file is the name of the test file without the pattern,
   so if you have a test named my\_class\_test.rb with a test method
   named my\_test\_method, it would be invoked by:

    rake test:my\_class[my\_test\_method]


### Travis CI Lint Tasks

#### Dependencies

* [Travis::Yaml][travis-yaml]


### Release Task

* [Gems][gems]

This task will do the following:

It is worth noting that the version bumping will strip out any part of versioning
where the string version does not match the number
(i.e. `1.3.2.pre-3.6` => `1.3.2.6`).

* Prompt you for a version number in this order:
  * The current version number.
  * Bump the lowest point. (i.e. 1.2.3.5.8 => 1.2.3.5.9)
  * Bump the minor number (i.e. 1.2.3.5.8 => 1.3.0.0.0)
  * Bump the major number (i.e. 1.2.3.5.8 => 2.0.0.0.0)
  * Enter the new number
* Updates the gemspec with that version number.
* Ensures Gemfile.lock is up to date (by running `bundle check`).
* Builds the gem
* Generates checksums
* For git repos only:
  * check in gemspec, Gemfile, Gemfile.lock, and checksums
  * commit with a message of "Version [new\_version]"
  * tag the commit with v[new\_version]


Useful Methods
--------------

### `RakeTasks.build_default_tasks`

This method allows you to run your 'default' task differently
in different environments.
This is generally not advisable,
but for libraries, it makes sense.
You want to check the code against multiple rubies/gemspecs,
which is easy to do with [wwtd][wwtd],
but ci (in particular [travisci][travisci]),
has no way to say
'run these things FIRST, then run these other things against different rubies'.

By telling [travisci][travisci] (or the ci of your choice)
to run `bundle exec rake base`,
you can now run `bundle exec rake` in development,
thus ensuring everything stays tested, but in more efficient ways.

This function should be invoked *AFTER* all rake tasks have been loaded.
Otherwise, some tasks/libraries, may decide to throw things into your
default task for you.
This method clears them all out, so you know exactly what you have
and you get exactly what you want.

This function builds those tasks for you. Let's look at the parameters.

The first three are all expected to be arrays of rake task names.

* reqs

These are the things that should be run only once where possible.
These tasks would be things like linters
that only need to be run once.

`RakeTasks` has this set to `[:cane, 'travis_ci:lint']`
(if `Travis` is loaded) and just `[:cane]`, if not.


* specs

These are the test/spec tasks that should be run in every environment specified.

`RakeTasks` sets this to `[:spec, 'test:unit']`.


* local

These are the tasks that will be run locally with a `bundle exec rake`.

`RakeTasks` sets this to `['wwtd:parallel']`.


* ci

Whether the tasks are being built for CI or not.

`RakeTasks` looks for the existence of `ENV['CI']`,
which [travisci][travisci] lists as an environment variable
that you can count on being set.


* base

The name of the base task.
This is the task that you should use in CI.

`RakeTasks` uses the default setting of `:base`.


* default

The name of the 'default' task.
Although, if you send it something other than `:default`,
it's not really the default task anymore, is it?

This is here for completion,
but probably best not overridden
unless you really know what you're doing and why.

`RakeTasks` uses the default setting of `:default`.


#### Summary

With all of those settings in place
and with `.travis.yml` set to run `bundle exec rake base`,
what happens is this:


##### Locally

    $ bundle exec rake

In the case of `RakeTasks`, this will run the prereqs,
stopping if any of them fail
(rather than having a failure for each matrix due to linting).
Then, it will run the specs in parallel.

    $ bundle exec rake base

In the case of `RakeTasks`, this will ONLY run the specs.


##### CI

    $ bundle exec rake

You probably shouldn't be running this on CI using these tasks.
Most likely, you can skip the overhead and just use the default rake task
in all environments.

For what it's worth, this will run the prereqs both prior to running
the matrix builds and during each one.
If you want that, just use the default rake task
and make it the same for all environments.


    $ bundle exec rake base

In the case of `RakeTasks`, this functions as a stand-alone full rake.
It will have all pre-requisites, plus run the specs.


Updates
-------

    4.2.0 Added travis_ci:lint task.

          Added checksums rake task.
          It generates three checksums: sha256, sha512, and md5.

          Added release rake task.

          Added RakeTasks.build_default_tasks.

    4.1.0 Added console task.

    4.0.0 Added gem:push.

          Added spec, spec:features, spec:api, spec:integration, and spec:unit.

          Dependencies are expected to be loaded by the consumer
          prior to loading any tasks.

    3.0.0 No tasks are automatically added to the default rake task.

          Tasks must be included explicitly.
          The only thing rake\_tasks does by default is load rake tasks for you.

          Added cane and checksum tasks.

          Added `rake test:script` as a workaround
          to problems with `rake test:full`.
          For some reason the gem command no longer works
          for me from the shell scripts.

          Support for rake 0.8.7 was removed due
          to what appears to be issues with rspec.

          Custom rake tasks should now load properly from any tasks folder
          under the project root.

          Generated README.md is now named readme.md (lowercase).

    2.0.6 Use markdown for generated README.
          Convert rake\_task's README to markdown and rename it to README.md.

          The gemspec is now located by extension rather than root folder.

    2.0.5 Specify load order of rake tasks.

    2.0.4 Added license files to the included files in the gemspec.
          Excluded Gemfile.lock from included fileo in the gemspec.

    2.0.3 Added bundle\_install.sh to the included files in the gemspec.

    2.0.2 test:[test\_file] will now run all the tests in the specified file
          if a method is not specified. It should be noted that 'test\_file' is
          the name of the file with the test pattern removed
          (i.e. 'my\_module\_test.rb' => 'my\_module',
          'test\_my\_module.rb' => 'my\_module').

    2.0.1 Added test:full task (requires rvm).

          test:full allows a user to run tests against multiple ruby/gemset/rake
          configurations by specifying them in a yaml file in the test folder.

          A common rubies.yml file might look something like this:

          - ruby: 1.9.2
            gemset: my\_gem\_test
          - ruby: 1.9.3
            gemset: my\_gem\_test


Additional Documentation
------------------------

    rake rdoc:app


Gemfile.lock
------------

Common advice is to not check in the Gemfile.lock for libraries.

This is a terrible practice.

If you attempt to use a gem that has no Gemfile.lock
committed, then you have no idea what combination
of dependencies has a reasonable expectation of working.
If you are a maintainer of said gem,
you will have a local Gemfile.lock that likely works.
And you are probably not deleting it EVERY time you
work on the gem.
We all know that we SHOULD delete the Gemfile.lock on occasion
and some of us maybe even do it.
But more of us run an occasional `bundle update`
and keep on trucking.

The point is that on an actively-maintained gem,
not checking the Gemfile.lock in only makes it harder
to get started helping, not easier.
I will gladly remove my Gemfile.lock once I have a passing suite
with known 'supported' dependencies.
At that point, I may get errors from udpated dependencies
that would be a good starting point for contributions.
Or I may just continue pursuing the pull request to fix/update/add a feature
that caused me to care about a Gemfile.lock for the project in the first place.
Either way, the project is better for it.

There are far more out-of-date/unmaintained gems than there are
up-to-date/active gems.
Many of the out-of-date gems are actually useful.
And many of them have dependencies that don't work when updated.
It is much harder to get something working if you have no idea
what a good starting point is
or even whether it was expected to work at some point
(maybe the test suite was failing when it was abandoned).
The point is that it very difficult to know the difference
without a Gemfile.lock.

This is one of the dumbest things we do.
The practice of not checking in a Gemfile.lock for libraries is ridiculous
and we should start checking them in.


License
-------

RakeTasks is released under the LGPLv3 license.


[gems]:        https://github.com/rubygems/gems
[cane]:        http://github.com/square/cane
[travis-yaml]: https://github.com/travis-ci/travis-yaml
[tasks]:       #Tasks
[wwtd]:        https://github.com/grosser/wwtd
[travisci]:    https://travis-ci.org
