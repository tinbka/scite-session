# SciTE::Session

This gem is used to ease a process of starting to work on a new project.  
It handles SciTE sessions using a yaml file with a list of windows needed to pop up on demand. With a command it restores and arranges on a display a project-specific set of SciTE windows setting them custom meta-titles.  
It works only within KDE using `kwin`, `xwininfo` and `wmctrl`.

SciTE is a non-popular text editor which I use for several reasons:  
1. My eyes favor non-monospace fonts.  
2. Several years ago I made cute lexers with beautiful color scheme for Ruby, CofeeScript, HAML, and Slim.  
3. It allows to arrange its instances so that I have configs in the first corner, models in the second, controllers in the third and so on. One day it has become mnemonical.

I use one Dolphin instance to manage files which allows text editor windows to contain only code not wasting display space.

For more info on title template read comment at top of `./bin/kwintag.fish`

## Installation

Inside new project dir, so that it would be installed into an according gemset, run

$ gem install scite-session

## Usage

Suggest there is two windows for project "my-app": one with models and another with controllers.  
Save sessions to `~/scite/my-app/models` and `~/scite/my-app/controllers` accordingly.  
In a console:

```ruby
require 'scite/session'
windows = SciTE::Window.find_all
windows[0].title = 'Models: :title:'
windows[1].title = 'Controllers: :title:'
windows[0].session = 'my-app/models'
windows[1].session = 'my-app/controllers'
SciTE::Session.save windows, layout: 'my-app'
```

Now when you run

```ruby
SciTE::Session.restore layout: 'my-app'
```
or
```
$ scite-session my-app
```

Those windows will be back on positions.  
You can manually adjust a layout at ~/scite/layouts/my-app.yml