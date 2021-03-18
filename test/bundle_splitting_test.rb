# frozen_string_literal: true

require 'test_helper'
<<<<<<< HEAD

class BundleSplittingTest < Minitest::Test
  def small_jws_is_not_split
=======
require 'health_cards/chunking'

FILEPATH_SMALL = 'test/fixtures/example-00-d-jws.txt'
FILEPATH_LARGE = 'test/fixtures/example-02-d-jws.txt'

describe HealthCards::Chunking do
  class DummyClass
  end

  before(:all) do
    @dummy_class = DummyClass.new
    @dummy_class.extend(HealthCards::Chunking)
>>>>>>> Rename bundle splitting to chunking
  end
end