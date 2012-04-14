# locally-developed modules
require 'acts_as_faceted'
require 'acts_as_filesystem'
require 'acts_as_having_boxes'
require 'acts_as_having_image'
require 'acts_as_having_posts'
require 'acts_as_having_settings'
require 'acts_as_searchable'
require 'authenticated_system'
require 'countries_helper'
require 'maybe_add_http'
require 'needs_profile'
require 'short_filename'
require 'white_list_filter'
require 'user_activation_job'

# reload model because of conflict with Task (alias of Rake::Task)
require 'task'
