Dir.glob(File.expand_path("../seeds/#{APP_CONFIG[:node]}/*.rb", __FILE__)).sort.each &method(:require)
