prototype-rails provides Prototype, Scriptaculous, and RJS on Rails 3.1
and later.

Prototype and Scriptaculous are pulled in by the asset pipeline, so you don't
need to copy the source files into your app. You may reference them in your
s app/assets/javascripts/application.js:

    //= require prototype
    //= require prototype_ujs
    //= require effects
    //= require dragdrop
    //= require controls

prototype-rails supports RJS debugging. RJS responses are wrapped to catch
exceptions, alert() them, and re-raise the exception. Debugging is disabled by
default. To enable in development, set `config.action_view.debug_rjs = true`
in config/environments/development.rb.

---

## Support for Rails 4.1 and above

Unfortunately, due to limited manpower and resources, the Rails core team has
not been able to confirm if this gem currently works with Rails 4.1 and above.
If you have found any problems while upgrading your application, please report
them at the [issue tracker](https://github.com/rails/prototype-rails/issues),
or better yet, submit patches by sending a [pull request](https://github.com/rails/prototype-rails/pulls).

In any case, this gem will *NOT* be officially supported on Rails 5.0 and above.
