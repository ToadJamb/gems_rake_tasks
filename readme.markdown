Welcome to RakeTasks
====================

RakeTasks provides basic rake tasks for generating documentation,
building and installing gems, and running tests.
It will also load additional rake tasks if they are in a folder named 'tasks'.
mmmm yummy

The following assumptions are currently made:

* There is a valid .gemspec file in the root folder that is named the same
   as the root folder.

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

* Additional rake tasks are named \*.rake (as of 3.0.0) and reside in a folder named 'tasks'.

* README generation uses the gemspec data to populate the license information.

  If README.md does not exist, one will be created.
  If README.md does exist, a README\_GENERATED.md file will be created,
  so as not to overwrite a 'real' README.md file.

The default task will be set in the following order:

1. If tests are found, rake will run test:all.

2. If tests are not found, but an appropriately named .gemspec file is,
   gem:build will be run.

3. If no tests or .gemspec are found, rdoc:app will be run.

Getting Started
---------------

Install RakeTasks at the command prompt if you haven't yet:

    $ gem install rake\_tasks

Require the gem in your Gemfile:

    gem 'rake\_tasks', '~> 3.0.0.pre'

Require the gem wherever you need to use it:

    require 'rake\_tasks'

Updates
-------

    4.0.0 No tasks are automatically added to the default rake task.

          Tasks must be included explicitly.
          The only thing rake\_tasks does by default is load rake tasks for you.

    3.0.0 Added `rake test:script` as a workaround to problems with `rake test:full`.
          For some reason the gem command no longer works for me from the shell scripts.

          Support for rake 0.8.7 was removed due to what appears to be issues with rspec.

          Custom rake tasks should now load properly from any tasks folder under the project root.

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

License
-------

RakeTasks is released under the LGPLv3 license.
