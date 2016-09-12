# Redmine Teaching Extension

Trabajo Fin de Grado del Grado en Ingeniería Informática de la Universidad de Almería.

Se trata de un producto software cuyo objetivo es extender el sistema de gestión de proyectos Redmine mediante un plugin para su uso en docencia.

El propósito de Redmine Teaching Extension es llevar a cabo una nueva función de creación de nueva petición de Redmine desde un proyecto padre que contenga más de un subproyecto para, de este modo, posteriormente propagar dicha petición entre todos estos subproyectos.
---------------------------------------------------------------------------------------------------------------------------
Final Career Project of the Grade of Computer Sciences of the University of Almería.
It's a software product which extend the web-based project management and issue tracking tool _Redmine_ through a plugin for its use in teaching.
Redmine Teaching Extension allows you to create a new issue in a root project and propagate it to its subprojects at the same time. So you can create the same issue, multiple times at once.

Installation notes

1. Copy your plugin directory into #{RAILS-ROOT}/plugins (Redmine 2.x). If you are downloading the plugin directly from GitHub, you can do so by changing into your plugin directory and issuing a command like @git clone git://github.com/MarioMerino/redmine_teaching_extension.git@

2. If the plugin requires a migration, run the following command in #{RAILS_ROOT} to upgrade your database (make a db backup before)

@bundle exec rake redmine:plugins:migrate RAILS_ENV=production@
3. Restart redmine

You should now be able to see the plugin list in Administration -> Plugins and configure the newly installed plugin (if the plugin requires to be configured).
