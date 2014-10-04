# -- encoding: utf-8 --
require 'digest/md5'
require 'fileutils'
require 'tempfile'
require 'helpers_for_test'

class TestWrite < TestCase

  def setup
    @temp_file = Tempfile.new('test')
    @temp_file.close
    @temp_filename = @temp_file.path
    @org_filename = File.dirname(__FILE__) + '/data/test.jpg'
    FileUtils.cp(@org_filename, @temp_filename)
    @mini_exiftool = MiniExiftool.new @temp_filename
    @mini_exiftool_num = MiniExiftool.new @temp_filename, :numerical => true
  end

  def teardown
    @temp_file.delete
  end

  def test_access_existing_tags
    assert_equal 'Horizontal (normal)', @mini_exiftool['Orientation']
    @mini_exiftool['Orientation'] = 'some string'
    assert_equal 'some string', @mini_exiftool['Orientation']
    assert_equal false, @mini_exiftool.changed?('Orientation')
    @mini_exiftool['Orientation'] = 2
    assert_equal 2, @mini_exiftool['Orientation']
    assert @mini_exiftool.changed_tags.include?('Orientation')
    @mini_exiftool.save
    assert_equal 'Mirror horizontal', @mini_exiftool['Orientation']
    @mini_exiftool_num.reload
    assert_equal 2, @mini_exiftool_num['Orientation']
  end

  def test_access_existing_tags_numerical
    assert_equal 1, @mini_exiftool_num['Orientation']
    @mini_exiftool_num['Orientation'] = 2
    assert_equal 2, @mini_exiftool_num['Orientation']
    assert_equal 2, @mini_exiftool_num.orientation
    @mini_exiftool_num.orientation = 3
    assert_equal 3, @mini_exiftool_num.orientation
    assert @mini_exiftool_num.changed_tags.include?('Orientation')
    @mini_exiftool_num.save
    assert_equal 3, @mini_exiftool_num['Orientation']
    @mini_exiftool.reload
    assert_equal 'Rotate 180', @mini_exiftool['Orientation']
  end

  def test_access_non_writable_tags
    @mini_exiftool_num['FileSize'] = 1
    assert_equal true, @mini_exiftool_num.changed?
    @mini_exiftool_num['SomeNonWritableName'] = 'test'
    assert_equal true, @mini_exiftool_num.changed?
  end

  # Catching rubyforge bug [#29596]
  # Thanks to Michael Grove for reporting
  # Part 1
  def test_quotes_in_values
    caption = "\"String in quotes\""
    @mini_exiftool.caption = caption
    assert_equal true, @mini_exiftool.save, 'Saving error'
    @mini_exiftool.reload
    assert_equal caption, @mini_exiftool.caption
  end

  # Catching rubyforge bug [#29596]
  # Thanks to Michael Grove for reporting
  # Part 2
  def test_quotes_and_apostrophe_in_values
    caption = caption = "\"Watch your step, it's slippery.\""
    @mini_exiftool.caption = caption
    assert_equal true, @mini_exiftool.save, 'Saving error'
    @mini_exiftool.reload
    assert_equal caption, @mini_exiftool.caption
  end

  def test_time_conversion
    t = Time.now
    @mini_exiftool_num['DateTimeOriginal'] = t
    assert_kind_of Time, @mini_exiftool_num['DateTimeOriginal']
    assert_equal true, @mini_exiftool_num.changed_tags.include?('DateTimeOriginal')
    @mini_exiftool_num.save
    assert_equal false, @mini_exiftool_num.changed?
    assert_kind_of Time, @mini_exiftool_num['DateTimeOriginal']
    assert_equal t.to_s, @mini_exiftool_num['DateTimeOriginal'].to_s
  end

  def test_float_conversion
    assert_kind_of Float, @mini_exiftool_num['BrightnessValue']
    new_time = @mini_exiftool_num['BrightnessValue'] + 1
    @mini_exiftool_num['BrightnessValue'] = new_time
    assert_equal new_time, @mini_exiftool_num['BrightnessValue']
    assert_equal true, @mini_exiftool_num.changed_tags.include?('BrightnessValue')
    @mini_exiftool_num.save
    assert_kind_of Float, @mini_exiftool_num['BrightnessValue']
    assert_equal new_time, @mini_exiftool_num['BrightnessValue']
  end

  def test_integer_conversion
    assert_kind_of Integer, @mini_exiftool_num['MeteringMode']
    new_mode = @mini_exiftool_num['MeteringMode'] - 1
    @mini_exiftool_num['MeteringMode'] = new_mode
    assert_equal new_mode, @mini_exiftool_num['MeteringMode']
    assert @mini_exiftool_num.changed_tags.include?('MeteringMode')
    @mini_exiftool_num.save
    assert_equal new_mode, @mini_exiftool_num['MeteringMode']
  end

  def test_rational_conversion
    new_exposure_time = Rational(1, 125)
    @mini_exiftool.exposure_time = new_exposure_time
    assert @mini_exiftool.changed?, 'No changing of value.'
    ok = @mini_exiftool.save
    assert ok, 'Saving failed.'
    @mini_exiftool.reload
    assert_equal new_exposure_time, @mini_exiftool.exposure_time
  end

  def test_list_conversion
    arr =  ['a', 'b', 'c']
    @mini_exiftool['Keywords'] = arr
    ok = @mini_exiftool.save
    assert ok
    assert_equal arr, @mini_exiftool['Keywords']
    arr = ['text, with', 'commas, let us look']
    @mini_exiftool['Keywords'] = arr
    ok = @mini_exiftool.save
    assert ok
    if MiniExiftool.exiftool_version.to_f < 7.41
      assert_equal ['text', 'with', 'commas', 'let us look'], @mini_exiftool['Keywords']
    else
      assert_equal arr, @mini_exiftool['Keywords']
    end
  end

  def test_revert_one
    @mini_exiftool_num['Orientation'] = 2
    @mini_exiftool_num['ISO'] = 200
    res = @mini_exiftool_num.revert 'Orientation'
    assert_equal 1, @mini_exiftool_num['Orientation']
    assert_equal 200, @mini_exiftool_num['ISO']
    assert_equal true, res
    res = @mini_exiftool_num.revert 'Orientation'
    assert_equal false, res
  end

  def test_revert_all
    @mini_exiftool_num['Orientation'] = 2
    @mini_exiftool_num['ISO'] = 200
    res = @mini_exiftool_num.revert
    assert_equal 1, @mini_exiftool_num['Orientation']
    assert_equal 400, @mini_exiftool_num['ISO']
    assert_equal true, res
    res = @mini_exiftool_num.revert
    assert_equal false, res
  end

end
