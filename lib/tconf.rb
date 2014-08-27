require 'tconf/version'
require 'yaml'
require 'csv'
require 'pathname'
require 'class_config'

module Tconf

  class HashExt < Hash
    def initialize(hash=nil)
      super()
      update hash if hash
    end

    def to_dictionary(separator='.', parent_key=nil)
      each_with_object({}) do |(k,v), hash|
        key = [parent_key, k].compact.join(separator)
        if v.is_a? Hash
          hash.merge! HashExt.new(v).to_dictionary(separator, key)
        else
          hash[key] = v
        end
      end
    end
  end


  class Key < String
    attr_reader :name, :scope, :file

    def initialize(key, file)
      super key
      sections = key.split '.'
      @name = sections.pop
      @scope = sections.join '.'
      @file = file
    end
  end


  class Translator

    extend ClassConfig

    attr_config :languages, %w(es en pt)
    attr_config :path, Pathname.new(Dir.pwd).join('config', 'locales')
    attr_config :default_file, 'translations'

    def self.[](key)
      translations[key]
    end

    def self.[]=(key, t)
      key = Key.new(key, default_file) unless key.is_a? Key
      translations[key] = Hash[t.map { |k,v| [k.to_s.downcase, v] }]
    end

    def self.delete(key)
      translations.delete key
    end

    def self.translations
      @translations ||= load
    end

    def self.reload
      @translations = nil
      self
    end

    def self.check
      errors = {}
      translations.each do |k,v|
        missing = []
        languages.each do |lang|
          missing << lang unless v.key? lang
        end
        if missing.any?
          errors[k] = {
            translations: v,
            missing: missing
          }
        end
      end
      Hash[errors.sort_by { |k,v| k }]
    end

    def self.save
      hash = {}
      
      translations.sort_by { |k,v| k }.each do |k,v|
        v.each do |lang, value|
          h = hash[k.file] ||= {}
          h = h[lang] ||= {}
          k.scope.split('.').each { |s| h = h[s] ||= {} }
          h[k.name] = value
        end
      end

      remove_files
      
      hash.each do |file, languages|
        languages.each do |l,t|
          File.write(path.join("#{file}.#{l}.yml"), YAML.dump(l => t))
        end
      end

      true
    end

    def self.export(filename)
      CSV.open(filename, 'w') do |csv|
        csv << ['Scope', 'Key', *languages.map(&:upcase)]
        translations.sort_by { |k,v| k }.each do |key, t|
          csv << [key.scope, key.name, *languages.map { |l| t[l] }]
        end
      end
    end

    private

    def self.load
      Hash.new { |h,k| h[k] = {} }.tap do |translations|
        translation_files.each do |locale|
          HashExt.new(YAML.load_file(locale)).to_dictionary.each do |k,v|
            lang, *sections = k.split '.'
            key = Key.new sections.join('.'), File.basename(File.basename(locale, '.*'), '.*')
            translations[key][lang] = v
          end
        end
      end
    end

    def self.remove_files
      translation_files.each { |f| File.delete f }
    end

    def self.translation_files
      Dir.glob path.join('*.yml')
    end

  end

end