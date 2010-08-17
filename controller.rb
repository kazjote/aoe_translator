require 'sinatra'
require 'haml'

require File.dirname(__FILE__) + '/translate'

def has_file?(param_key)
  instance_variable_set(:"@#{param_key}",
    params[param_key] && params[param_key][:tempfile])
end

set :haml, {:format => :html5 }

get '/' do
  haml :index
end

post '/' do
  if has_file?(:dictionary) && has_file?(:to_translate)
    dictionary = TranslationFile.parse(@dictionary.path)
    to_translate = TranslationFile.parse(@to_translate.path)
    translator = Translator.new(dictionary, to_translate)
    translator.translate!

    raw = StringIO.new
    raw.puts '<?xml version="1.0" encoding="UTF-16"?>'
    raw.puts
    to_translate.update_translations!
    to_translate.doc.write(raw)
    raw.rewind
    raw = raw.read
    raw.gsub!("\n", "\r\n")
    out = Tempfile.new("translated.xml")
    out.write Iconv.conv('utf-16', 'utf-8', raw)
    out.close
    send_file(out.path, :filename => "translated.xml")
    out.unlink
  else
    halt 200, 'Please go back and remember about uploading files!'
  end
end

