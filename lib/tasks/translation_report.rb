require 'yaml'

# we will want to change this, as the english keys will get moved
# into different files, and we will have a script that dumps them in 
# one big file, and this should look at that big file:
en = YAML.load_file 'config/locales/en.yml'


def extract_keys()
  keys = {}
  ["app","lib","extensions","vendor/crabgrass_plugins"].each do |dir|
    lines = `grep -rh '\\.t\\( \\|(\\)' #{dir} | grep -v '^ *#'`.split "\n"
    # this way to exclude comments could grab a line like: some code # blah.t
    # -h is so we will not output filename

    lines.each do |line|
      match = line.match(/:([0-9a-zA-Z_]+)\.t/)
      # catches :standard.t
      (keys[match[1]] = true) if match

      match_i18n = line.match(/I18n\.t(\(| )(:|'|")([0-9a-zA-Z_]+)(,|\)|'|"| )/)
      # catches I18n.t "less good", I18n.t("less good", blah), I18n.t 'less good', I18n.t('less good'), I18n.t :ok, I18n.t :ok, blah, I18n.t(:ok), etc..
      (keys[match_i18n[3]] = true) if match_i18n
    end
  end
  keys

end

namespace :cg do
  namespace :i18n do

    desc "translation keys report"
    task :translation_report do

      keys = extract_keys

      p 'Never-used language keys:'
      p  (en['en'].keys - keys.keys)
      p 'There are '+ (en['en'].keys - keys.keys).count.to_s + ' never-used language keys'
      p 'Used in code but not in yaml:'
      p (keys.keys - en['en'].keys)

      p 'Yaml key count:'
      p en['en'].keys.count
      p 'Language keys in code count:'
      p  keys.keys.count
    end
  end
end

