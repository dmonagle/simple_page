require "simple_page/engine"
require 'simple_page/active_record_extension'

ActiveRecord::Relation.send :include, SimplePageExtension