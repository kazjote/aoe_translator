require 'rubygems'
require 'rexml/document'
require 'progressbar'
require 'iconv'
require 'stringio'

class TranslationFile < Struct.new(:doc)

  def self.parse(path)
    data = File.read(path)
    data = Iconv.conv('utf-8', 'utf-16', data)
    data = data[41..-1]
    doc = REXML::Document.new(data)
    new(doc)
  end

  def translated
    @translated ||= {}
  end

  def update_translations!
    return if translated.size < 1
    doc.elements.each('/StringTable/Language/String') do |element|
      id = element.attributes["_locID"]
      translation = translated[id]
      element.text = translation if translation
    end
    translated = {}
  end

  def translations(reload = true)
    ret = {}
    doc.elements.each('/StringTable/Language/String') do |element|
      ret[element.attributes["_locID"]] = element.text
    end
    ret
  end

  def translate(id, text)
    translated[id] = text
  end
end

class Translator < Struct.new(:dictionary_file, :translatable_file)
  def translate!
    translations = dictionary_file.translations
    translations.each_pair do |id, text|
      translatable_file.translate(id, text)
    end
  end
end

if __FILE__ == $0
  dictionary = TranslationFile.parse('translated/stringtable.xml')
  Dir['original/*'].each do |name|
    puts "Processing file #{name}"
    translatable = TranslationFile.parse(name)
    translator = Translator.new(dictionary, translatable)
    translator.translate!

    changed_path = 'changed/' + File.basename(name)

    File.open(changed_path, 'w') do |file|
      out = StringIO.new
      out.puts '<?xml version="1.0" encoding="UTF-16"?>'
      out.puts
      translatable.update_translations!
      translatable.doc.write(out)
      out.rewind
      raw = out.read
      raw.gsub!("\n", "\r\n")
      file.write Iconv.conv('utf-16', 'utf-8', raw)
    end
  end
end

