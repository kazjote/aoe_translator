require File.dirname(__FILE__) + '/../translate'

describe TranslationFile do
  it "should load file" do
    TranslationFile.parse('spec/fixture.xml').should_not be_nil
  end

  describe "with parsed file" do
    before(:each) do
      @translation_file = TranslationFile.parse('spec/fixture.xml')
    end

    it "should return hash of translations" do
      @translation_file.translations.should == {
        '10' => 'translated 10',
        '20' => 'translated 20'
      }
    end

    it "should replace translation" do
      @translation_file.translate('10', 'translation modified')
      @translation_file.update_translations!
      @translation_file.translations(true)['10'].should == 'translation modified'
    end
  end
end

describe "Translator" do
  it "should translate each entry" do
    @df = mock(:dictionary_file)
    @tf = mock(:translatable_file)

    @df.should_receive(:translations).and_return('10' => 'string 1', '20' => 'string 2')
    @tf.should_receive(:translate).with('10', 'string 1')
    @tf.should_receive(:translate).with('20', 'string 2')

    translator = Translator.new(@df, @tf)
    translator.translate!
  end
end

