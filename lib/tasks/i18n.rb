require 'yaml'
require 'fileutils'
require 'crabgrass/boot'

def extract_keys
  keys = {}
  ['app', 'lib/dummystrings.rb', 'extensions', 'vendor/crabgrass_plugins'].each do |dir|
    # this will catch all non-commented-out lines that contain '.t'. It seems better to look at more lines and then distinguish $
    lines = `find #{dir} -type f -exec grep '\\.t' \\{\\} \\; | grep -v '^ *#'`.split "\n"

    lines.each do |line|
      # there could be multiple matches per line
      matches = line.scan(/([^:]|^):([0-9a-zA-Z_]+)\.t?/)
      # catches :standard.t and :standard.tcap

      matches.each do |match|
        (keys[match[1]] = true) if match
      end

      # again, look for multiple matches in line
      matches_i18n = line.scan(/I18n\.t(\(| )(:|'|")([0-9a-zA-Z_]+)(,|\)|'|"| )/)
      # catches I18n.t "less good", I18n.t("less good", blah), I18n.t 'less good', I18n.t('less good'), I18n.t :ok, I18n.t :ok, blah, I18n.t(:ok), etc..

      matches_i18n.each do |match_i18n|
        (keys[match_i18n[2]] = true) if match_i18n
      end
    end
  end

  keys
end

def load_data
  unless File.exist?('config/en.yml')
    puts 'Skipping, no config/en.yml. This might be because you have not run `rake cg:i18n:bundle`.'
    exit
  end
  en = YAML.load_file('config/en.yml')['en']
  keys = extract_keys
  # FIXME orphaned includes namespaces like 'crabgrass' or 'activerecord'
  orphaned = en.keys - keys.keys
  missing = keys.keys - en.keys
  duplicates = []
  duplicate_hash = en.values.each_with_object(Hash.new(0)) { |i, h| h[i] += 1; }
  duplicate_hash.each do |value, count|
    duplicates << value if count > 1
  end
  [en, keys, orphaned, missing, duplicates]
end

def load_data_for_dups file, lang
  unless File.exist?(file)
    puts 'Skipping, no '+ file + '. This might be because you have not run `rake cg:i18n:bundle`.'
    exit
  end
  en = YAML.load_file(file)[lang]
  keys = extract_keys
  orphaned = en.keys - keys.keys
  missing = keys.keys - en.keys
  duplicates = []
  duplicate_hash = en.values.each_with_object(Hash.new(0)) { |i, h| h[i] += 1; }
  duplicate_hash.each do |value, count|
    duplicates << value if count > 1
  end
  duplicates_hash = Hash.new
  duplicate_key_hash = en.map do |key, value|
    if duplicates.include? value
      if duplicates_hash[value]
       duplicates_hash[value].push(key)
      else
       duplicates_hash[value] = [key]
      end
    end
  end
  [en, keys, orphaned, missing, duplicates_hash]
end


# This assumes you're already in a directory with a transifex.netrc
# Typically this would be the config dir.
def download_from_transifex(lang, resources)
  api_url = 'https://www.transifex.com/api/2/'
  auth = '--netrc-file transifex.netrc'

  puts "downloading #{lang}"
  resources.each do |resource, target|
    path = "project/crabgrass/resource/#{resource}/translation/#{lang}/?file"
    `curl -L #{auth} -X GET '#{api_url}#{path}' > #{target}`
  end
end

namespace :cg do
  namespace :i18n do
    desc 'print translation report'
    task :report do
      en, keys, orphaned, missing, dups = load_data
      puts format('Total keys in yaml: %s', en.keys.count)
      puts format('Total keys in code: %s', keys.keys.count)
      puts format('Orphaned keys: %s (translated, but not in code)', orphaned.count)
      puts format('Missing keys: %s (in code, but not translated)', missing.count)
      puts format('Duplicate values: %s', dups.count)
      puts format('Currently enabled languages: %s', Conf.enabled_languages.count)
      puts
      puts 'run "rake cg:i18n:orphaned" for a list of orphaned keys'
      puts 'run "rake cg:i18n:missing" for a list of missing keys'
      puts 'run "rake cg:i18n:dups" for a list of duplicate values'
      puts 'run "rake cg:i18n:dups_stats" for a list of duplicate key statistics'
      puts 'run "rake cg:i18n:bundle" to combine the keys in config/locales/en/*.yml to config/en.yml'
    end

    desc 'list keys not in code'
    task :orphaned do
      en, keys, orphaned, missing, dups = load_data
      puts orphaned.join("\n")
    end

    desc 'list keys missing from config/en.yml'
    task :missing do
      en, keys, orphaned, missing, dups = load_data
      puts missing.join("\n")
    end

    desc 'list duplicate values'
    task :dups do
      en, keys, orphaned, missing, dups = load_data
      puts dups.join("\n")
    end

    desc 'duplicate key stats'
    task :dups_stats do
      keys_count = Hash.new(0)
      dups_lang = Hash.new
      Conf.enabled_languages.each do |lang|
        if lang == 'en'
          file = 'config/en.yml'
        else
          file = 'config/locales/'+lang+'.yml'
        end
        all, keys, orphaned, missing, dups = load_data_for_dups file, lang
        dups_lang[lang] = dups
        dups.map do |key, vals|
          vals.each do |val|
            keys_count[val] += 1
          end
        end
      end
      sorted_counts = keys_count.sort_by {|k,v| v}.reverse
      sorted_counts.each do |key, val|
        puts key.to_s + ":" + val.to_s
      end
      dups_lang.each do |lang|
        lang.each do |key, val|
          puts key.to_s + ":" + val.to_s
        end
      end
    end

    #
    # for coding, it helps to have the english strings in separate files.
    # for translating, it helps to have a single file. This action will combine
    # the small files into one big one.
    #
    # config/locales/en/*.yml --> the english locale files that are actually used.
    # config/en.yml --> bundled locale file used for transifex and other cg:i18n tasks
    #
    # transifex is set to automatically pull from
    # https://0xacab.org/riseuplabs/crabgrass/raw/master/config/en.yml
    #
    desc 'combine locales/en/*.yml to config/en.yml'
    task :bundle do
      Dir.chdir('config/locales/') do
        en_yml = '../en.yml'
        File.unlink(en_yml) if File.exist?(en_yml)
        File.open(en_yml, 'w') do |output|
          output.write("### Do NOT edit this file directly, as all changes will be overwritten by\n")
          output.write("### the bundle script. Instead, make changes in the appropriate file in\n")
          output.write("### config/locales/en and recreate this file with the cg:i18n:bundle task.\n\n")
          output.write('en:')
          Dir.glob('en/*.yml').sort.each do |file|
            ## print separator to see where another file begins
            output.write("\n\n" + '#' * 40 + "\n" + '### ' + file + "\n")
            output.write(
              # remove the toplevel "en" key
              YAML.load_file(file)['en']
              .to_yaml.
              # prefix all lines with two spaces (we're nested below "en:")
              lines.map { |line| "  #{line}" }[
                1..-1 # << skip the first line (it's "---" and freaks out the parser if it sees it multiple times in a file)
              ].join
            )
          end
        end
        puts "You can now find the bundled en.yml in: #{File.expand_path(en_yml, Dir.pwd)}"
      end
    end

    # OR:
    # find the orphaned keys.
    # find each line that starts with an even number of spaces then orphaned key then a colon, and stick a !# at the beginning.
    # this would break with multi-line translations
    # or we could manually deal with multiline keys?
    # if it has pipe, print out
    # only find each key once.

    desc 'comment out orphaned keys'
    task :disable do
      en, keys, orphaned, missing, dups = load_data
      Dir.chdir('config/locales/') do
        Dir.glob('en/*.yml').sort.each do |file|
          File.rename(file, "#{file}bak")
          File.open("#{file}bak", 'r') do |f_bak|
            File.open(file, 'w') do |f|
              while line = f_bak.gets
                orph = false
                orphaned.each do |orphan| # these are just top-level keys
                  # orphans only have top-level keys
                  # so we are only looking for keys indented by 2
                  next unless /^(\s\s)#{orphan}:(\s+\S)/ =~ line
                  f.write('  ##!' + line)
                  orph = true
                  # break
                end
                f.write(line) unless orph
              end
            end
          end
          File.unlink("#{file}bak")
        end
      end
    end

    desc 'pull translations from transifex'
    task :download do
      Dir.chdir('config/') do
        unless File.exist?('transifex.netrc')
          puts 'In order to download translations, you need a config/transifex.netrc file.'
          puts 'For example:'
          puts 'machine www.transifex.com login crabgrass password xxxxxxxxxxxxxxxxx'
          exit
        end
        Conf.enabled_languages.each do |lang|
          next if lang == 'en'
          download_from_transifex lang,
                                  develop: "locales/#{lang}.yml",
                                  riseup: "../extensions/locales/riseup/#{lang}.yml"
        end
      end
    end
  end
end
