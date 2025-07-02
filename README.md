# README

Run tests serially:

```
bin/rspec
```

This works: ✅

---

Run tests in parallel:

```
bin/rails parallel:spec
```

This works: ✅

---

Create the parallel test databases:

```
RAILS_ENV=test bin/rails parallel:create
```

This works ✅

---

Create the parallel test database without setting `RAILS_ENV=test`:

```
bin/rails parallel:create
```

This fails ❌:

(Note: I picked JWT very randomly as the example here. The problem isn't to do with JWT in particular).

```
$ rails parallel:create
bin/rails aborted!
bin/rails aborted!
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
bin/rails aborted!
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
bin/rails aborted!
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
bin/rails aborted!
bin/rails aborted!
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
bin/rails aborted!
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
bin/rails aborted!
bin/rails aborted!
bin/rails aborted!
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
bin/rails aborted!
NameError: uninitialized constant JWT (NameError)

  puts JWT
       ^^^
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/initializers/jwt.rb:3:in '<top (required)>'
/Users/mjacobson/src/gh/maxjacobson/parallelagram/config/environment.rb:5:in '<top (required)>'
Tasks: TOP => db:create => db:load_config => environment
(See full trace by running task with --trace)
```

What seems to be happening:

- I run `bin/rails parallel:create` without setting `RAILS_ENV`
- Rails defaults to the development environment
- Bundler loads all of the gems in the development group of Gemfile
- dotenv-rails loads all of the environment variables in `.env.development` and exports them
- all of the rails initializers run without issue
- parallel_tests creates N subprocesses to create N databases. Each of those subproceses inherits the parent
  environment, which includes the variables defined in `.env.development`
- The subprocesses run with `RAILS_ENV=test` set, and so
    - Bundler loads all of the gems in the test group of Gemfile
    - dotenv loads the variables defined in `.env.test`. But it will not overwrite any value which is already in the
      environment, and so it does not overwrite `ENABLE_COOL_FEATURE=true` with the `ENABLE_COOL_FEATURE=false` value in
      `.env.test`
    - The subprocesses proceed to run all of the Rails initializers, and the error occurs because
      `ENABLE_COOL_FEATURE=true` and yet JWT is not loaded

Remediations available to me:

1. make that gem available in the development group too, so it's safe to run that initializer when creating parallel
   databases
2. Always export `RAILS_ENV=test` before running `bin/rails parallel:create`


It would be nice if it Just Worked though.
