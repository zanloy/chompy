# -- encoding: utf-8 --
require 'helpers_for_test'

class TestRead < TestCase

  def setup
    @data_dir = File.dirname(__FILE__) + '/data'
    @filename_test = @data_dir + '/test.jpg'
    @mini_exiftool = MiniExiftool.new @filename_test
  end

  def test_access
    assert_equal 'DYNAX 7D', @mini_exiftool['Model']
    assert_equal 'MLT0', @mini_exiftool['maker_note_version']
    assert_equal 'MLT0', @mini_exiftool[:MakerNoteVersion]
    assert_equal 'MLT0', @mini_exiftool[:maker_note_version]
    assert_equal 'MLT0', @mini_exiftool.maker_note_version
    assert_equal 400, @mini_exiftool.iso
  end

  def test_tags
    assert @mini_exiftool.tags.include?('FileSize')
  end

  def test_conversion
    assert_kind_of String, @mini_exiftool.model
    assert_kind_of Time, @mini_exiftool['DateTimeOriginal']
    assert_kind_of Float, @mini_exiftool['MaxApertureValue']
    assert_kind_of String, @mini_exiftool.flash
    assert_kind_of Fixnum, @mini_exiftool['ExposureCompensation']
    assert_kind_of String, (@mini_exiftool['SubjectLocation'] || @mini_exiftool['SubjectArea'])
    assert_kind_of Array, @mini_exiftool['Keywords']
    assert_kind_of String, @mini_exiftool['SupplementalCategories']
    assert_kind_of Rational, @mini_exiftool.shutterspeed
  end

  def test_list_tags
    assert_equal ['Orange', 'Rot'], @mini_exiftool['Keywords']
    assert_equal 'Natur', @mini_exiftool['SupplementalCategories']
    assert_equal ['Natur'], Array(@mini_exiftool['SupplementalCategories'])
  end

  def test_value_encoding
    title= 'Abenddämmerung'
    assert_equal Encoding::UTF_8, @mini_exiftool.title.encoding
    assert_equal title, @mini_exiftool.title
  end

end
